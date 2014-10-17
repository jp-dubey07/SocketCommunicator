//************************************************************************
// ClassName     : Communicator.h
// Created On    : 10/13/12.
// Created By    : Jayprakash Dubey
// Purpose       : Socket connection
//************************************************************************

#import <Foundation/Foundation.h>

//Note this \r and \n are essential in request parameter
#define REQUEST_DETAILS @"search^10|5|2|1 abcdefghijk\r\n\r\n"

@interface Communicator : NSObject <NSStreamDelegate> {
@public
	
	NSString *host;
	int port;
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
}

- (void)setup;
- (void)open;
- (void)close;
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event;

@property (strong) NSInputStream *inputStream;
@property (strong) NSOutputStream *outputStream;

@end
