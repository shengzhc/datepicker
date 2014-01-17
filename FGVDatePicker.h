//
//  FGVDatePicker.h
//  FindAGrave
//
//  Created by Shengzhe Chen on 1/15/14.
//  Copyright (c) 2014 Ancestry.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FGVDatePicker;

@protocol FGVDatePickerDelegate <NSObject>

@optional
- (void)didValueChangedWithDatePicker:(FGVDatePicker *)picker;

@end


@interface FGVDatePicker : UIView

@property (nonatomic, weak) id < FGVDatePickerDelegate > delegate;
@property (nonatomic, strong) NSDictionary *date;

- (NSString *)shortDateString;

@end
