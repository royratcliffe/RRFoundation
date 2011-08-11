// RRFoundation RRAppSupportFolder.m
//
// Copyright © 2008–2010, Roy Ratcliffe, Pioneering Software, United Kingdom
// All rights reserved
//
//------------------------------------------------------------------------------

#import "RRAppSupportFolder.h"

NSString *const kRRAppSupportFolderErrorDomain = @"uk.co.pioneeringsoftware.RRAppSupportFolderError";

NSString *RRAppSupportFolderPathForAppName(NSString *appName, NSError **outError)
{
	//	NSApplicationSupportDirectory=14
	//		(application support folder)
	//			Library/Application Support
	//
	//	NSUserDomainMask=1
	//		(user's home folder for personal items)
	//			~
	//
	NSArray *folderPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	
	// diagnostics
	if ([folderPaths count] == 0)
	{
		if (outError)
		{
			*outError = [NSError errorWithDomain:kRRAppSupportFolderErrorDomain code:kRRAppSupportFolderUserDirectoryNotFoundError userInfo:nil];
		}
		return nil;
	}
	
	return [[folderPaths objectAtIndex:0] stringByAppendingPathComponent:appName];
}

#if MAC_OS_X_VERSION_10_6 <= MAC_OS_X_VERSION_MAX_ALLOWED

NSURL *RRAppSupportFolderURLForAppName(NSString *appName, NSError **outError)
{
	NSURL *appSupportFolderURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:outError];
	
	// diagnostics
	if (appSupportFolderURL == nil)
	{
		return nil;
	}
	
	return [appSupportFolderURL URLByAppendingPathComponent:appName];
}

#endif
