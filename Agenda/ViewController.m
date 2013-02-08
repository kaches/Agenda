//
//  ViewController.m
//  Agenda
//
//  Created by Kaches on 2/4/13.
//  Copyright (c) 2013 Kaches. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    NSString *docsDir;
    NSArray *dirPaths;
    
    //Add delegates
    _name.delegate = self;
    _address.delegate = self;
    _phone.delegate = self;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc]
                    initWithString: [docsDir stringByAppendingPathComponent:
                                     @"contacts.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, ADDRESS TEXT, PHONE TEXT)";
            
            if (sqlite3_exec(contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                _status.text = @"Failed to create table";
            }
            
            sqlite3_close(contactDB);
            
        }
        else
        {
            _status.text = @"Failed to open/create database";
        }
    }
    
    filemgr = nil;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clear:(id)sender {
    _name.text = @"";
    _address.text = @"";
    _phone.text = @"";
}

- (IBAction)saveData:(id)sender {
    bool bNameFound = false;
    sqlite3_stmt    *statement;
    const char *dbpath = [databasePath UTF8String];
    
    //If the name is empty then return an error
    if ([_name.text isEqualToString:@""])
    {
        _address.text = @"";
        _phone.text = @"";
        _status.text = @"";
        _status.text = @"Invalid name";
        return;
    }
    
    //Open the database
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        //Before saving the data verify that the user doesn't exists
        
        //Create the query to find the name
        NSString *insertSQL = [NSString stringWithFormat:
         @"SELECT address, phone FROM contacts WHERE name=\"%@\"",
         _name.text];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(contactDB, insert_stmt,-1, &statement, NULL);
        
        //if the query returns a row it means that the user exists already
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            bNameFound = true;
            _status.text = @"Contact already exists";
            _name.text = @"";
            _address.text = @"";
            _phone.text = @"";
        }
        
        //If the user was not found then add it to the database
        if (!bNameFound)
        {
            insertSQL = [NSString stringWithFormat: @"INSERT INTO CONTACTS (name, address, phone) VALUES (\"%@\", \"%@\", \"%@\")",_name.text, _address.text, _phone.text];
            
            insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(contactDB, insert_stmt,-1, &statement, NULL);
            
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                _status.text = @"Contact added";
                _name.text = @"";
                _address.text = @"";
                _phone.text = @"";
            }
            else
            {
                _status.text = @"Failed to add contact";
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
    }
    else
    {
        _status.text = @"Can't open DB";
    }
}

- (IBAction)find:(id)sender {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT address, phone FROM contacts WHERE name=\"%@\"",
                              _name.text];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *addressField = [[NSString alloc]
                                          initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 0)];
                _address.text = addressField;
                
                NSString *phoneField = [[NSString alloc]
                                        initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                _phone.text = phoneField;
                
                _status.text = @"Match found";
                
                addressField = nil;
                phoneField = nil;
            }
            else
            {
                _status.text = @"Match not found";
                _address.text = @"";
                _phone.text = @"";
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_close(contactDB);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

@end
