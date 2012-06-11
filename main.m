/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "RollItem.h"
#import "SlideItem.h"

#define COOKBOOK_PURPLE_COLOR    [UIColor colorWithRed:0.21392f green:0.18607f blue:0.60176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR)     [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] 
#define IS_IPHONE			(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#pragma mark -
#pragma mark TestBedViewController
@interface SlideViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIPickerViewDelegate, UIActionSheetDelegate, UIPickerViewDataSource>

{
    NSManagedObjectContext *context;
    NSFetchedResultsController *fetchedResultsController;
    RollItem *selectedRoll;
}
@end

@interface LightboxViewController : UIViewController
{
    UISlider *slider;
    float previousValue;
}
@end

@implementation LightboxViewController

- (void) updateBg: (UISlider *) aSlider
{
    self.view.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:aSlider.value];
}

- (void) loadView
{
    
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
   
    // Set global UISlider appearance attributes
    [[UISlider appearance] setMinimumTrackTintColor:[UIColor blackColor]];
    [[UISlider appearance] setMaximumTrackTintColor:[UIColor grayColor]];
    
    // Create slider
	slider = [[UISlider alloc] initWithFrame:(CGRect){.size=CGSizeMake(200.0f, 40.0f)}];
    //[slider setThumbImage:simpleThumb() forState:UIControlStateNormal];
    slider.minimumValue = 0.5f;
    slider.maximumValue = 1.0f;
	slider.value = 1.0f;
    
	// Create the callbacks for touch, move, and release
	//[slider addTarget:self action:@selector(startDrag:) forControlEvents:UIControlEventTouchDown];
	[slider addTarget:self action:@selector(updateBg:) forControlEvents:UIControlEventValueChanged];
	//[slider addTarget:self action:@selector(endDrag:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
	
	// Present the slider
	[self.view addSubview:slider];
	//[self performSelector:@selector(updateThumb:) withObject:slider afterDelay:0.1f];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:
    (UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self dismissModalViewControllerAnimated:YES];
}
@end

@interface SlideEditViewController : UIViewController
{
    UISlider *slider;
    float previousValue;
}
@end

@implementation SlideEditViewController

- (void) updateBg: (UISlider *) aSlider
{
    self.view.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:aSlider.value];
}

- (void) loadView
{
    
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemAdd, @selector(save:));
    self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemAdd, @selector(cancel));
    
    
    // Create slider
	//UILabel *lblSubject = [[UILabel alloc] initWithFrame:(CGRect){.size=CGSizeMake(200.0f, 20.0f)}];
    UILabel *lblSubject = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 20.0, 200.0f, 20.0f)];
    lblSubject.text = @"Subject";
    UILabel *lblFrame = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 50.0, 200.0f, 20.0f)];
    lblFrame.text = @"Frame";
    UILabel *lblIso = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 80.0, 200.0f, 20.0f)];
    lblIso.text = @"ISO";
    UILabel *lblF = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 110.0, 200.0f, 20.0f)];
    lblF.text = @"F";
    
    UISlider *slIso = [[UISlider alloc] initWithFrame:
                         CGRectMake(100.0, 80.0, 200.0f, 20.0f)];
    UISlider *slF = [[UISlider alloc] initWithFrame:
                       CGRectMake(100.0, 110.0, 200.0f, 20.0f)];
    
    //[slider setThumbImage:simpleThumb() forState:UIControlStateNormal];
    //slider.minimumValue = 0.5f;
    //slider.maximumValue = 1.0f;
	//slider.value = 1.0f;
    
	// Create the callbacks for touch, move, and release
	//[slider addTarget:self action:@selector(startDrag:) forControlEvents:UIControlEventTouchDown];
	//[slider addTarget:self action:@selector(updateBg:) forControlEvents:UIControlEventValueChanged];
	//[slider addTarget:self action:@selector(endDrag:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
	
	// Present the slider
    [self.view addSubview:lblFrame];
	[self.view addSubview:lblSubject];
    [self.view addSubview:lblIso];
	[self.view addSubview:lblF];
    [self.view addSubview:slIso];
	[self.view addSubview:slF];
	//[self performSelector:@selector(updateThumb:) withObject:slider afterDelay:0.1f];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self dismissModalViewControllerAnimated:YES];
}
@end

@implementation SlideViewController


// Setting values
- (NSArray *)getArrayISO
{
    return [@"25/50/100/125/200/400/800/1200" componentsSeparatedByString: @"/"];
}

- (NSArray *)getArrayShutterSpeed
{
    return [@"1*1/30*1/60*1/250*1/500" componentsSeparatedByString: @"*"];
}

- (NSArray *)getArrayApperature
{
    return [@"2.0/2.8/4.5/5.6/8.0/11.0/16.0/22.0" componentsSeparatedByString: @"/"];
}

- (NSArray *)getArrayMode
{
    return [@"A/S/M/P" componentsSeparatedByString: @"/"];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 3; // three columns
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	//return 20; // twenty items per column
    switch (component) {
        case 0:
            return [[self getArrayShutterSpeed] count];
            break;
        case 1:
            return [[self getArrayApperature] count];
            break;
        case 2:
            return [[self getArrayMode] count];
            break;
    }
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	//return [NSString stringWithFormat:@"%@-%d", component == 1 ? @"R" : @"L", row];
    
    switch (component) {
        case 0:
            return [[self getArrayShutterSpeed] objectAtIndex:row];
            break;
        case 1:
            return [[self getArrayApperature] objectAtIndex:row];
            break;
        case 2:
            return [[self getArrayMode] objectAtIndex:row];
            break;
    }
    
    return @"";
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIPickerView *pickerView = (UIPickerView *)[actionSheet viewWithTag:101];
	self.title = [NSString stringWithFormat:@"L%d-R%d-L%d", [pickerView selectedRowInComponent:0], [pickerView selectedRowInComponent:1], [pickerView selectedRowInComponent:2]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	self.title = [NSString stringWithFormat:@"L%d-R%d-L%d", [pickerView selectedRowInComponent:0], [pickerView selectedRowInComponent:1], [pickerView selectedRowInComponent:2]];
}

- (void) action: (id) sender
{
	
	// Establish enough space for the picker
	NSString *title = @"Bam!\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
	/*
    if (IS_IPHONE)
		title = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n" : @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
    */
    
	// Create the base action sheet
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save", nil];
    
    if (IS_IPHONE)
        [actionSheet showInView:self.view];
    else
        [actionSheet showFromBarButtonItem:sender animated:NO];
	
	// Build the picker
	UIPickerView *pickerView = [[UIPickerView alloc] init];
	pickerView.tag = 101;
	pickerView.delegate = self;
	pickerView.dataSource = self;
	pickerView.showsSelectionIndicator = YES;
    
	// If working with an iPad, adjust the frames as needed
	if (!IS_IPHONE)
	{
		pickerView.frame = CGRectMake(0.0f, 0.0f, 272.0f, 216.0f);
		CGPoint center = actionSheet.center;
		actionSheet.frame = CGRectMake(0.0f, 40.0f, 272.0f, 253.0f);
		actionSheet.center = center;
	}
	
	// Embed the picker
    UILabel *lblSubject = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 220.0f, 272.0f, 40.0f)];
    lblSubject.text = @"\t\t\tShutter\t\t\t\t\t\t\t\t\tApperture\t\t\t\t\t\tMode";
    [actionSheet addSubview:lblSubject];
    
    
	[actionSheet addSubview:pickerView];
}

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
    
    /*
    cell.accessoryType = [managedObject valueForKey:@"pass"] ?
        UITableViewCellAccessoryCheckmark :
        UITableViewCellAccessoryNone;
    */
    
    cell.accessoryType =
        UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    /*
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = (cell.accessoryType == UITableViewCellAccessoryNone) ?
        UITableViewCellAccessoryCheckmark :
        UITableViewCellAccessoryNone;
    
    
    SlideItem *item = (SlideItem *)[fetchedResultsController objectAtIndexPath:indexPath];
    item.pass = [NSNumber numberWithBool:(cell.accessoryType == UITableViewCellAccessoryCheckmark)];
    
    // save the new item
    NSError *error; 
    if (![context save:&error]) NSLog(@"Error: %@", [error localizedFailureReason]);
    */
    /*
    //[self performFetch];
    
    SlideEditViewController *svc = [[SlideEditViewController alloc] init];
    //[svc setContext:context];
    //[svc setRoll:[fetchedResultsController objectAtIndexPath:indexPath]];
    [self.navigationController pushViewController:svc animated:YES];
    
    //self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
    */
    [self action:[tableView cellForRowAtIndexPath:indexPath]];
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
    //self.navigationItem.title = [NSString stringWithFormat:@"Slides: %@", selectedRoll.title];
    
    // Create the segmented control
    NSArray *buttonNames = [NSArray arrayWithObjects:
                            @"One", @"Lightbox", nil];
    UISegmentedControl* segmentedControl = [[UISegmentedControl alloc]
                                            initWithItems:buttonNames];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.momentary = YES;
    [segmentedControl addTarget:self action:@selector(segmentAction:)
               forControlEvents:UIControlEventValueChanged];
    
    // Add it to the navigation bar
    self.navigationItem.titleView = segmentedControl;
    
    /*
    // right (edit/done) item depends on both edit mode and item count
    int count = [[fetchedResultsController fetchedObjects] count];
    if (self.tableView.isEditing)
        self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemDone, @selector(leaveEditMode));
    else
        self.navigationItem.rightBarButtonItem =  count ? SYSBARBUTTON(UIBarButtonSystemItemEdit, @selector(enterEditMode)) : nil;
     */
}

-(void) segmentAction: (UISegmentedControl *) segmentedControl
{
    if (segmentedControl.selectedSegmentIndex == 1) {
        
        LightboxViewController *lvc = [[LightboxViewController alloc] init];
        lvc.modalPresentationStyle = UIModalTransitionStyleFlipHorizontal;
        [self.navigationController presentModalViewController:
            lvc animated:YES];
    }
    //[(UITextView *)self.view setText:segmentNumber];
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
    
    cell.accessoryType =
        UITableViewCellAccessoryDetailDisclosureButton;
    
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
    self.navigationItem.title = @"My Rolls";
    
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