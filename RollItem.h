//
//  ToDoItem.h
//  HelloWorld
//
//  Created by Erica Sadun on 8/24/09.
//  Copyright 2009 Up To No Good, Inc.. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface RollItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * sectionName;

@end



