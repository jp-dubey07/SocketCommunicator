//************************************************************************
// ClassName     : Communicator.m
// Created On    : 10/13/12.
// Created By    : Jayprakash Dubey
// Purpose       : Socket connection
//************************************************************************

#import "Communicator.h"

CFReadStreamRef readStream;
CFWriteStreamRef writeStream;

@implementation Communicator

@synthesize inputStream,outputStream;

//////////////////////////////////////////////////////////////////
// Method : setup
// Params :nil
// Description : Establishes a connection for socket
//////////////////////////////////////////////////////////////////

#pragma mark - Connection handlers

- (void)setup {
	NSURL *url = [NSURL URLWithString:host];
	
	NSLog(@"Setting up connection to %@ : %i", [url absoluteString], port);
	
	CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (CFStringRef)CFBridgingRetain([url host]), port, &readStream, &writeStream);
	
	if(!CFWriteStreamOpen(writeStream)) {
		NSLog(@"Error, writeStream not open");
		
		return;
	}
    
	[self open]; // Note if you open connection multiple times then response might be empty
	
	NSLog(@"Status of outputStream: %i", [outputStream streamStatus]);
	
	return;
}

- (void)open {
	NSLog(@"Opening streams.");
	
    inputStream = (NSInputStream *)CFBridgingRelease(readStream);
    outputStream = (NSOutputStream *)CFBridgingRelease(writeStream);
    
	[inputStream setDelegate:self];
	[outputStream setDelegate:self];
	
	[inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
	[inputStream open];
	[outputStream open];
}

- (void)close {
	NSLog(@"Closing streams.");
	
	[inputStream close];
	[outputStream close];
	
	[inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
	[inputStream setDelegate:nil];
	[outputStream setDelegate:nil];
			
	inputStream = nil;
	outputStream = nil;
}

//////////////////////////////////////////////////////////////////
// Method : handleEvent
// Params :event
// Description : Handles events of NSStream
//////////////////////////////////////////////////////////////////

#pragma mark - NSStreamEvent delegates

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event {
	NSLog(@"Stream triggered.");
    
	switch(event) {
            
		case NSStreamEventHasSpaceAvailable: {
			if(stream == outputStream) {
				NSLog(@"outputStream is ready.");
                
                NSString *response  = @"search^10|5|2|1 abcdefgh\r\n\r\n"; // request parameter
                NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
                
                [outputStream write:[data bytes] maxLength:[data length]];
                [outputStream close];
            }
			break;
		}
		case NSStreamEventHasBytesAvailable: {
			         
            NSLog(@"NSStreamEventHasBytesAvailable");
            
            if (stream == inputStream) {
                NSLog(@"inputStream is ready.");
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            
                            NSLog(@"server said: %@", output);
                        }
                    }
                }
            }
            
			break;
		}
        case NSStreamEventErrorOccurred: {
            NSLog(@"Can not connect to the host!");
            
            break;
        }
		case NSStreamEventEndEncountered: {
			NSLog(@"Event end occured");
			break;
		}
		default: {
			NSLog(@"Stream is sending an Event: %i", event);
			
			break;
		}
	}
}

@end
