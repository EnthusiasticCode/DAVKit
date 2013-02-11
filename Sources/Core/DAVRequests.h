//
//  DAVRequests.h
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "DAVRequest.h"

@interface DAVCopyRequest : DAVRequest {
  @private
	NSString *_destinationPath;
	BOOL _overwrite;
}

@property (copy) NSString *destinationPath;
@property (assign) BOOL overwrite;

@end

@interface DAVDeleteRequest : DAVRequest { }
@end

@interface DAVGetRequest : DAVRequest { }
@end

@interface DAVListingRequest : DAVRequest {
  @private
	NSUInteger _depth;
}

@property (assign) NSUInteger depth; /* default is 1 */

@end

@interface DAVMakeCollectionRequest : DAVRequest { }
@end

@interface DAVMoveRequest : DAVCopyRequest { }
@end


#pragma mark -


@protocol DAVPutRequestDelegate <DAVRequestDelegate>
@optional
- (void)webDAVRequest:(DAVRequest *)request didSendDataOfLength:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
@end

@interface DAVPutRequest : DAVRequest {
  @private
	NSData          *_pdata;
    NSInputStream   *_pstream;
    NSString        *_MIMEType;
}

@property(nonatomic, assign, readonly) id <DAVPutRequestDelegate> delegate;

// Pass - [NSData dataWithContentsOfFile:] to upload a local file
@property (retain) NSData *data;
@property(nonatomic, copy) NSString *dataMIMEType;  // defaults to application/octet-stream
@property (retain) NSInputStream *stream;

@end
