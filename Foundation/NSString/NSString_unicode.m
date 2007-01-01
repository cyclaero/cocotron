/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - Christopher Lloyd <cjwl@objc.net>
#import <Foundation/NSString_unicode.h>
#import <Foundation/NSRaise.h>
#import <Foundation/NSString_cString.h>
#import <Foundation/NSStringHashing.h>

@implementation NSString_unicode

NSString *NSString_unicodeNew(NSZone *zone,
 const unichar *unicode,unsigned length) {
   NSString_unicode *self;
   int              i;

   self=NSAllocateObject([NSString_unicode class],length*sizeof(unichar),zone);

   self->_length=length;
   for(i=0;i<length;i++)
    self->_unicode[i]=unicode[i];

   return self;
}

-(unsigned)length {
   return _length;
}

-(unichar)characterAtIndex:(unsigned)location {
   if(location>=_length){
    NSRaiseException(NSRangeException,self,_cmd,@"index %d beyond length %d",
     location,[self length]);
   }

   return _unicode[location];
}

-(void)getCharacters:(unichar *)buffer {
   int i;

   for(i=0;i<_length;i++)
    buffer[i]=_unicode[i];
}

-(void)getCharacters:(unichar *)buffer range:(NSRange)range {
   int i,len=range.length,loc=range.location;

   if(NSMaxRange(range)>_length){
    NSRaiseException(NSRangeException,self,_cmd,@"range %@ beyond length %d",
     NSStringFromRange(range),[self length]);
   }

   for(i=0;i<len;i++)
    buffer[i]=_unicode[loc+i];
}

-(void)getCString:(char *)cString maxLength:(unsigned)maxLength {
   unsigned location;

   NSGetCStringWithMaxLength(_unicode,_length,&location,cString,maxLength,YES);
}

-(unsigned)hash {
   return NSStringHashUnicode(_unicode,MIN(_length,NSHashStringLength));
}

@end
