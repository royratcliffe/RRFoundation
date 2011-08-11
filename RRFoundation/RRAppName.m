// RRFoundation RRAppName.m
//
// Copyright © 2008, Roy Ratcliffe, Pioneering Software, United Kingdom
// All rights reserved
//
//------------------------------------------------------------------------------

#import "RRAppName.h"

NSString *RRAppName()
{
	// see Technical Q&A QA1544
	
	// Some users enable "Show all filename extensions" in Finder. With this
	// option, the app name becomes AppName.app rather than just AppName. Remove
	// the app extension when creating the Application Support folder so that
	// the support folder does not also carry the app extension.
	
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	return [[[NSFileManager defaultManager] displayNameAtPath:bundlePath] stringByDeletingPathExtension];
}
