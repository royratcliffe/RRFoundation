// RRFoundation RRPremptiveSerialQueue.m
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

#import "RRPremptiveSerialQueue.h"

@implementation RRPremptiveSerialQueue

- (id)init
{
	dispatch_queue_t preemptiveSerialQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
	dispatch_queue_t preemptingSerialQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
	self = [self initWithPreemptiveSerialQueue:preemptiveSerialQueue preemptingSerialQueue:preemptingSerialQueue];
	dispatch_release(preemptiveSerialQueue);
	dispatch_release(preemptingSerialQueue);
	return self;
}

- (id)initWithPreemptiveSerialQueue:(dispatch_queue_t)preemptiveSerialQueue
{
	dispatch_queue_t preemptingSerialQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
	self = [self initWithPreemptiveSerialQueue:preemptiveSerialQueue preemptingSerialQueue:preemptingSerialQueue];
	dispatch_release(preemptingSerialQueue);
	return self;
}

- (id)initWithPreemptiveSerialQueue:(dispatch_queue_t)preemptiveSerialQueue preemptingSerialQueue:(dispatch_queue_t)preemptingSerialQueue
{
	self = [super init];
	if (self)
	{
		dispatch_retain(_preemptive_serial_queue = preemptiveSerialQueue);
		dispatch_retain(_preempting_serial_queue = preemptingSerialQueue);
		
		dispatch_set_target_queue(_preemptive_serial_queue, _preempting_serial_queue);
	}
	return self;
}

- (void)dispatchAsync:(dispatch_block_t)block
{
	dispatch_async(_preemptive_serial_queue, block);
}

- (void)dispatchPreemptAsync:(dispatch_block_t)block
{
	dispatch_suspend(_preemptive_serial_queue);
	dispatch_async(_preempting_serial_queue, ^{
		block();
		dispatch_resume(_preemptive_serial_queue);
	});
}

- (dispatch_queue_t)preemptiveSerialQueue
{
	return _preemptive_serial_queue;
}

- (dispatch_queue_t)preemptingSerialQueue
{
	return _preempting_serial_queue;
}

- (void)dealloc
{
	dispatch_release(_preemptive_serial_queue);
	dispatch_release(_preempting_serial_queue);
}

@end
