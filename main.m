#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Communicator.h"

int main (int argc, const char *argv[]) {
	
  @autoreleasepool {
	Communicator *c = [[Communicator alloc] init];

	c->host = @"http://abc.pqr.com";
	c->port = 1234;
	
	[c setup];
	
	 return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
	 
  }
}
