// RRFoundation NSSet+RRFoundation.m
//
// Copyright © 2011, Roy Ratcliffe, Pioneering Software, United Kingdom
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//------------------------------------------------------------------------------

#import "NSSet+RRFoundation.h"

@implementation NSSet(RRFoundation)

// Temporarily copy the set to a mutable set. This becomes redundant if the set
// is already a mutable set. Then perform the intersection, minus or union with
// self and the given set. Finally copy the mutable set back to a immutable copy
// of the result.

- (NSSet *)setByIntersectingSet:(NSSet *)aSet
{
	NSMutableSet *set;
	[set = [NSMutableSet setWithSet:self] intersectSet:aSet];
	return [[set copy] autorelease];
}

- (NSSet *)setByRemovingSet:(NSSet *)aSet
{
	NSMutableSet *set;
	[set = [NSMutableSet setWithSet:self] minusSet:aSet];
	return [[set copy] autorelease];
}

- (NSSet *)setByAddingSet:(NSSet *)aSet
{
	NSMutableSet *set;
	[set = [NSMutableSet setWithSet:self] unionSet:aSet];
	return [[set copy] autorelease];
}

@end
