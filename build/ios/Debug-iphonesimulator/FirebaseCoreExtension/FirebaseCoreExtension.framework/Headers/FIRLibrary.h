/*
 * Copyright 2018 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef FIREBASECORE_FIRLIBRARY_H
#define FIREBASECORE_FIRLIBRARY_H

#ifndef FIRLibrary_h
#define FIRLibrary_h

#import <Foundation/Foundation.h>

@class FIRApp;
@class FIRComponent;

NS_ASSUME_NONNULL_BEGIN

/// Provide an interface to register a library for userAgent logging and availability to others.
NS_SWIFT_NAME(Library)
@protocol FIRLibrary

/// Returns one or more Components that will be registered in
/// FirebaseApp and participate in dependency resolution and injection.
+ (NSArray<FIRComponent *> *)componentsToRegister;

@end

NS_ASSUME_NONNULL_END

#endif /* FIRLibrary_h */

#endif  // FIREBASECORE_FIRLIBRARY_H
