//
//  FGVDatePicker.m
//  FindAGrave
//
//  Created by Shengzhe Chen on 1/15/14.
//  Copyright (c) 2014 Ancestry.com. All rights reserved.
//

#import "FGVDatePicker.h"
#import "UILabel+FGVExtension.h"

typedef enum : char {
    kComponentTypeYear = 0,
    kComponentTypeMonth = 1,
    kComponentTypeDay = 2
}kComponentType;

@interface FGVDatePicker () < UIPickerViewDataSource, UIPickerViewDelegate >

@end

@implementation FGVDatePicker
{
    UIPickerView *_picker;
    NSUInteger _startYear;
    NSUInteger _endYear;
    NSUInteger _selectYear;
    NSUInteger _selectMonth;
    NSUInteger _selectDay;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _picker.delegate = self;
        _picker.dataSource = self;
        _startYear = 1800;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
        _selectYear = [components year];
        _selectMonth = 12;
        _selectDay = 31;
        _endYear = [components year];
        
        [_picker selectRow:_selectYear - _startYear inComponent:kComponentTypeYear animated:NO];
        [_picker selectRow:_selectMonth inComponent:kComponentTypeMonth animated:NO];
        [_picker selectRow:_selectDay inComponent:kComponentTypeDay animated:NO];
        
        [self addSubview:_picker];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _picker.frame = self.bounds;
}

- (NSDictionary *)date
{
    NSMutableDictionary *ret = [NSMutableDictionary new];
    
    if ([self row:_selectYear-_startYear isLastRowInComponent:kComponentTypeYear]) {
        [ret setObject:@(-1) forKey:@"year"];
    } else {
        [ret setObject:@(_selectYear) forKey:@"year"];
    }
    
    if ([self row:_selectMonth isLastRowInComponent:kComponentTypeMonth]) {
        [ret setObject:@(-1) forKey:@"month"];
    } else {
        [ret setObject:@(_selectMonth+1) forKey:@"month"];
    }
    
    if ([self row:_selectDay isLastRowInComponent:kComponentTypeDay]) {
        [ret setObject:@(-1) forKey:@"day"];
    } else {
        [ret setObject:@(_selectDay+1) forKey:@"day"];
    }
    
    [ret setObject:[self shortDateString] forKey:@"dateString"];
    return ret;
}

- (void)setDate:(NSDictionary *)date
{
    NSInteger year = [[date valueForKey:@"year"] integerValue];
    NSInteger month = [[date valueForKey:@"month"] integerValue];
    NSUInteger day = [[date valueForKey:@"day"] integerValue];
    
    _selectYear = year;
    _selectMonth = month-1;
    _selectDay = day-1;
    
    if (year == -1) {
        _selectYear = _endYear+1;
        _selectMonth = 12;
        _selectDay = 31;
    } else if (month == -1) {
        _selectMonth = 12;
        _selectDay = 31;
    } else if (day == -1) {
        _selectDay = 31;
    }
    
    [_picker reloadAllComponents];
    [_picker selectRow:_selectYear-_startYear inComponent:kComponentTypeYear animated:NO];
    [_picker selectRow:_selectMonth inComponent:kComponentTypeMonth animated:NO];
    [_picker selectRow:_selectDay inComponent:kComponentTypeDay animated:NO];
}

- (NSString *)shortDateString
{
    BOOL isYearLast = [self row:_selectYear - _startYear isLastRowInComponent:kComponentTypeYear];
    BOOL isMonthLast = [self row:_selectMonth isLastRowInComponent:kComponentTypeMonth];
    BOOL isDayLast = [self row:_selectDay isLastRowInComponent:kComponentTypeDay];
    
    if (isYearLast) {
        return @"";
    } else if (isMonthLast) {
        return [NSString stringWithFormat:@"%d", _selectYear];
    } else {
        NSString *year = [NSString stringWithFormat:@"%d", _selectYear];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        NSString *month = [[df shortMonthSymbols] objectAtIndex:_selectMonth];
        if (isDayLast) {
            return [NSString stringWithFormat:@"%@, %@", month, year];
        } else {
            NSString *day = [NSString stringWithFormat:@"%d", _selectDay+1];
            return [NSString stringWithFormat:@"%@ %@, %@", month, day, year];
        }
    }
}

- (BOOL)row:(NSUInteger)row isLastRowInComponent:(NSUInteger)component
{
    int rowCount = [self pickerView:_picker numberOfRowsInComponent:component];
    if (row >= rowCount - 1) {
        return YES;
    }
    return NO;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    switch (component) {
        case kComponentTypeYear:
        {
            return _endYear - _startYear + 2;
        }
            break;
        case kComponentTypeMonth:
        {
            return 13;
        }
            break;
        case kComponentTypeDay:
        {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            
            if ([self row:(_selectYear - _startYear) isLastRowInComponent:kComponentTypeYear] || [self row:_selectMonth isLastRowInComponent:kComponentTypeMonth]) {
                return 32;
            }
            
            [components setYear:_selectYear];
            [components setMonth:_selectMonth+1];
            NSUInteger count = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[calendar dateFromComponents:components]].length + 1;
            if (_selectDay >= count) {
                _selectDay = count - 1;
            }
            return count;
        }
            break;
        default:
            break;
    }
    
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component) {
        case kComponentTypeYear:
        {
            return 100;
        }
            break;
        case kComponentTypeMonth:
        {
            return 50.0f;
        }
            break;
        case kComponentTypeDay:
        {
            return 50.0f;
        }
            break;
        default:
            break;
    }
    
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0f;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if (!view || ![view isKindOfClass:[UILabel class]]) {
        view = [UILabel labelWithFont:[UIFont regularFontWithSize:18.0f] textColor:kPurpleDarkColor text:nil textAlignment:NSTextAlignmentCenter];
    }
    
    UILabel *label = (UILabel *)view;
    if ([self row:row isLastRowInComponent:component]) {
        label.text = @"?";
    } else {
        switch (component) {
            case kComponentTypeYear:
            {
                NSUInteger year = _startYear + row;
                label.text = [NSString stringWithFormat:@"%d", year];
            }
                break;
            case kComponentTypeMonth:
            {
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                NSString *monthName = [[df shortMonthSymbols] objectAtIndex:row];
                label.text = monthName;
            }
                break;
            case kComponentTypeDay:
            {
                NSString *text = nil;
                if (row+1 < 10) {
                    text = [NSString stringWithFormat:@"0%d", row+1];
                } else {
                    text = [NSString stringWithFormat:@"%d", row+1];
                }
                label.text = text;
            }
                break;
            default:
                break;
        }
    }
    [label sizeToFit];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case kComponentTypeYear:
        {
            _selectYear = _startYear + row;
            [pickerView reloadComponent:kComponentTypeDay];
        }
            break;
        case kComponentTypeMonth:
        {
            if ([self row:row isLastRowInComponent:kComponentTypeMonth]) {
                _selectMonth = [self pickerView:pickerView numberOfRowsInComponent:component] - 1;
            } else {
                _selectMonth = row;
            }
            [pickerView reloadComponent:kComponentTypeDay];
        }
            break;
        case kComponentTypeDay:
        {
            if ([self row:row isLastRowInComponent:kComponentTypeDay]) {
                _selectDay = [self pickerView:pickerView numberOfRowsInComponent:component] - 1;
            } else {
                _selectDay = row;
            }
        }
            break;
        default:
            break;
    }
    
    if ([self row:(_selectYear - _startYear) isLastRowInComponent:kComponentTypeYear]) {
        _selectMonth = 12;
        _selectDay = 31;
        [pickerView selectRow:_selectMonth inComponent:kComponentTypeMonth animated:YES];
        [pickerView selectRow:_selectDay inComponent:kComponentTypeDay animated:YES];
    }
    
    if ([self row:_selectMonth isLastRowInComponent:kComponentTypeMonth]) {
        _selectDay = 31;
        [pickerView selectRow:_selectDay inComponent:kComponentTypeDay animated:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(didValueChangedWithDatePicker:)]) {
        [self.delegate didValueChangedWithDatePicker:self];
    }
}

@end
