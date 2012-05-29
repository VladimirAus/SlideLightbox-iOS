//
//  SlideItem.h
//  HelloWorld
//
//  Created by Vladimir Roudakov on 30/05/12.
//  Copyright (c) 2012 Tomato Elephant Studio. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "RollItem.h"

@interface SlideItem : NSManagedObject  
{
}

@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * pass;
@property (nonatomic, retain) RollItem * roll;

@end
