//
//  TableViewController.m
//  Agenda
//
//  Created by Kaches on 2/6/13.
//  Copyright (c) 2013 Kaches. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController
{
    NSMutableArray *tableDataNames;
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//Method created to update the internar status of the tableDataNames. It executes a query to get al the names in the database
-(void)UpdateContactNames
{
    tableDataNames = [[NSMutableArray alloc] init];
    
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT name FROM contacts"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                [tableDataNames addObject:[[NSString alloc]
                                           initWithUTF8String:
                                           (const char *) sqlite3_column_text(statement, 0)]];
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_close(contactDB);
    }
}

//Fucntion added from the delegate to add a title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Contacts";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //When the form loads update the status of the tableDataNames
    [self UpdateContactNames];
    
    self.navigationItem.title = @"List of users on Agenda";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of elements in table
    return [tableDataNames count ];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
    }
    
    //Add the arrow on the right of the cell
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    
    //Set the cell text value
    cell.textLabel.text = [tableDataNames objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = @"";
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        const char *dbpath = [databasePath UTF8String];
        sqlite3_stmt    *statement;
        
        //Open the database
        if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
        {
            //Create the query string
            NSString *querySQL = [NSString stringWithFormat:
                                  @"delete from contacts where name = \"%@\"",[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
            const char *query_stmt = [querySQL UTF8String];
            
            //Execute query
            if (sqlite3_prepare_v2(contactDB,query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    //If contact was deleted from database then update the tableDataNames
                    [self UpdateContactNames];
                }
                
                sqlite3_finalize(statement);
            }
            sqlite3_close(contactDB);
        }
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Navigation logic may go here. Create and push another view controller.
    
    //TODO 
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:navController animated:YES];
     
}

- (IBAction)Return:(id)sender {
   
}
@end
