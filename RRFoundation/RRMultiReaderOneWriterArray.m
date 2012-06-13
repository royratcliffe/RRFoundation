// RRFoundation RRMultiReaderOneWriterArray.m
//
// Copyright © 2011, Roy Ratcliffe, Pioneering Software, United Kingdom
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

#import "RRMultiReaderOneWriterArray.h"

@implementation RRMultiReaderOneWriterArray

- (id)init
{
	self = [super init];
	if (self)
	{
		_concurrentQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
		_mutableArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	dispatch_release(_concurrentQueue);
}

- (NSUInteger)count
{
	__block NSUInteger count;
	dispatch_sync(_concurrentQueue, ^{
		count = [_mutableArray count];
	});
	return count;
}

- (id)objectAtIndex:(NSUInteger)index
{
	__block id object;
	dispatch_sync(_concurrentQueue, ^{
		object = [_mutableArray objectAtIndex:index];
	});
	return object;
}

//------------------------------------------------------------------------------
#pragma mark                                                           Mutations
//------------------------------------------------------------------------------

- (void)insertObject:(id)object atIndex:(NSUInteger)index
{
	dispatch_barrier_async(_concurrentQueue, ^{
		[_mutableArray insertObject:object atIndex:index];
	});
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
	dispatch_barrier_async(_concurrentQueue, ^{
		[_mutableArray removeObjectAtIndex:index];
	});
}

@end
