// RRFoundation RRAppSupportFolder.h
//
// Copyright © 2008–2010, Roy Ratcliffe, Pioneering Software, United Kingdom
// All rights reserved
//
//------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

extern NSString *const kRRAppSupportFolderErrorDomain;

enum
{
	kRRAppSupportFolderUserDirectoryNotFoundError = 'UDnf',
};

/*!
 * Asking for the path does not create the user application-support folder. It
 * assumes that the folder already exists. If not, the function answers nil and
 * sets up the given outError, output error.
 */
NSString *RRAppSupportFolderPathForAppName(NSString *appName, NSError **outError);

/*!
 * Asking for the URL differs because it does create the user application-
 * support folder if it does not already exist. However it does not create the
 * sub-folder as given by the appName argument. You must create that sub-folder
 * yourself.
 *
 * This function is not available before OS X 10.6 because the underlying
 * dependencies originate from that version of the operating system.
 */
NSURL *RRAppSupportFolderURLForAppName(NSString *appName, NSError **outError) AVAILABLE_MAC_OS_X_VERSION_10_6_AND_LATER;
