/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - Christopher Lloyd <cjwl@objc.net>
#import <Foundation/NSPersistantDomain_win32.h>
#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSData.h>
#import <Foundation/NSPropertyListReader.h>
#import <Foundation/NSPropertyListWriter.h>
#import <Foundation/NSException.h>

#import <windows.h>

@implementation NSPersistantDomain_win32

-(HKEY)rootHandle {
   int   i,count=[_path count];
   HKEY  previous=HKEY_CURRENT_USER;
   HKEY  current=NULL;
   DWORD disposition;
   LONG  error;

   for(i=0;i<count;i++){
    error=RegCreateKeyEx(previous,[[_path objectAtIndex:i] cString],0,"",
         REG_OPTION_NON_VOLATILE,KEY_ALL_ACCESS,NULL,&current,&disposition);

    if(error!=ERROR_SUCCESS)
     NSLog(@"RegCreateKeyEx failed %@",_path);

    if(previous!=HKEY_CURRENT_USER)
     RegCloseKey(previous);

    previous=current;
   }

   return current;
}

-initWithName:(NSString *)name {
   _path=[[NSArray arrayWithObjects:
     @"Software",@"Cocotron",name,nil] retain];
   _handle=[self rootHandle];
   _cache=[NSMutableDictionary new];
   return self;
}

-(void)dealloc {
   if(_handle!=NULL){
    RegFlushKey(_handle);
    RegCloseKey(_handle);
   }
   [_path release];
   [_cache release];
   [super dealloc];
}

+(NSPersistantDomain_win32 *)persistantDomainWithName:(NSString *)name {
   return [[[self allocWithZone:NULL] initWithName:name] autorelease];
}

-(NSArray *)allKeys {
   NSMutableArray *result=[NSMutableArray array];
   LONG            error;
   int             index;
   char            valueName[8192];
   DWORD           length;

   for(index=0;;index++){
    length=8192;
    error=RegEnumValue(_handle,index,valueName,&length,NULL,NULL,NULL,NULL);
    if(error!=ERROR_SUCCESS)
     break;
    [result addObject:[NSString stringWithCString:valueName length:length]];
   }

   return result;
}

-(NSEnumerator *)keyEnumerator {
    return [[self allKeys] objectEnumerator];
}

-objectForKey:(NSString *)key {
   id result=[_cache objectForKey:key];

   if(result==nil){
    LONG      error;
    DWORD     type;
    char      buffer[8192];
    DWORD     length=8192;

//NSLog(@"-[%@ %s] %@ %@",isa,SELNAME(_cmd),_path,key);

    error=RegQueryValueEx(_handle,[key cString],NULL,&type,(void *)buffer,&length);
    if(error!=ERROR_SUCCESS){
     //NSLog(@"RegQueryValueEx failed %@ %@",_path,key);
    }

    if(error!=ERROR_SUCCESS)
     return nil;

    NS_DURING
     result=[[NSString stringWithCString:buffer] propertyList];
    NS_HANDLER
     result=nil;
    NS_ENDHANDLER

    [_cache setObject:result forKey:key];
   }

   return result;
}

-(void)setObject:object forKey:(NSString *)key {
   LONG      error;
   NSData   *data=[NSPropertyListWriter dataWithPropertyList:object];
   
   [_cache removeObjectForKey:key];

   error=RegSetValueEx(_handle,[key cString],0,REG_SZ,[data bytes],[data length]);
   if(error!=ERROR_SUCCESS){
    NSLog(@"RegSetValueEx failed %@ %@",_path,key);
   }
}

-(void)removeObjectForKey:(NSString *)key {
   LONG      error;

   [_cache removeObjectForKey:key];

   error=RegDeleteValue(_handle,[key cString]);
   if(error!=ERROR_SUCCESS){
    NSLog(@"RegDeleteValue failed %@ %@",_path,key);
   }
}

@end
