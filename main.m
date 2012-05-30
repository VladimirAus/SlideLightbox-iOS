/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "RollItem.h"
#import "SlideItem.h"

#define COOKBOOK_PURPLE_COLOR    [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR)     [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] 

#pragma mark -
#pragma mark TestBedViewController
@interface SlideViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    NSManagedObjectContext *context;
    NSFetchedResultsController *fetchedResultsController;
    RollItem *selectedRoll;
}
@end

@implementation SlideViewController
- (void) performFetch
{
    // Init a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SlideItem" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"roll == %@", selectedRoll];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchBatchSize:100]; // more than needed for this example
    
    // Apply an ascending sort for the items
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"notes" ascending:YES selector:nil];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:descriptors];
    
    // Init the fetched results controller
    NSError *error;
    //fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:@"sectionName" cacheName:nil];
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    fetchedResultsController.delegate = self;
    if (![fetchedResultsController performFetch:&error])    
        NSLog(@"Error: %@", [error localizedFailureReason]);
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
    [self setBarButtonItems];
}

#pragma mark Table Sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    //return [[fetchedResultsController sections] count];
    return 1;
}

/*
 - (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
 {
 // Return the title for a given section
 NSArray *titles = [fetchedResultsController sectionIndexTitles];
 if (titles.count <= section) return @"Error";
 return [titles objectAtIndex:section];
 }
 */

#pragma mark Items in Sections
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    //return [[[fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
    return [[fetchedResultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve or create a cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basic cell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"basic cell"];
    
    // Recover object from fetched results
    NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [managedObject valueForKey:@"notes"];
    
    cell.accessoryType = [managedObject valueForKey:@"pass"] ?
        UITableViewCellAccessoryCheckmark :
        UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = (cell.accessoryType == UITableViewCellAccessoryNone) ?
        UITableViewCellAccessoryCheckmark :
        UITableViewCellAccessoryNone;
    
    
    SlideItem *item = (SlideItem *)[fetchedResultsController objectAtIndexPath:indexPath];
    item.pass = [NSNumber numberWithBool:(cell.accessoryType == UITableViewCellAccessoryCheckmark)];
    
    // save the new item
    NSError *error; 
    if (![context save:&error]) NSLog(@"Error: %@", [error localizedFailureReason]);
    
    //[self performFetch];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return NO;     // no reordering allowed
}

#pragma mark Data
- (void) setBarButtonItems
{
    // left item is always add
    self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemAdd, @selector(add));
    
    /*
    // right (edit/done) item depends on both edit mode and item count
    int count = [[fetchedResultsController fetchedObjects] count];
    if (self.tableView.isEditing)
        self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemDone, @selector(leaveEditMode));
    else
        self.navigationItem.rightBarButtonItem =  count ? SYSBARBUTTON(UIBarButtonSystemItemEdit, @selector(enterEditMode)) : nil;
     */
}

-(void)enterEditMode
{
    // Start editing
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.tableView setEditing:YES animated:YES];
    [self setBarButtonItems];
}

-(void)leaveEditMode
{
    // finish editing
    [self.tableView setEditing:NO animated:YES];
    [self setBarButtonItems];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // delete request
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        NSError *error = nil;
        [context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
        if (![context save:&error]) NSLog(@"Error: %@", [error localizedFailureReason]);
    }
    
    [self performFetch];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) return;
    
    NSString *rollItem = [alertView textFieldAtIndex:0].text;
    if (!rollItem || rollItem.length == 0) return;
    
    SlideItem *item = (SlideItem *)[NSEntityDescription insertNewObjectForEntityForName:@"SlideItem" inManagedObjectContext:context];
    item.notes = rollItem;
    item.pass = [NSNumber numberWithBool:NO];
    item.roll = selectedRoll;
    
    // save the new item
    NSError *error; 
    if (![context save:&error]) NSLog(@"Error: %@", [error localizedFailureReason]);
    
    [self performFetch];
}

- (void) add
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Add slide notes" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av show];
}

/*
- (void) initCoreData
{
    NSError *error;
    
    // Path to sqlite file. 
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/todo.sqlite"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    // Init the model, coordinator, context
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) 
        NSLog(@"Error: %@", [error localizedFailureReason]);
    else
    {
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:persistentStoreCoordinator];
    }
}
 */

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    //self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
    
    //[self initCoreData];
    [self performFetch];
    [self setBarButtonItems];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)setRoll:(RollItem *)roll
{
    selectedRoll = roll;
}

- (void)setContext:(NSManagedObjectContext *)_context
{
    context = _context;
}

@end

#pragma mark -
#pragma mark TestBedViewController
@interface TestBedViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    NSManagedObjectContext *context;
    NSFetchedResultsController *fetchedResultsController;
}
@end

@implementation TestBedViewController
- (void) performFetch
{
    // Init a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RollItem" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:100]; // more than needed for this example
    
    // Apply an ascending sort for the items
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:nil];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:descriptors];
    
    // Init the fetched results controller
    NSError *error;
    //fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:@"sectionName" cacheName:nil];
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    fetchedResultsController.delegate = self;
    if (![fetchedResultsController performFetch:&error])    
        NSLog(@"Error: %@", [error localizedFailureReason]);
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
    [self setBarButtonItems];
}

#pragma mark Table Sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    //return [[fetchedResultsController sections] count];
    return 1;
}

/*
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    // Return the title for a given section
    NSArray *titles = [fetchedResultsController sectionIndexTitles];
    if (titles.count <= section) return @"Error";
    return [titles objectAtIndex:section];
}
 */

#pragma mark Items in Sections
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    //return [[[fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
    return [[fetchedResultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve or create a cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basic cell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"basic cell"];
    
    // Recover object from fetched results
    NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [managedObject valueForKey:@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
    // some action here
    SlideViewController *svc = [[SlideViewController alloc] init];
    [svc setContext:context];
    [svc setRoll:[fetchedResultsController objectAtIndexPath:indexPath]];
    [self.navigationController pushViewController:svc animated:YES];
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return NO;     // no reordering allowed
}

#pragma mark Data
- (void) setBarButtonItems
{
    // left item is always add
    self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemAdd, @selector(add));
    
    // right (edit/done) item depends on both edit mode and item count
    int count = [[fetchedResultsController fetchedObjects] count];
    if (self.tableView.isEditing)
        self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemDone, @selector(leaveEditMode));
    else
        self.navigationItem.leftBarButtonItem =  count ? SYSBARBUTTON(UIBarButtonSystemItemEdit, @selector(enterEditMode)) : nil;
}

-(void)enterEditMode
{
    // Start editing
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.tableView setEditing:YES animated:YES];
    [self setBarButtonItems];
}

-(void)leaveEditMode
{
    // finish editing
    [self.tableView setEditing:NO animated:YES];
    [self setBarButtonItems];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // delete request
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        NSError *error = nil;
        [context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
        if (![context save:&error]) NSLog(@"Error: %@", [error localizedFailureReason]);
    }
    
    [self performFetch];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) return;
    
    NSString *rollItem = [alertView textFieldAtIndex:0].text;
    if (!rollItem || rollItem.length == 0) return;
    
    RollItem *item = (RollItem *)[NSEntityDescription insertNewObjectForEntityForName:@"RollItem" inManagedObjectContext:context];
    item.title = rollItem;
    item.sectionName = [[rollItem substringToIndex:1] uppercaseString];
    
    // save the new item
    NSError *error; 
    if (![context save:&error]) NSLog(@"Error: %@", [error localizedFailureReason]);
    
    [self performFetch];
}

- (void) add
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Add roll" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av show];
}

- (void) initCoreData
{
    NSError *error;
    
    // Path to sqlite file. 
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/todo.sqlite"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    // Init the model, coordinator, context
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) 
        NSLog(@"Error: %@", [error localizedFailureReason]);
    else
    {
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:persistentStoreCoordinator];
    }
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
    
    [self initCoreData];
    [self performFetch];
    [self setBarButtonItems];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
}
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
    [application setStatusBarHidden:YES];
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    window.rootViewController = nav;
    [window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}