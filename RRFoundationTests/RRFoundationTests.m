// RRFoundationTests RRFoundationTests.m
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

#import "RRFoundationTests.h"
#import "NSRegularExpression+RRFoundation.h"
#import "RRURLForAppDirectory.h"

@implementation RRFoundationTests

- (void)setUp
{
	appIdentifier = [@"uk.co.pioneeringsoftware.RRFoundation" retain];
	libraryPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] retain];
	cachesPath = [[libraryPath stringByAppendingPathComponent:@"Caches"] retain];
	appCachesPath = [[cachesPath stringByAppendingPathComponent:appIdentifier] retain];
}

- (void)tearDown
{
	[appIdentifier release];
	[libraryPath release];
	[cachesPath release];
	[appCachesPath release];
}

- (void)testRegularExpressions
{
	STAssertEqualObjects([[NSRegularExpression regularExpressionWithPattern:@"/(.?)" options:0 error:NULL] replaceMatchesInString:@"active/record/errors" replacementStringForResult:^NSString *(NSTextCheckingResult *result, NSString *inString, NSInteger offset) {
		return [@"::" stringByAppendingString:[[[result regularExpression] replacementStringForResult:result inString:inString offset:offset template:@"$1"] uppercaseString]];
	}], @"active::Record::Errors", nil);
}

- (void)testURLForDirectory
{
	NSError *error = nil;
	NSURL *appCachesURL = RRURLForAppDirectoryInUserDomain(NSCachesDirectory, appIdentifier, &error);
	STAssertEqualObjects([appCachesURL path], appCachesPath, nil);
	STAssertNil(error, @"%@", error);
}

- (void)testURLForDirectoryButInsteadFindAFile
{
	NSError *error = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:appCachesPath error:&error];
	STAssertTrue([fileManager createFileAtPath:appCachesPath contents:[NSData data] attributes:nil], nil);
	STAssertNil(RRURLForAppDirectoryInUserDomain(NSCachesDirectory, appIdentifier, &error), nil);
	STAssertEqualObjects([error domain], kRRURLForAppDirectoryErrorDomain, nil);
	STAssertEquals([error code], 999L, nil);
	STAssertTrue([fileManager removeItemAtPath:appCachesPath error:NULL], nil);
}

@end
