//
//  OPSegmentedControlViewController.h
//  Search
//
//  Created by Oleg Pochtovy on 20.01.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OPSegmentedControlViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

// property searchBar to take a search text for method generateSectionsFromArray:withFilter:
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *sortingOrderControl;

- (IBAction)actionControl:(UISegmentedControl *)sender;


@end
