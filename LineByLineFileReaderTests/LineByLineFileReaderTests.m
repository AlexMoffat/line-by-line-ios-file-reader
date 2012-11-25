//
//  LineByLineFileReaderTests.m
//
//  Copyright (c) 2012 Alex Moffat. All rights reserved.
//

#import "LineByLineFileReaderTests.h"
#import "LineByLineFileReader.h"

@implementation LineByLineFileReaderTests

// Method to check that we get what we expect when we read a file.
- (void)readFile:(NSString *)path withLines:(int)lines andExpectingError:(BOOL)expectError
{
    LineByLineFileReader *reader = [[LineByLineFileReader alloc] init];
    
    __block BOOL gotError = NO;
    __block int linesRead = 0;
    __block NSMutableArray *linesFromReader = [NSMutableArray arrayWithCapacity:8];
    [reader processFile:path withEncoding:NSUTF8StringEncoding usingBlock:^(NSString *line, NSError *error)  {
        if (error) {
            gotError = YES;
        } else {
            ++linesRead;
            [linesFromReader addObject:line];
        }
    }];
    
    // RunLoop is used to read the file so need to give it time to run.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    
    // Check number of lines read.
    STAssertEquals(linesRead, lines, @"Read lines");
    
    // If we expect an error check we got one.
    if (expectError) {
        STAssertTrue(gotError, @"Got error");
    }
    
    // Didn't expect an error and didn't get one so check the file contents.
    if (!expectError && !gotError) {
        // Read the file using a different method and compare the results.
        NSError *error;
        NSArray *allLines = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        STAssertEqualObjects(linesFromReader, allLines, @"Lines match");
    }
}

// Read a file where all the contents fit into a single buffer used by LinebyLineFileReader
- (void)testReadSimpleFile
{
    // Using bundleForClass means we can just add the resource to the test target.
    // Using mainBundle it had to be in the
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestFileOne" ofType:@"txt"];
    
    [self readFile:path withLines:9 andExpectingError:NO];
}

// This file "TestFileTwo" has several lines that span blocks, that is when reading in 1024
// blocks we end up with a partial line at the end of the block.
- (void)testReadLongerFile
{
    // Using bundleForClass means we can just add the resource to the test target.
    // Using mainBundle it had to be in the
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestFileTwo" ofType:@"txt"];
    
    [self readFile:path withLines:123 andExpectingError:NO];
}

// Try reading a file that doesn't exist.
- (void)testNilFile
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"Missing" ofType:@"txt"];
    
    [self readFile:path withLines:0 andExpectingError:YES];}

// Try reading another file that doesn't exist.
- (void)testReadNonexistingFile
{
    NSString *path = [[[NSBundle bundleForClass:[self class]] pathForResource:@"TestFileTwo" ofType:@"txt"] stringByReplacingOccurrencesOfString:@"TestFileTwo" withString:@"Missing"];
    
    [self readFile:path withLines:0 andExpectingError:YES];
}

@end
