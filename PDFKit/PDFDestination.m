#import <PDFKit/PDFDestination.h>
#import <PDFKit/PDFDocument.h>

@implementation PDFDestination

- (id)initWithPage:(PDFPage *)page atPoint:(NSPoint)point
{
    if (self = [super init])
    {
        _page = [page retain];
        _point = point;
        _zoom = kPDFDestinationUnspecifiedValue;
    }

    return self;
}


- (id)copyWithZone:(NSZone *)zone
{
    PDFDestination *copy = [[PDFDestination alloc] initWithPage:_page atPoint:_point];
    [copy setZoom:_zoom];
}


- (void)dealloc
{
    [_page release];
    [super dealloc];
}


- (PDFPage *)page
{
    return _page;
}

- (NSPoint)point
{
    return _point;
}


- (CGFloat)zoom
{
    return _zoom;
}


- (void)setZoom:(CGFloat)zoom
{
    _zoom = zoom;
}


- (NSComparisonResult)compare:(PDFDestination *)destination
{
    PDFPage *pageB = [destination page];
    if (pageB)
    {
        PDFDocument *docB = [pageB document];
        PDFDocument *docA = [_page document];
        if (docB == docA)
        {
            NSUInteger pageIndexB = [docB indexForPage:pageB];
            NSUInteger pageIndexA = [docA indexForPage:_page];
            if (pageIndexB > pageIndexA)
                return NSOrderedAscending;

            else if (pageIndexB < pageIndexA)
                return NSOrderedDescending;

            else // (pageIndexB == pageIndexA)
            {
                CGFloat pos = [destination point].y;
                if (pos == kPDFDestinationUnspecifiedValue)
                    if (_point.y == kPDFDestinationUnspecifiedValue)
                        return NSOrderedSame;
                    else
                        pos = [[destination page] boundsForBox:kPDFDisplayBoxMediaBox].size.height;

                if (pos < _point.y)
                    return NSOrderedAscending;

                else if (pos > _point.y)
                    return NSOrderedDescending;

                else // (pos == _point.y)
                    return NSOrderedSame;
            }
        }

        else
        {
            [NSException raise:NSInvalidArgumentException format:@"PDFDestination %@ targets a page from a different PDFDocument, and cannot be compared.", destination];
            return NSNotFound;
        }
    }

    else
    {
        [NSException raise:NSInvalidArgumentException format:@"PDFDestination %@ does not have a page associated with it, and cannot be compared.", destination];
        return NSNotFound;
    }

}

@end
