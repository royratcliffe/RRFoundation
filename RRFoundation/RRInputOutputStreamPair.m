// RRFoundation RRInputOutputStreamPair.m
//
// Copyright © 2012, Roy Ratcliffe, Pioneering Software, United Kingdom
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the “Software”), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS,” WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//------------------------------------------------------------------------------

#import "RRInputOutputStreamPair.h"

@interface RRInputOutputStreamPair()

// You would not normally access the buffers directly. The following exposes the
// buffer implementation: just a pair of mutable data objects.
@property(strong, NS_NONATOMIC_IOSONLY) NSMutableData *inputBytes;
@property(strong, NS_NONATOMIC_IOSONLY) NSMutableData *outputBytes;

- (void)handleInputEvent:(NSStreamEvent)eventCode;
- (void)handleOutputEvent:(NSStreamEvent)eventCode;
- (void)hasSpaceAvailable;
- (void)writeBytes;

@end

@implementation RRInputOutputStreamPair

// streams
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;

@synthesize delegate = _delegate;

// buffers
@synthesize inputBytes = _inputBytes;
@synthesize outputBytes = _outputBytes;

// designated initialiser
- (id)init
{
	self = [super init];
	if (self)
	{
		// Set up the buffers at the outset. You can ask for available input
		// bytes even before the input stream opens. Similarly, you can write
		// output bytes even before the output opens. Hard to imagine exactly
		// why, however. Still, there is nothing to say that we can assume that
		// the output stream will open before the input opens; indeed, the
		// delegate may even respond by sending some bytes even before the
		// output stream becomes ready.
		[self setInputBytes:[NSMutableData data]];
		[self setOutputBytes:[NSMutableData data]];
	}
	return self;
}

- (void)dealloc
{
	[self close];
}

// convenience initialiser
- (id)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream
{
	self = [self init];
	if (self)
	{
		[self setInputStream:inputStream];
		[self setOutputStream:outputStream];
	}
	return self;
}

- (id)initWithSocketNativeHandle:(NSSocketNativeHandle)socketNativeHandle
{
	self = [self init];
	if (self)
	{
		CFReadStreamRef readStream = NULL;
		CFWriteStreamRef writeStream = NULL;
		CFStreamCreatePairWithSocket(kCFAllocatorDefault, socketNativeHandle, &readStream, &writeStream);
		if (readStream && writeStream)
		{
			CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
			CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
			[self setInputStream:CFBridgingRelease(readStream)];
			[self setOutputStream:CFBridgingRelease(writeStream)];
		}
		else
		{
			if (readStream) CFRelease(readStream);
			if (writeStream) CFRelease(writeStream);
			
			// Something went wrong.
			self = nil;
		}
	}
	return self;
}

/*
 * This method assumes that you have not already delegated, scheduled or opened
 * the given input-output stream pair.
 */
- (void)open
{
	for (NSStream *stream in [NSArray arrayWithObjects:[self inputStream], [self outputStream], nil])
	{
		[stream setDelegate:self];
		[stream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[stream open];
	}
}

- (void)close
{
	// Send -close first. Closing may trigger events. Let the stream emit all
	// events until closing finishes. Might be wise to check the stream status
	// first, before attempting to close the stream. The de-allocator invokes
	// -close and therefore may send a double-close if the pair has already
	// received an explicit -close message.
	for (NSStream *stream in [NSArray arrayWithObjects:[self inputStream], [self outputStream], nil])
	{
		[stream close];
		[stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	}
}

/*
 * Destructively reads bytes from the input buffer.
 */
- (NSData *)readAvailableBytes
{
	NSData *inputBytes = [[self inputBytes] copy];
	[[self inputBytes] setLength:0];
	return inputBytes;
}

- (NSString *)readLineUsingEncoding:(NSStringEncoding)encoding
{
	// The implementation first converts all the input bytes to a string. This
	// could be risky for multi-byte characters. The implementation effectively
	// assumes that multi-byte characters do not cross buffer boundaries.
	//
	// When the input range has length equal to zero, sending
	// -lineRangeForRange: searches for the first line. The final bit is
	// tricky. How to dissect the line from any remaining characters? Convert
	// the remaining characters back to data using the given encoding.
	NSString *result;
	NSString *inputString = [[NSString alloc] initWithData:[self inputBytes] encoding:encoding];
	NSRange lineRange = [inputString lineRangeForRange:NSMakeRange(0, 0)];
	if (lineRange.length)
	{
		[[self inputBytes] setData:[[inputString substringFromIndex:lineRange.length] dataUsingEncoding:encoding]];
		result = [inputString substringToIndex:lineRange.length];
	}
	else
	{
		result = nil;
	}
	return result;
}

- (void)writeBytes:(NSData *)outputBytes
{
	[[self outputBytes] appendData:outputBytes];
	
	// Trigger a "has space available" event if the output stream reports
	// available space at this point.
	if ([[self outputStream] hasSpaceAvailable])
	{
		[self hasSpaceAvailable];
	}
}

- (void)handleInputEvent:(NSStreamEvent)eventCode
{
	switch (eventCode)
	{
		case NSStreamEventHasBytesAvailable:
		{
			uint8_t buffer[4096];
			NSInteger bytesRead = [[self inputStream] read:buffer maxLength:sizeof(buffer)];
			// Do not send a -read:maxLength message unless the stream reports
			// that it has bytes available. Always send this message at least
			// once. The stream event indicates that available bytes have
			// already been sensed. Avoid asking again.
			//
			// What happens however if more bytes arrive while reading, or the
			// available bytes overflow the stack-based temporary buffer? In
			// these cases, after reading, ask if more bytes exist. Issue
			// another read if they do, and repeat while they do.
			while (bytesRead > 0)
			{
				[[self inputBytes] appendBytes:buffer length:bytesRead];
				if ([[self inputStream] hasBytesAvailable])
				{
					bytesRead = [[self inputStream] read:buffer maxLength:sizeof(buffer)];
				}
				else
				{
					bytesRead = 0;
				}
			}
			// Please note, the delegate can receive an has-bytes-available
			// event immediately followed by an error event.
			if ([[self inputBytes] length])
			{
				id delegate = [self delegate];
				if (delegate && [delegate respondsToSelector:@selector(streamPair:hasBytesAvailable:)])
				{
					[delegate streamPair:self hasBytesAvailable:[[self inputBytes] length]];
				}
			}
			if (bytesRead < 0)
			{
				
			}
			break;
		}
		default:
			;
	}
	
	id delegate = [self delegate];
	if (delegate && [delegate respondsToSelector:@selector(streamPair:handleInputEvent:)])
	{
		[delegate streamPair:self handleInputEvent:eventCode];
	}
}

- (void)handleOutputEvent:(NSStreamEvent)eventCode
{
	switch (eventCode)
	{
		case NSStreamEventHasSpaceAvailable:
		{
			[self hasSpaceAvailable];
			break;
		}
		default:
			;
	}
	
	id delegate = [self delegate];
	if (delegate && [delegate respondsToSelector:@selector(streamPair:handleOutputEvent:)])
	{
		[delegate streamPair:self handleOutputEvent:eventCode];
	}
}

- (void)hasSpaceAvailable
{
	// Note that writing zero bytes to the output stream closes the
	// connection. Therefore, avoid writing nothing unless you want to close.
	if ([[self outputBytes] length])
	{
		[self writeBytes];
	}
}

- (void)writeBytes
{
	NSInteger bytesWritten = [[self outputStream] write:[[self outputBytes] bytes] maxLength:[[self outputBytes] length]];
	if (bytesWritten > 0)
	{
		[[self outputBytes] replaceBytesInRange:NSMakeRange(0, bytesWritten) withBytes:NULL length:0];
	}
}

#pragma mark -
#pragma mark Stream Delegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
	if (aStream == [self inputStream])
	{
		[self handleInputEvent:eventCode];
	}
	else if (aStream == [self outputStream])
	{
		[self handleOutputEvent:eventCode];
	}
	else
	{
		;
	}
}

@end
