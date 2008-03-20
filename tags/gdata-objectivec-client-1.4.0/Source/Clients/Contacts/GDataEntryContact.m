/* Copyright (c) 2008 Google Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

//
//  GDataEntryContact.m
//

#define GDATAENTRYCONTACT_DEFINE_GLOBALS 1
#import "GDataEntryContact.h"


@implementation GDataEntryContact

+ (NSDictionary *)contactNamespaces {
  NSMutableDictionary *namespaces;
  
  namespaces = [NSMutableDictionary dictionaryWithObject:kGDataNamespaceContact
                                                  forKey:kGDataNamespaceContactPrefix];
  
  [namespaces addEntriesFromDictionary:[GDataEntryBase baseGDataNamespaces]];
  
  return namespaces;
}

+ (GDataEntryContact *)contactEntryWithTitle:(NSString *)title {
  GDataEntryContact *obj = [[[GDataEntryContact alloc] init] autorelease];
  
  [obj setNamespaces:[GDataEntryContact contactNamespaces]];
  
  [obj setTitleWithString:title];
  return obj;
}

#pragma mark -

+ (void)load {
  [GDataObject registerEntryClass:[self class]
            forCategoryWithScheme:kGDataCategoryScheme 
                             term:kGDataCategoryContact];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  // ContactEntry extensions
  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataOrganization class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataEmail class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataIM class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhoneNumber class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPostalAddress class]];  
}

- (id)init {
  self = [super init];
  if (self) {
    GDataCategory *category = [GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                           term:kGDataCategoryContact];
    [self addCategory:category];
  }
  return self;
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  if ([[self organizations] count] > 0) {
    [self addToArray:items objectDescriptionIfNonNil:[self organizations] withName:@"organization"];
  }
  if ([[self emailAddresses] count] > 0) {
    [self addToArray:items objectDescriptionIfNonNil:[self emailAddresses] withName:@"email"];
  }
  if ([[self phoneNumbers] count] > 0) {
    [self addToArray:items objectDescriptionIfNonNil:[self phoneNumbers] withName:@"phone"];
  }
  if ([[self IMAddresses] count] > 0) {
    [self addToArray:items objectDescriptionIfNonNil:[self IMAddresses] withName:@"IM"];
  }
  if ([[self postalAddresses] count] > 0) {
    [self addToArray:items objectDescriptionIfNonNil:[self postalAddresses] withName:@"postal"];
  }  
  return items;
}


#pragma mark -

// The Focus UI does not happily handle empty strings, so we'll force those
// to be nil
- (void)setTitle:(GDataTextConstruct *)theTitle {
  if ([[theTitle stringValue] length] == 0) {
    theTitle = nil; 
  }
  [super setTitle:theTitle];
}

- (void)setTitleWithString:(NSString *)str {
  if ([str length] == 0) {
    [self setTitle:nil]; 
  } else {
    [super setTitleWithString:str]; 
  }
}

#pragma mark -

// routines to do the work for finding or setting the primary elements
// of the different extension classes

- (GDataObject *)primaryObjectForExtensionClass:(Class)class {
  
  NSArray *extns = [self objectsForExtensionClass:class];
  NSEnumerator *enumerator = [extns objectEnumerator];
  
  GDataObject *obj;
  
  while ((obj = [enumerator nextObject]) != nil) {
    if ([(id)obj isPrimary]) return obj;
  }
  return nil;
}

- (void)setPrimaryObject:(GDataObject *)newPrimaryObj
       forExtensionClass:(Class)class {
  NSArray *extns =  [self objectsForExtensionClass:class];
  NSEnumerator *enumerator = [extns objectEnumerator];
  GDataObject *obj;
  
  BOOL foundIt = NO;

  while ((obj = [enumerator nextObject]) != nil) {
    BOOL isPrimary = [newPrimaryObj isEqual:obj];
    [(id)obj setIsPrimary:isPrimary];
    
    if (isPrimary) foundIt = YES;
  }
  
  // if the object isn't already in the list, add it
  if (!foundIt && newPrimaryObj != nil) {
    [(id)newPrimaryObj setIsPrimary:YES];
    [self addObject:newPrimaryObj forExtensionClass:class];
  }
}

#pragma mark -

- (NSArray *)organizations {
  return [self objectsForExtensionClass:[GDataOrganization class]];
}

- (void)setOrganizations:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataOrganization class]];
}

- (void)addOrganization:(GDataOrganization *)obj {
  [self addObject:obj forExtensionClass:[obj class]];
}

- (GDataOrganization *)primaryOrganization {
  id obj = [self primaryObjectForExtensionClass:[GDataOrganization class]];
  return obj;
}

- (void)setPrimaryOrganization:(GDataOrganization *)obj {
  [self setPrimaryObject:obj forExtensionClass:[GDataOrganization class]];
}


- (NSArray *)emailAddresses {
  return [self objectsForExtensionClass:[GDataEmail class]];
}

- (void)setEmailAddresses:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataEmail class]];
}

- (void)addEmailAddress:(GDataEmail *)obj {
  [self addObject:obj forExtensionClass:[obj class]];
}

- (GDataEmail *)primaryEmailAddress {
  id obj = [self primaryObjectForExtensionClass:[GDataEmail class]];
  return obj;
}

- (void)setPrimaryEmailAddress:(GDataEmail *)obj {
  [self setPrimaryObject:obj forExtensionClass:[GDataEmail class]];
}


- (NSArray *)IMAddresses {
  return [self objectsForExtensionClass:[GDataIM class]];
}

- (void)setIMAddresses:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataIM class]];
}

- (GDataIM *)primaryIMAddress {
  id obj = [self primaryObjectForExtensionClass:[GDataIM class]];
  return obj;
}

- (void)setPrimaryIMAddress:(GDataIM *)obj {
  [self setPrimaryObject:obj forExtensionClass:[GDataIM class]];
}


- (void)addIMAddress:(GDataIM *)obj {
  [self addObject:obj forExtensionClass:[obj class]];
}

- (NSArray *)phoneNumbers {
  return [self objectsForExtensionClass:[GDataPhoneNumber class]];
}

- (void)setPhoneNumbers:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataPhoneNumber class]];
}

- (void)addPhoneNumber:(GDataPhoneNumber *)obj {
  [self addObject:obj forExtensionClass:[obj class]];
}

- (GDataPhoneNumber *)primaryPhoneNumber {
  id obj = [self primaryObjectForExtensionClass:[GDataPhoneNumber class]];
  return obj;
}

- (void)setPrimaryPhoneNumber:(GDataPhoneNumber *)obj {
  [self setPrimaryObject:obj forExtensionClass:[GDataPhoneNumber class]];
}


- (NSArray *)postalAddresses {
  return [self objectsForExtensionClass:[GDataPostalAddress class]];
}

- (void)setPostalAddresses:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataPostalAddress class]];
}

- (void)addPostalAddress:(GDataPostalAddress *)obj {
  [self addObject:obj forExtensionClass:[obj class]];
}

- (GDataPostalAddress *)primaryPostalAddress {
  id obj = [self primaryObjectForExtensionClass:[GDataPostalAddress class]];
  return obj;
}

- (void)setPrimaryPostalAddress:(GDataPostalAddress *)obj {
  [self setPrimaryObject:obj forExtensionClass:[GDataPostalAddress class]];
}

@end
