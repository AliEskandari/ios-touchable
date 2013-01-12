//
//  FilterScreen.m
//  touchMe
//
//  Created by Ali Eskandari on 1/8/13.
//  Copyright (c) 2013 Marin Todorov. All rights reserved.
//

#import "FilterScreen.h"

@interface FilterScreen () {
	DataSource *dataSource;
}
@end

@implementation FilterScreen

@synthesize backBtn;
@synthesize addFilterBtn;
@synthesize tableView;
@synthesize filterPicker;
@synthesize filterList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


# pragma mark - ViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Setting up navigation bar
 	UIImage *navigationBarBackground = [UIImage imageNamed:@"menubar_no_title.png"];
	[self.navigationController.navigationBar setBackgroundImage:navigationBarBackground forBarMetrics:UIBarMetricsDefault];
	NSDictionary *titleBarAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, [UIColor blackColor], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset, [UIFont fontWithName:@"Segoe WP Black" size:18], UITextAttributeFont, nil];
	self.navigationController.navigationBar.titleTextAttributes = titleBarAttributes;
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(EditTable:)];
	self.navigationItem.rightBarButtonItem = editButton;
	[self.navigationController setNavigationBarHidden:NO];
	
	// setting up toolbar
	self.navigationController.toolbarHidden = YES;
	[self.navigationController.toolbar setBackgroundImage:navigationBarBackground forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
	
	// setting up data source
	dataSource = [[DataSource alloc] init];
	
	// setting up filter picker
	CGRect pickerFrame = CGRectMake(0, 156, 320, 0);
	filterPicker = [[MyPickerView alloc] initWithFrame:pickerFrame];
	filterList = [[NSMutableArray alloc] init];
	filterPicker.hidden = YES;
	filterPicker.source = dataSource.filters;
	filterPicker.delegate = self;
	[self.view insertSubview:filterPicker aboveSubview:tableView];
	
	// set up tableView
	tableView.dataSource = self;
	tableView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if ([self.tableView isEditing]) [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
	
	for (NSInteger sect = 0; sect < [filterList count]; sect ++) {
		UITableViewCell* cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:sect]];
		if ([cell isMemberOfClass:[SexCell class]])
		{
			SexCell *sexCell = (SexCell*) cell;
			NSDictionary* sexDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:sexCell.segment.selectedSegmentIndex],[NSNumber numberWithInteger:cell.tag], nil];
			filterList[sect] = sexDict;
		}
		else if ([cell isMemberOfClass:[AgeCell class]])
		{
			AgeCell *ageCell = (AgeCell*) cell;
			NSDictionary* ageDict = [[NSDictionary alloc] initWithObjectsAndKeys:ageCell.age1TextField.text, [NSNumber numberWithInteger:cell.tag], ageCell.age2TextField.text, [NSNumber numberWithInteger:-1], nil];
			filterList[sect] = ageDict;
		}
		else if ([cell isMemberOfClass:[SegueCell class]])
		{
			SegueCell *segueCell = (SegueCell*) cell;
			NSDictionary* segueDict = [[NSDictionary alloc] initWithObjectsAndKeys:segueCell.detailLabel.text,[NSNumber numberWithInteger:cell.tag], nil];
			filterList[sect] = segueDict;
		}
	}
	
	[[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"setFilters", @"command", filterList, @"filterList", [[API sharedInstance].user objectForKey:@"IdUser"], @"IdUser", nil] onCompletion:^(NSDictionary *json) {
			[super viewWillDisappear:animated];
	}];
}

- (void)viewDidUnload {
	[self setBackBtn:nil];
	[self setAddFilterBtn:nil];
	[self setTableView:nil];
	[super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [filterList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *cellDict = [filterList objectAtIndex:indexPath.section];
	NSInteger cellId = [[[cellDict allKeys] objectAtIndex:0] integerValue];
	
	static NSString *CellIdentifier;
	UITableViewCell *cell;
	switch (cellId) {
		case 0:
		{
			CellIdentifier = @"SexCell";
			cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
			if (cell == nil) cell = [[SexCell alloc] init];
		}
			break;
		case 1:
		{
			CellIdentifier = @"AgeCell";
			cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
			if (cell == nil) cell = [[AgeCell alloc] init];
		}
			break;
		case 2: 
		case 3: 
		case 4: 
		case 5: 
		{
			CellIdentifier = @"SegueCell";
			cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
			if (cell == nil) cell = [[SegueCell alloc] init];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
			break;
		default:
			break;
	}
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.textLabel.font = [UIFont fontWithName:@"Segoe WP Black" size:16];
	cell.textLabel.shadowColor = [UIColor blackColor];
	cell.textLabel.shadowOffset = CGSizeMake(0, 1);
	UIView *selectionColor = [[UIView alloc] init];
	selectionColor.backgroundColor = [UIColor colorWithRed:(255.0/255.0) green:(51.0/255.0) blue:(21.0/255.0) alpha:1];
	cell.selectedBackgroundView = selectionColor;
	
	NSDictionary *cellDict = [filterList objectAtIndex:indexPath.section];
	NSInteger cellId = [[[cellDict allKeys] objectAtIndex:0] integerValue];
	
	switch (cellId) {
		case 1:
		{
			AgeCell* ageCell = (AgeCell*) cell;
			ageCell.toLabel.font = [UIFont fontWithName:@"Segoe WP Black" size:14];
		}
			break;
		case 2:
		{
			SegueCell* countryCell = (SegueCell*) cell;
			countryCell.textLabel.text = @"Country";
			countryCell.detailLabel.font = [UIFont fontWithName:@"Segoe WP" size:18];
		}
			break;
		case 3:
		{
			SegueCell* stateCell = (SegueCell*) cell;
			stateCell.textLabel.text = @"State";
			stateCell.detailLabel.font = [UIFont fontWithName:@"Segoe WP" size:18];
		}
			break;
			
		case 4:
		{
			SegueCell* cityCell = (SegueCell*) cell;
			cityCell.textLabel.text = @"City";
			cityCell.detailLabel.font = [UIFont fontWithName:@"Segoe WP" size:18];
		}
			break;
		case 5:
		{
			SegueCell* schoolCell = (SegueCell*) cell;
			schoolCell.textLabel.text = @"School";
			schoolCell.detailLabel.font = [UIFont fontWithName:@"Segoe WP" size:18];
		}
			break;
			
		default:
			break;
	}
	cell.tag = cellId;
	
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


// Override to support editing the table view.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		[filterList removeObjectAtIndex:indexPath.section];
        [aTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *cellDict = [filterList objectAtIndex:indexPath.section];
	NSInteger cellId = [[[cellDict allKeys] objectAtIndex:0] integerValue];
	
	if (cellId >= 2 && cellId <= 5) {
		[self performSegueWithIdentifier:@"ShowAutoComp" sender:[NSNumber numberWithInteger:indexPath.section]];
	}
	[aTableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UIPickerView delegate
-(NSString*)pickerView:(MyPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [pickerView.source objectAtIndex:row];
	
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	[filterList insertObject:[NSDictionary dictionaryWithObject:@"" forKey:[NSNumber numberWithInteger:row]] atIndex:0];
	pickerView.hidden = YES;
	[tableView beginUpdates];
	[tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
	[tableView endUpdates];
}



#pragma mark - My methods

- (IBAction)backBtnTapped:(id)sender {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addFilterBtnTapped:(id)sender {
	[filterPicker setHidden:NO];
}

- (IBAction) EditTable:(id)sender{
	if (self.editing)
	{
		[super setEditing:NO animated:NO];
		[self.tableView setEditing:NO animated:NO];
		[filterPicker setHidden:YES];
		[self.navigationController setToolbarHidden:YES animated:YES];
		[self.tableView reloadData];
		[self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
		[self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
	}
	else
	{
		[super setEditing:YES animated:YES];
		[self.tableView setEditing:YES animated:YES];
		[self.navigationController setToolbarHidden:NO animated:YES];
		[self.tableView reloadData];
		[self.navigationItem.rightBarButtonItem setTitle:@"Done"];
		[self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
	}
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(NSNumber*)sender{
	NSDictionary *cellDict = [filterList objectAtIndex:sender.integerValue];
	NSInteger cellId = [[[cellDict allKeys] objectAtIndex:0] integerValue];
	
	if ([@"ShowAutoComp" compare:segue.identifier] == NSOrderedSame) {
		AutoCompScreen* autoCompScreen = segue.destinationViewController;
		switch (cellId) {
			case 2:
				autoCompScreen.title = @"Country";
				autoCompScreen.tag = [sender integerValue];
				autoCompScreen.listContent = dataSource.countries;
				break;
			case 3:
				autoCompScreen.title = @"State";
				autoCompScreen.tag = [sender integerValue];
				autoCompScreen.listContent = dataSource.states;
				break;
			case 4:
				autoCompScreen.title = @"City";
				autoCompScreen.tag = [sender integerValue];
				autoCompScreen.listContent = dataSource.cities;
				break;
			case 5:
				autoCompScreen.title = @"School";
				autoCompScreen.tag = [sender integerValue];
				autoCompScreen.listContent = dataSource.schools;
				break;
			default:
				break;
		}
		autoCompScreen.delegate = self;
	}
}

/* SAVE AND SET LABELS WITH CHOSEN COUNTRY, STATE, CITY, SCHOOL */
-(void)autoCompScreenDismissed:(NSString*)string tag:(NSInteger)tag
{
	SegueCell* cell = (SegueCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:tag]];
	cell.detailLabel.text = string;
}

@end
