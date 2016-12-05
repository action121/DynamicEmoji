//
//  CFTextModel.m
//  11 - 动态表情
//
//  Created by 于传峰 on 15/12/29.
//  Copyright © 2015年 于传峰. All rights reserved.
//

#import "CFTextModel.h"
#import <UIKit/UIKit.h>
#import "CFTextAttachment.h"
#import "UIImage+GIF.h"

@implementation CFTextModel

- (void)setContentString:(NSString *)contentString
{
    _contentString = contentString;
    NSString* pattern = @"/[\u4e00-\u9fa5]{2,4}";
    NSRegularExpression* regx = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"EmotionGifList" ofType:@"plist"];
    NSDictionary* emotionDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSMutableDictionary* gifEomtionDict = [[NSMutableDictionary alloc] init];
    [regx enumerateMatchesInString:contentString options:NSMatchingReportProgress range:NSMakeRange(0, contentString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        NSString* resultString = [contentString substringWithRange:result.range];
        NSString* gifName = emotionDic[resultString];
        
        for (int i = 0; resultString.length > 2 && !gifName; i++) {
            resultString = [resultString substringWithRange:NSMakeRange(0, resultString.length - 1)];
            gifName = emotionDic[resultString];
        }
        
        if (gifName) {
            gifEomtionDict[NSStringFromRange(NSMakeRange(result.range.location, resultString.length))] = gifName;
            NSLog(@"%@----%@====%@", resultString, gifName, gifEomtionDict);
        }
    }];
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:contentString];
    NSMutableArray* ranges = [gifEomtionDict.allKeys mutableCopy];
    [ranges sortUsingComparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {
        NSRange range1 = NSRangeFromString(obj1);
        NSRange range2 = NSRangeFromString(obj2);
        
        if (range1.location < range2.location) {
            return NSOrderedDescending;
        }
        
        return NSOrderedAscending;
    }];
    
    for (NSString* rangeString in ranges) {
        CFTextAttachment* attachment = [[CFTextAttachment alloc] init];
        attachment.gifName = gifEomtionDict[rangeString];
        if (!_onlyGif) {
            UIImage *image = [UIImage sd_animatedGIFNamed:attachment.gifName];
            attachment.image = image;
        }
        NSAttributedString* attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        [attributedString replaceCharactersInRange:NSRangeFromString(rangeString) withAttributedString:attachmentString];
    }
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:NSMakeRange(0, attributedString.length)];
    self.attributedString = attributedString;
}

@end
