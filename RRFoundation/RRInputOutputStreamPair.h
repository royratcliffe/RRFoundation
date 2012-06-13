// RRFoundation RRInputOutputStreamPair.h
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

#import <Foundation/Foundation.h>

@class RRInputOutputStreamPair;
@protocol RRInputOutputStreamPairDelegate<NSObject>
@optional
- (void)streamPair:(RRInputOutputStreamPair *)streamPair handleInputEvent:(NSStreamEvent)eventCode;
- (void)streamPair:(RRInputOutputStreamPair *)streamPair handleOutputEvent:(NSStreamEvent)eventCode;
- (void)streamPair:(RRInputOutputStreamPair *)streamPair hasBytesAvailable:(NSUInteger)bytesAvailable;
@end

/*!
 * @brief Encapsulates a buffered input-output stream pair for convenient
 * reading and writing.
 * @details The underlying stream pair belongs to Core Foundation: a read stream
 * and a write stream; also known as an input and output stream in the Next Step
 * name space. You can easily read and write bytes to the pair. The bytes pass
 * through buffers in order to synchronise with asynchronous stream events.
 */
@interface RRInputOutputStreamPair : NSObject<NSStreamDelegate>

@property(strong, NS_NONATOMIC_IOSONLY) NSInputStream *inputStream;
@property(strong, NS_NONATOMIC_IOSONLY) NSOutputStream *outputStream;
@property(weak, NS_NONATOMIC_IOSONLY) id delegate;

- (id)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;
- (id)initWithSocketNativeHandle:(NSSocketNativeHandle)socketNativeHandle;

- (void)open;
- (void)close;
- (NSData *)readAvailableBytes;

/*!
 * @brief Special convenience method for reading lines of text based on a given
 * string encoding.
 * @details The result includes any line termination characters. There could be
 * more than one termination character at the end of the line since some line
 * termination sequences span multiple characters.
 * @result Answers @c nil if the input buffer does not contain a complete line.
 */
- (NSString *)readLineUsingEncoding:(NSStringEncoding)encoding;

- (void)writeBytes:(NSData *)outputBytes;

@end
