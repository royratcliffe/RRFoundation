// RRFoundation RRURLForAppDirectory.m
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

#import "RRURLForAppDirectory.h"

NSString *const kRRURLForAppDirectoryErrorDomain = @"uk.co.pioneeringsoftware.RRURLForAppDirectoryError";

NSURL *RRURLForAppDirectoryInUserDomain(NSSearchPathDirectory directory, NSString *appIdentifier, NSError **outError)
{
	// Note that asking -[NSFileManager URLsForDirectory:inDomains:] answers an
	// ordered array of directory URLs identifying the requested folders, where
	// folders in the user domain appear first in the array, folders in the
	// system domain appear last. Let us assume that there could be more than
	// one possibility. Try each one, from the first to the last, until
	// success. Success means either finding or creating the application
	// folder. Typically though, the array will contain just one element: the
	// one and only folder available in the user domain.
	NSError *error = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	for (NSURL *directoryURL in [fileManager URLsForDirectory:directory inDomains:NSUserDomainMask])
	{
		NSURL *appDirectoryURL = [directoryURL URLByAppendingPathComponent:appIdentifier];
		NSDictionary *resourceValues = [appDirectoryURL resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
		if (resourceValues == nil)
		{
			if ([error code] != NSFileReadNoSuchFileError || ![fileManager createDirectoryAtPath:[appDirectoryURL path] withIntermediateDirectories:YES attributes:nil error:outError])
			{
				continue;
			}
		}
		else if (![[resourceValues objectForKey:NSURLIsDirectoryKey] boolValue])
		{
			error = [NSError errorWithDomain:kRRURLForAppDirectoryErrorDomain code:999 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Expected to find a folder to store application-specific information but instead found a file (%@)", [appDirectoryURL path]] forKey:NSLocalizedDescriptionKey]];
			continue;
		}
		return appDirectoryURL;
	}
	if (outError)
	{
		*outError = error;
	}
	return nil;
}
