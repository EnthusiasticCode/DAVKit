//
//  DAVRequests.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "DAVRequests.h"

#import "DAVListingParser.h"
#import "DAVRequest+Private.h"

@implementation DAVCopyRequest

@synthesize destinationPath = _destinationPath;
@synthesize overwrite = _overwrite;

- (NSString *)method {
	return @"COPY";
}

- (NSURLRequest *)request {
	NSParameterAssert(_destinationPath != nil);
	
	NSURL *dp = [self concatenatedURLWithPath:_destinationPath];
	
	NSMutableURLRequest *req = [self newRequestWithPath:self.path
												 method:[self method]];
	
	[req setValue:[dp absoluteString] forHTTPHeaderField:@"Destination"];
	
	if (_overwrite)
		[req setValue:@"T" forHTTPHeaderField:@"Overwrite"];
	else
		[req setValue:@"F" forHTTPHeaderField:@"Overwrite"];
	
	return [req autorelease];
}

- (void)dealloc {
	[_destinationPath release];
	[super dealloc];
}

@end


@implementation DAVDeleteRequest

- (NSURLRequest *)request {
	return [[self newRequestWithPath:self.path method:@"DELETE"] autorelease];
}

@end


@implementation DAVGetRequest

- (NSURLRequest *)request {
	return [[self newRequestWithPath:self.path method:@"GET"] autorelease];
}

- (id)resultForData:(NSData *)data {
	return data;
}

@end


@implementation DAVListingRequest

@synthesize depth = _depth;

- (id)initWithPath:(NSString *)aPath session:(DAVSession *)session delegate:(id <DAVRequestDelegate>)delegate;
{
	self = [super initWithPath:aPath session:session delegate:delegate];
	if (self) {
		_depth = 1;
	}
	return self;
}

- (NSURLRequest *)request {
	NSMutableURLRequest *req = [self newRequestWithPath:self.path method:@"PROPFIND"];
	
	if (_depth > 1) {
		[req setValue:@"infinity" forHTTPHeaderField:@"Depth"];
	}
	else {
		[req setValue:[NSString stringWithFormat:@"%ld", (unsigned long) _depth] forHTTPHeaderField:@"Depth"];
	}
	
	[req setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
	
	NSString *xml = @"<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n"
					@"<D:propfind xmlns:D=\"DAV:\"><D:allprop/></D:propfind>";
	
	[req setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
	
	return [req autorelease];
}

- (id)resultForData:(NSData *)data {
	DAVListingParser *p = [[DAVListingParser alloc] initWithData:data];
	
	NSError *error = nil;
	NSArray *items = [p parse:&error];
	
	if (error) {
		#ifdef DEBUG
			NSLog(@"XML Parse error: %@", error);
		#endif
	}
	
	[p release];
	
	return items;
}

@end


@implementation DAVMakeCollectionRequest

- (NSURLRequest *)request {
	return [[self newRequestWithPath:self.path method:@"MKCOL"] autorelease];
}

@end


@implementation DAVMoveRequest

- (NSString *)method {
	return @"MOVE";
}

@end


@implementation DAVPutRequest

- (id)initWithSession:(DAVSession *)session;
{
    if (self = [super initWithSession:session])
    {
        _MIMEType = @"application/octet-stream";
    }
    return self;
}

@dynamic delegate;

@synthesize data = _pdata;
@synthesize dataMIMEType = _MIMEType;

- (NSURLRequest *)request {
	NSParameterAssert(_pdata != nil);
	
	NSString *len = [NSString stringWithFormat:@"%ld", (unsigned long)[_pdata length]];
	
	NSMutableURLRequest *req = [self newRequestWithPath:self.path method:@"PUT"];
	[req setValue:[self dataMIMEType] forHTTPHeaderField:@"Content-Type"];
	[req setValue:len forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:_pdata];
	
	return [req autorelease];
}

- (void)dealloc
{
	[_pdata release];
    [_MIMEType release];
    
	[super dealloc];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if ([[self delegate] respondsToSelector:@selector(webDAVRequest:didSendDataOfLength:totalBytesWritten:totalBytesExpectedToWrite:)])
    {
        [[self delegate] webDAVRequest:self didSendDataOfLength:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

@end
