//
//  ViewController.h
//  Agenda
//
//  Created by Kaches on 2/4/13.
//  Copyright (c) 2013 Kaches. All rights reserved.
//
// ahh perro

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface ViewController : UIViewController<UITextFieldDelegate>
{
    NSString        *databasePath;
    sqlite3         *contactDB;

}
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UILabel *status;
- (IBAction)clear:(id)sender;
- (IBAction)saveData:(id)sender;
- (IBAction)find:(id)sender;

@end
