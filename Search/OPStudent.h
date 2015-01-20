//
//  OPStudent.h
//  Search
//
//  Created by Oleg Pochtovy on 20.01.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPStudent : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (assign, nonatomic) NSInteger yearOfBirth;
@property (strong, nonatomic) NSDate *birthDate;
@property (strong, nonatomic) NSString *monthDigit;

+ (OPStudent *)randomStudent;

@end
