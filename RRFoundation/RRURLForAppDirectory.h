// RRFoundation RRURLForAppDirectory.h
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

#import <Foundation/Foundation.h>

extern NSString *const RRURLForAppDirectoryErrorDomain;

enum
{
	kRRURLForAppDirectoryFoundFileError = 'ADff',
};

/*!
 * @brief Identifies, creating if necessary, an application-specific directory
 * in the user domain.
 *
 * @details The search path directory argument typically specifies library,
 * caches or application support; specifically, NSLibraryDirectory,
 * NSCachesDirectory or NSApplicationSupportDirectory respectively. These are in
 * fact the only places to which you can write application-specific files if you
 * want to submit your application to the Mac App Store. See Mac OS X developer
 * library, File-System Usage Requirements for the Mac App Store. The
 * appIdentifier corresponds to one of: your application's bundle identifer, its
 * name, or your company's name.
 *
 * The implementation uses file manager methods only available in OS X 10.6 or
 * above.
 */
NSURL *RRURLForAppDirectoryInUserDomain(NSSearchPathDirectory directory, NSString *appIdentifier, NSError **outError);
