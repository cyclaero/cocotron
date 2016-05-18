#import <Foundation/Foundation.h>
#import <PDFKit/PDFPage.h>

#define kPDFDestinationUnspecifiedValue FLT_MAX

@interface PDFDestination : NSObject <NSCopying>
{
    PDFPage *_page;
    NSPoint  _point;
    CGFloat  _zoom;
}

- (id)initWithPage:(PDFPage *)page atPoint:(NSPoint)point;
- (PDFPage *)page;
- (NSPoint)point;
- (CGFloat)zoom;
- (void)setZoom:(CGFloat)zoom;
- (NSComparisonResult)compare:(PDFDestination *)destination;

@end
