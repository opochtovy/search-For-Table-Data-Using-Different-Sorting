//
//  OPSegmentedControlViewController.m
//  Search
//
//  Created by Oleg Pochtovy on 20.01.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPSegmentedControlViewController.h"
#import "OPStudent.h"
#import "OPSection.h"

// here we create our custom data type for UISegmentedControl's index (value)
typedef enum {
    OPSortingOrderTypeBirthday, // by default 0
    OPSortingOrderTypeFirstName, // by default 1
    OPSortingOrderTypeLastName // by default 2
} OPSortingOrderType;

@interface OPSegmentedControlViewController()

@property (strong, nonatomic) NSArray *studentsArray;
@property (strong, nonatomic) NSArray *startStudentsArray;

@property (strong, nonatomic) NSMutableArray *sectionsArray; // array of sections (after grouping procedure)
@property (strong, nonatomic) NSOperationQueue *operationQueue;

+ (NSOperationQueue *)sharedOperationQueue;

@end

@implementation OPSegmentedControlViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.sortingOrderControl.selectedSegmentIndex = OPSortingOrderTypeBirthday; // start index for UISegmentedControl
    
    NSMutableArray *array = [NSMutableArray array];
    
    // here we generate a students array with a random number of students from 50 to 100
    for (int i = 0; i < (50 + arc4random() % 51); i++) {
        
        OPStudent *student = [OPStudent randomStudent];
        
        [array addObject:student];
    }
    
    self.startStudentsArray = array;
    
    // according to 3 segments of UISegmentedControl we have to get 3 arrays of sorting students inside
    
    // using NSSortDescriptor is quite convinient because it compares two objects by keys (properties of these objects). It's a key-value coding.
    NSSortDescriptor *monthSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"monthDigit" ascending:YES];
    NSSortDescriptor *lastNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSSortDescriptor *firstNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *birthdaySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"birthDate" ascending:YES];
    
    if (self.sortingOrderControl.selectedSegmentIndex == OPSortingOrderTypeBirthday) {
        
        // for this segment index students array is sorted first by month, then by last name and then by first name
        [array sortUsingDescriptors:@[monthSortDescriptor, lastNameSortDescriptor, firstNameSortDescriptor]];
        
    } else if (self.sortingOrderControl.selectedSegmentIndex == OPSortingOrderTypeFirstName) {
        
        // for this segment index students array is sorted first by first name, then by last name and then by birth date
        [array sortUsingDescriptors:@[firstNameSortDescriptor, lastNameSortDescriptor, birthdaySortDescriptor]];
        
    } else {
        
        // for this segment index students array is sorted first by last name, then by birth date and then by first name
        [array sortUsingDescriptors:@[lastNameSortDescriptor, birthdaySortDescriptor, firstNameSortDescriptor]];
        
    }
    
    self.studentsArray = array;
    
    // here we perform a method that will group our students depending on segment index of UISegmentedControl (0 - by month of birth date, 1 - by first name, 2 - by last name)
    if (self.sortingOrderControl.selectedSegmentIndex == OPSortingOrderTypeBirthday) {
        
        self.sectionsArray = [self generateBirthdaySectionsFromArray:self.studentsArray withFilter:self.searchBar.text];
        
    } else {
        
        self.sectionsArray = [self generateNameSectionsFromArray:self.studentsArray withFilter:self.searchBar.text];
        
    }
    
    self.searchBar.showsCancelButton = NO;
    
    self.operationQueue = [OPSegmentedControlViewController sharedOperationQueue];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods
// class method returns static (one instance for all objects of OPSegmentedControlViewController class) NSOperationQueue that is initialized during first call to that method
+ (NSOperationQueue *)sharedOperationQueue {
    static NSOperationQueue *operationQueue;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        operationQueue = [[NSOperationQueue alloc] init];
    });
    
    return operationQueue;
}

- (NSMutableArray *)generateSectionsFromArray:(NSArray *)array {
    
    NSMutableArray *sectionsArray = [NSMutableArray array];
    
    NSString *currentMonth = nil;
    
    for (OPStudent *student in array) {
        
        // here we get the property student.monthDigit from each student - if compared monthDigits are different then we create a new section
        OPSection *section = nil;
        
        if (![currentMonth isEqualToString:student.monthDigit]) {
            
            section = [[OPSection alloc] init];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMMM"]; // MM - month, mm - minutes, MM - month by digit, MMM - shorthand for month, MMMM - full month name, MMMMM - first letter of month
            NSString *birthMonthNameString = [dateFormatter stringFromDate:student.birthDate];
            section.sectionName = birthMonthNameString;
            
            section.itemsArray = [NSMutableArray array];
            
            currentMonth = student.monthDigit;
            
            // add this section in our sections array
            [sectionsArray addObject:section];
            
        } else {
            section = [sectionsArray lastObject];
        }
        
        // add the student in this section
        [section.itemsArray addObject:student];
    }
    
    return sectionsArray;
}

- (NSMutableArray *)generateBirthdaySectionsFromArray:(NSArray *)array withFilter:(NSString *)filterString {
    
    NSMutableArray *sectionsArray = [NSMutableArray array];
    
    NSString *currentMonth = nil;
    
    NSOperation *lastOperation = [self.operationQueue.operations lastObject];
    
    for (OPStudent *student in array) {
        
        // Cancel ([self.operationQueue cancelAllOperations]) doesn't cancel executing operation but it cancels all inactive operations in queue -> method cancel for NSOperation or cancelAllOperations for NSOperationQueue just changes the flag isCancelled -> we need to check in code the flag isCancelled for that operation during calculations to cancel that operation
        // here for each student in array during calculations we check if that operation has cancelled according to one more search filter (fresher than current)
        if (!lastOperation.isCancelled) {
            
            
            // in app we don't consider the case
            NSString *lowerCaseFirstName = [student.firstName lowercaseString];
            NSString *lowerCaseLastName = [student.lastName lowercaseString];
            NSString *lowerCaseFilterString = [filterString lowercaseString];
            
            // ([lowerCaseFirstName rangeOfString:lowerCaseFilterString].location == NSNotFound) - here we check for matches our filter with current string (first name or last name) in array of students, if NSNotFound then we go next
            // ([lowerCaseFilterString length] > 0) - here we exclude a null search string
            if ( ([lowerCaseFilterString length] > 0) && ([lowerCaseFirstName rangeOfString:lowerCaseFilterString].location == NSNotFound) && ([lowerCaseLastName rangeOfString:lowerCaseFilterString].location == NSNotFound) )  {
                // here we search for matches in first name and last name
                
                continue; // finish current iteration and go to the next iteration (next string in array)
            }
            
            OPSection *section = nil;
            
            if (![currentMonth isEqualToString:student.monthDigit]) {
                
                section = [[OPSection alloc] init];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MMMM"];
                NSString *birthMonthNameString = [dateFormatter stringFromDate:student.birthDate];
                section.sectionName = birthMonthNameString;
                
                section.itemsArray = [NSMutableArray array];
                
                currentMonth = student.monthDigit;
                
                [sectionsArray addObject:section];
                
            } else {
                
                section = [sectionsArray lastObject];
            }
            
            [section.itemsArray addObject:student];
            
        }
    }
    
    return sectionsArray;
    
}

- (NSMutableArray *)generateNameSectionsFromArray:(NSArray *)array withFilter:(NSString *)filterString {
    
    NSMutableArray *sectionsArray = [NSMutableArray array];
    
    NSString *currentLetter = nil;
    
    NSOperation *lastOperation = [self.operationQueue.operations lastObject];
    
    for (OPStudent *student in array) {
        
        // Cancel ([self.operationQueue cancelAllOperations]) doesn't cancel executing operation but it cancels all inactive operations in queue -> method cancel for NSOperation or cancelAllOperations for NSOperationQueue just changes the flag isCancelled -> we need to check in code the flag isCancelled for that operation during calculations to cancel that operation
        // here for each student in array during calculations we check if that operation has cancelled according to one more search filter (fresher than current)
        if (!lastOperation.isCancelled) {
            
            NSString *lowerCaseFirstName = [student.firstName lowercaseString];
            NSString *lowerCaseLastName = [student.lastName lowercaseString];
            NSString *lowerCaseFilterString = [filterString lowercaseString];
            
            if ( ([lowerCaseFilterString length] > 0) && ([lowerCaseFirstName rangeOfString:lowerCaseFilterString].location == NSNotFound) && ([lowerCaseLastName rangeOfString:lowerCaseFilterString].location == NSNotFound) )  {
                
                continue;
            }
            
            NSString *string;
            if (self.sortingOrderControl.selectedSegmentIndex == OPSortingOrderTypeFirstName) {
                
                string = student.firstName;
                
            } else {
                
                string = student.lastName;
                
            }
            
            NSString *firstLetter = [string substringToIndex:1];
            
            OPSection *section = nil;
            
            if (![currentLetter isEqualToString:firstLetter]) {
                
                section = [[OPSection alloc] init];
                
                section.sectionName = firstLetter;
                
                section.itemsArray = [NSMutableArray array];
                
                currentLetter = firstLetter;
                
                [sectionsArray addObject:section];
                
            } else {
                
                section = [sectionsArray lastObject];
            }
            
            [section.itemsArray addObject:student];
            
        }
        
    }
    
    return sectionsArray;
    
}

// using NSOperationQueue and checking for selectedSegment
- (void)generateSectionsInBackgroundFromArray:(NSArray *)array withFilter:(NSString *)filterString {
    
    // Cancel ([self.operationQueue cancelAllOperations]) doesn't cancel executing operation but it cancels all inactive operations in queue -> method cancel for NSOperation or cancelAllOperations for NSOperationQueue just changes the flag isCancelled -> we need to check in code the flag isCancelled for that operation during calculations to cancel that operation
    [self.operationQueue cancelAllOperations];
    
    __weak OPSegmentedControlViewController *weakSelf = self;
    
    [self.operationQueue addOperationWithBlock:^{
        
        NSMutableArray *sectionsArray;
        
        if (self.sortingOrderControl.selectedSegmentIndex == OPSortingOrderTypeBirthday) {
            
            sectionsArray = [weakSelf generateBirthdaySectionsFromArray:array withFilter:filterString];
            
        } else {
            
            sectionsArray = [weakSelf generateNameSectionsFromArray:array withFilter:filterString];
            
        }
        
        // as soon as we get sectionsArray we display the result
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.sectionsArray = sectionsArray;
            [weakSelf.tableView reloadData];
        });
        
    }];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.sectionsArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    OPSection *myClassSection = [self.sectionsArray objectAtIndex:section];
    return myClassSection.sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    OPSection *myClassSection = [self.sectionsArray objectAtIndex:section];
    return [myClassSection.itemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    OPSection *myClassSection = [self.sectionsArray objectAtIndex:indexPath.section];
    OPStudent *student = [myClassSection.itemsArray objectAtIndex:indexPath.row];
    
    if (self.sortingOrderControl.selectedSegmentIndex == OPSortingOrderTypeFirstName) {
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
        
        
    } else {
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", student.lastName, student.firstName];
        
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    
    NSString *birthDateString = [dateFormatter stringFromDate:student.birthDate];
    
    cell.detailTextLabel.text = birthDateString;
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (OPSection *section in self.sectionsArray) {
        
        NSString *shortSectionName;
        
        if (self.sortingOrderControl.selectedSegmentIndex == OPSortingOrderTypeBirthday) {
            
            shortSectionName = [section.sectionName substringToIndex:3]; // full month name is quite long that's why we'll use just first 3 letters of month names for indexBar
            
            
        } else {
            
            shortSectionName = [section.sectionName substringToIndex:1]; // 1 first letter of first name (or last name) for indexBar
            
        }
        
        [array addObject:shortSectionName];
    }
    
    return array;
}

#pragma mark - UISearchBarDelegate

// convinient method - Cancel Button appears with animation not at app's start but when we start to write search text in UISearchBar field
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:YES animated:YES];
}

// Cancel Button disappears with animation
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder]; // very important to resign first responder from searchbar
    [searchBar setShowsCancelButton:NO animated:YES];
}

// here we filter our students array
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    // the goal of this method is that as soon as the character in the searchBar changes we should do a search in our array for this new string
    [self generateSectionsInBackgroundFromArray:self.studentsArray withFilter:self.searchBar.text];
    
    [self.tableView reloadData]; // we need this line to display new sectionsArray in our table according to search filter
    
}

#pragma mark - Actions

- (IBAction)actionControl:(UISegmentedControl *)sender {
    
    NSSortDescriptor *monthSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"monthDigit" ascending:YES];
    NSSortDescriptor *lastNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSSortDescriptor *firstNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *birthdaySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"birthDate" ascending:YES];
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.startStudentsArray];
    
    if (self.sortingOrderControl.selectedSegmentIndex == OPSortingOrderTypeBirthday) {
        
        [array sortUsingDescriptors:@[monthSortDescriptor, lastNameSortDescriptor, firstNameSortDescriptor]];
        
    } else if (self.sortingOrderControl.selectedSegmentIndex == OPSortingOrderTypeFirstName) {
        
        [array sortUsingDescriptors:@[firstNameSortDescriptor, lastNameSortDescriptor, birthdaySortDescriptor]];
        
    } else {
        
        [array sortUsingDescriptors:@[lastNameSortDescriptor, birthdaySortDescriptor, firstNameSortDescriptor]];
        
    }
    
    self.studentsArray = array;
    
    if (self.sortingOrderControl.selectedSegmentIndex == OPSortingOrderTypeBirthday) {
        
        self.sectionsArray = [self generateBirthdaySectionsFromArray:self.studentsArray withFilter:self.searchBar.text];
        
    } else {
        
        self.sectionsArray = [self generateNameSectionsFromArray:self.studentsArray withFilter:self.searchBar.text];
        
    }
    
    [self.tableView reloadData]; // we need this line to display new sectionsArray in our table according to search filter
}
@end
