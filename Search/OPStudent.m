//
//  OPStudent.m
//  Search
//
//  Created by Oleg Pochtovy on 20.01.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPStudent.h"

static NSString* firstNames[] = {
    @"Tran", @"Lenore", @"Bud", @"Fredda", @"Katrice",
    @"Clyde", @"Hildegard", @"Vernell", @"Nellie", @"Rupert",
    @"Billie", @"Tamica", @"Crystle", @"Kandi", @"Caridad",
    @"Vanetta", @"Taylor", @"Pinkie", @"Ben", @"Rosanna",
    @"Eufemia", @"Britteny", @"Ramon", @"Jacque", @"Telma",
    @"Colton", @"Monte", @"Pam", @"Tracy", @"Tresa",
    @"Willard", @"Mireille", @"Roma", @"Elise", @"Trang",
    @"Ty", @"Pierre", @"Floyd", @"Savanna", @"Arvilla",
    @"Whitney", @"Denver", @"Norbert", @"Meghan", @"Tandra",
    @"Jenise", @"Brent", @"Elenor", @"Sha", @"Jessie"
}; // !!! - it's C array (not NSObject array)

static NSString* lastNames[] = {
    
    @"Farrah", @"Laviolette", @"Heal", @"Sechrest", @"Roots",
    @"Homan", @"Starns", @"Oldham", @"Yocum", @"Mancia",
    @"Prill", @"Lush", @"Piedra", @"Castenada", @"Warnock",
    @"Vanderlinden", @"Simms", @"Gilroy", @"Brann", @"Bodden",
    @"Lenz", @"Gildersleeve", @"Wimbish", @"Bello", @"Beachy",
    @"Jurado", @"William", @"Beaupre", @"Dyal", @"Doiron",
    @"Plourde", @"Bator", @"Krause", @"Odriscoll", @"Corby",
    @"Waltman", @"Michaud", @"Kobayashi", @"Sherrick", @"Woolfolk",
    @"Holladay", @"Hornback", @"Moler", @"Bowles", @"Libbey",
    @"Spano", @"Folson", @"Arguelles", @"Burke", @"Rook"
};

static int namesCount = 50;

@implementation OPStudent

// generation of student's properties
+ (OPStudent *)randomStudent {
    
    OPStudent *student = [[OPStudent alloc] init];
    
    student.firstName = firstNames[arc4random() % namesCount];
    student.lastName = lastNames[arc4random() % namesCount];
    student.yearOfBirth = (arc4random() % 17) + 1980; // year of birth from 1980 till 1996
    NSInteger randomYear = (arc4random() % 17) + 1980; // year of birth from 1980 till 1996
    NSInteger randomMonth = (arc4random() % 12) + 1;
    NSInteger numberOfDaysInRandomMonth = 31;
    
    if (randomMonth == 2) {
        
        if (randomYear % 4) {
            
            numberOfDaysInRandomMonth = 28;
            
        } else if (randomYear % 100) {
            
            numberOfDaysInRandomMonth = 29;
            
        } else if (randomYear % 400) {
            
            numberOfDaysInRandomMonth = 28;
            
        } else {
            
            numberOfDaysInRandomMonth = 29;
            
        }
        
    } else if ( ( !(randomMonth % 2) && (randomMonth < 8) ) || ( (randomMonth % 2) && (randomMonth > 8) ) ) {
        
        numberOfDaysInRandomMonth = 30;
        
    }
    
    NSInteger randomDay = (arc4random() % numberOfDaysInRandomMonth) + 1;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString *dateString = [NSString stringWithFormat:@"%li/%li/%li", (long)randomYear, (long)randomMonth, (long)randomDay];
    student.birthDate = [dateFormatter dateFromString:dateString];
    
    [dateFormatter setDateFormat:@"MM"]; // MM - month, mm - minutes, MM - month by digit, MMM - shorthand for month, MMMM - full month name, MMMMM - first letter of month
    student.monthDigit = [dateFormatter stringFromDate:student.birthDate];
    
    return student;
}

@end
