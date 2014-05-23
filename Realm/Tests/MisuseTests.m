////////////////////////////////////////////////////////////////////////////
//
// TIGHTDB CONFIDENTIAL
// __________________
//
//  [2011] - [2014] TightDB Inc
//  All Rights Reserved.
//
// NOTICE:  All information contained herein is, and remains
// the property of TightDB Incorporated and its suppliers,
// if any.  The intellectual and technical concepts contained
// herein are proprietary to TightDB Incorporated
// and its suppliers and may be covered by U.S. and Foreign Patents,
// patents in process, and are protected by trade secret or copyright law.
// Dissemination of this information or reproduction of this material
// is strictly forbidden unless prior written permission is obtained
// from TightDB Incorporated.
//
////////////////////////////////////////////////////////////////////////////

#import "RLMTestCase.h"


@interface SimpleMisuseObject : RLMObject
@property (nonatomic, copy) NSString *stringCol;
@property (nonatomic, assign) NSInteger intCol;
@end

@implementation SimpleMisuseObject

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"stringCol" : @""};
}

@end


@interface MisuseTests : RLMTestCase

@end

@implementation MisuseTests


-(void)testMisuse
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    // Insert an object
    [realm beginWriteTransaction];
    SimpleMisuseObject *obj = [SimpleMisuseObject createInRealm:realm withObject:nil];
    obj.stringCol = @"stringVal";
    obj.intCol = 10;
    [realm commitWriteTransaction];
    
    
    XCTAssertThrows([SimpleMisuseObject createInRealm:realm withObject:nil], @"Outside write transaction");
    
    XCTAssertThrows([realm commitWriteTransaction], @"No write transaction to close");
    
    [realm beginWriteTransaction];
    XCTAssertThrows([realm beginWriteTransaction], @"Write transactino already in place");
    [realm commitWriteTransaction];
    
    XCTAssertThrows([realm rollbackWriteTransaction], @"No write transaction to rool-back");

    XCTAssertThrows([realm deleteObject:obj], @"Outside writetransaction");
}


@end
