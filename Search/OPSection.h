//
//  OPSection.h
//  Search
//
//  Created by Oleg Pochtovy on 20.01.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPSection : NSObject

@property (strong, nonatomic) NSString *sectionName;
@property (strong, nonatomic) NSMutableArray *itemsArray;

@end
