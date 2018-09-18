//
//  PasswordSelectViewController.m
//  mobileLab
//
//  Created by Ilya Zimonin on 12.09.2018.
//  Copyright © 2018 Ilya Zimonin. All rights reserved.
//

#import "PasswordSelectViewController.h"
#import "DBManager.h"

@interface PasswordSelectViewController ()

@property (nonatomic, strong) DBManager *dbManager;
@property (weak, nonatomic) IBOutlet UITextField *labelPassword;
@property (weak, nonatomic) IBOutlet UITextField *labelPasswordRepeated;
@property (weak, nonatomic) IBOutlet UILabel *labelHint;

-(nullable NSString *)validatePassword:(NSString *)password
             repeatedPassword:(NSString *)repeatedPassword;
-(void)showPrompt:(NSString *)promptText;

@end

@implementation PasswordSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.dbManager = [[DBManager alloc] initWithDatabaseFileName:@"sambledb.sql"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionButtonAcceptClick:(id)sender {
    NSString *validationResult = [self validatePassword:self.labelPassword.text repeatedPassword:self.labelPasswordRepeated.text];
    if (validationResult == nil) {
        
    } else {
        [self showPrompt:validationResult];
    }
}

-(nullable NSString *)validatePassword:(NSString *)password
             repeatedPassword:(NSString *)repeatedPassword {
    if ([password isEqualToString:@""] || [repeatedPassword isEqualToString:@""]) {
        return @"Поля не могут быть пустыми";
    }
    
    if (![password isEqualToString:repeatedPassword]) {
        return @"Пароли не совпадают";
    }
    
    return nil;
}

-(void)showPrompt:(NSString *)promptText {
    self.labelHint.text = promptText;
    self.labelHint.alpha = 1.0f;
    [UIView animateWithDuration:3.0f delay:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
        [self.labelHint setAlpha:0.0f];
    } completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
