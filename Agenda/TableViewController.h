//
//  TableViewController.h
//  Agenda
//
//  Created by Kaches on 2/6/13.
//  Copyright (c) 2013 Kaches. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "Internal.h"
#import "DetailViewController.h"

@interface TableViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource>
{
    
}
-(void)UpdateContactNames;

- (IBAction)Return:(id)sender;

@end
