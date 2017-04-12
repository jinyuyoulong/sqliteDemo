//
//  ViewController.m
//  sqliteDemo
//
//  Created by fans on 17/4/6.
//  Copyright © 2017年 Fans. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>
@interface ViewController ()
{
    sqlite3 *db;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self openSqlite];

}
#define NAME @"name"
#define AGE @"age"
#define ADDRESS @"ADDRESS"

- (void)openSqlite{
    //1.打开数据库(如果指定的数据库文件存在就直接打开，不存在就创建一个新的数据文件)
    //参数1:需要打开的数据库文件路径(iOS中一般将数据库文件放到沙盒目录下的Documents下)
    NSString *nsPath = [NSString stringWithFormat:@"%@/Documents/test.db", NSHomeDirectory()];
    NSLog(@"%@",nsPath);
    const char *path = [nsPath UTF8String];

    //参数2:指向数据库变量的指针的地址
    //返回值:数据库操作结果
    int ret = sqlite3_open(path, &db);

    //判断执行结果
    if (ret == SQLITE_OK) {
        [self alertLog:[NSString stringWithFormat:@"%s",__func__] isSuc:true];
//        [self selectDatebase];
        [self update];
//        [self exeSqlite:sqlCreateTable];
    }else{
        [self alertLog:[NSString stringWithFormat:@"%s",__func__] isSuc:NO];
    }
}

- (void)create{
    NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS student (ID INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, age INTEGER, address TEXT)";
    [self execSql:sqlCreateTable result:^(BOOL isSuccess) {
        [self alertLog:[NSString stringWithFormat:@"%s",__func__] isSuc:isSuccess];
    }];
}
- (void)insert{
    NSString *sql1 = [NSString stringWithFormat:
                      @"INSERT INTO '%@' ('%@', '%@', '%@') VALUES ('%@', %@, '%@')",
                      @"student", NAME, AGE, ADDRESS, @"张三", @"23", @"西城区"];

//    NSString *sql2 = [NSString stringWithFormat:
//                      @"INSERT INTO '%@' ('%@', '%@', '%@') VALUES ('%@', %d, '%@')",
//                      @"student", NAME, AGE, ADDRESS, @"老六", 20, @"东城区"];
    [self execSql:sql1 result:^(BOOL isSuccess) {
        [self alertLog:[NSString stringWithFormat:@"%s",__func__] isSuc:isSuccess];

    }];
}
- (void)delete{

}
- (void)update{
    //    NSString *sql1 =  @"UPDATE student set ('name', 'age', 'address') VALUES ('张三', 30, '西城区')";
    NSString *sql1 =  @"UPDATE student set name=\"张三\", age=30";

    //    NSString *sql2 = @"UPDATE student set age=20 where age=20" ;

    [self execSql:sql1 result:^(BOOL isSuccess) {
        [self alertLog:[NSString stringWithFormat:@"%s",__func__] isSuc:isSuccess];
    }];
    //    [self execSql:sql2];
}
-(void)alertLog:(NSString*)typeName isSuc:(BOOL)isSuccess{
    if (isSuccess) {
        printf("\n%s successed!\n",[typeName cStringUsingEncoding:NSUTF8StringEncoding]);
    }else{
        printf("\n%s feild!\n",[typeName cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}
- (void)selectDatebase{
    NSString *sqlQuery = @"SELECT * FROM student";
    sqlite3_stmt * statement;

    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *name = (char*)sqlite3_column_text(statement, 1);
            NSString *nsNameStr = [[NSString alloc]initWithUTF8String:name];

            int age = sqlite3_column_int(statement, 2);

            char *address = (char*)sqlite3_column_text(statement, 3);
            NSString *nsAddressStr = [[NSString alloc]initWithUTF8String:address];

            NSLog(@"name:%@  age:%d  address:%@",nsNameStr,age, nsAddressStr);
        }
    }
    sqlite3_close(db);
}


//执行非查询类的语句，例如创建，添加，删除等操作，使用如下方法：
-(void)execSql:(NSString*)sqlStr result:(void(^)(BOOL isSuccess))theResult{
    //sqlite3_exec方法中第一个参数为成功执行了打开数据库操作的sqlite3指针，第二个参数为要执行的sql语句，最后一个参数为错误信息字符串。
    char *err;
    int result =  sqlite3_exec(db, [sqlStr UTF8String], NULL, NULL, &err);
    if (result == SQLITE_OK) {
        NSLog(@"数据库语句执行成功");
        theResult(YES);
    }else{
        NSLog(@"exe result = %d",result);
        theResult(NO);
    }
}
@end
