//
//  DBManager.m
//  mobileLab
//
//  Created by Ilya Zimonin on 12.09.2018.
//  Copyright © 2018 Ilya Zimonin. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>

@interface DBManager ()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;
@property (nonatomic, strong) NSMutableArray *arrResults;


@end

@implementation DBManager

-(instancetype)initWithDatabaseFileName:(NSString *)dbFilename {
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        self.databaseFilename = dbFilename;
        [self copyDatabaseIntoDocumentsDirectory];
    }
    return self;
}

-(void)copyDatabaseIntoDocumentsDirectory {
    NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        // The database file does not exist in the documents directory, so copy it from the main bundle now.
        NSData *data = [NSData data];
        [data writeToFile:destinationPath atomically:YES];
        
    }
}

    -(void)runQuery:(const char *)query
  isQueryExecutable:(BOOL)queryExecutable {
        sqlite3 *sqlite3Database;
        NSString *databasePath = [self.documentsDirectory stringByAppendingString:self.databaseFilename];
        self.arrResults = [NSMutableArray new];
        self.arrColumnNames = [NSMutableArray new];
        BOOL openDatabaseResult = sqlite3_open(databasePath.UTF8String, &sqlite3Database);
        if (openDatabaseResult == SQLITE_OK) {
            sqlite3_stmt *compiledStatement;
            
            BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
            if (prepareStatementResult == SQLITE_OK) {
                if (!queryExecutable) {
                    NSMutableArray *arrDataRow;
                    while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                        arrDataRow = [NSMutableArray new];
                        int totalColumns = sqlite3_column_count(compiledStatement);
                        
                        for (int i = 0; i < totalColumns; i++) {
                            char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                            if (dbDataAsChars) {
                                [arrDataRow addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                            }
                            if (self.arrColumnNames.count != totalColumns) {
                                dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                                [self.arrColumnNames addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                            }
                        }
                        if (arrDataRow.count > 0) {
                            [self.arrResults addObject:arrDataRow];
                        }
                    }
                } else {
                    if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
                        self.affectedRows = sqlite3_changes(sqlite3Database);
                        self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                    } else {
                        NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                    }
                }
            } else {
                NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
            }
            sqlite3_finalize(compiledStatement);
        }
        
}

-(NSArray *)loadDataFromDB:(NSString *)query {
    [self runQuery:query.UTF8String isQueryExecutable:NO];
    return self.arrResults;
}

-(void)executeQuery:(NSString *)query {
    [self runQuery:query.UTF8String isQueryExecutable:YES];
}

@end
