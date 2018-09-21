//
//  AppDelegate.m
//  Live555Demo
//
//  Created by iceberg on 20/09/2018.
//
//

#import "AppDelegate.h"
#import "liveMedia.hh"
#import "Media.hh"
#import "BasicUsageEnvironment.hh"

#include <arpa/inet.h>

#define NEW_SMS(description) do {\
char const* descStr = description\
", streamed by the LIVE555 Media Server";\
sms = ServerMediaSession::createNew(env, fileName, fileName, descStr);\
} while(0)

@interface AppDelegate () {
    TaskScheduler* scheduler;
    ServerMediaSession* sms;
    UsageEnvironment* env;
    ServerMediaSubsession *mediaSubsession;
    FramedSource *fStreamSource;
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    Boolean const reuseSource = False;

    scheduler = BasicTaskScheduler::createNew();
    env = BasicUsageEnvironment::createNew(*scheduler);
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"record" ofType:@"h264"];
    
    if (filePath == nil) {
        return;
    }
    
    char const* fileName = [filePath UTF8String];
    
    sms = ServerMediaSession::createNew(*env, fileName, fileName, "H.264 Video, streamed by the LIVE555 Media Server");
    
    OutPacketBuffer::maxSize = 100000; // allow for some possibly large H.264 frames
    mediaSubsession = H264VideoFileServerMediaSubsession::createNew(*env, fileName, reuseSource, 1900, true);
    sms->addSubsession(mediaSubsession);
    
    u_int32_t fClientSessionId = 0;
    Port clientRTPPort(23456), clientRTCPPort(23456), serverRTPPort(0), serverRTCPPort(0);

    static netAddressBits destinationAddress = inet_addr("192.168.31.219");
    u_int8_t destinationTTL = 0;
    Boolean isMulticast = False;
    void* streamToken;
    mediaSubsession->getStreamParameters(fClientSessionId, 0, clientRTPPort,clientRTCPPort, -1,0,0, destinationAddress,destinationTTL, isMulticast, serverRTPPort,serverRTCPPort, streamToken);
    
    fStreamSource = mediaSubsession->getStreamSource(streamToken);
  
    unsigned short rtpSeqNum = 0;
    unsigned rtpTimestamp = 0;
    
    mediaSubsession->startStream(fClientSessionId, fStreamSource, NULL, NULL, rtpSeqNum, rtpTimestamp, NULL, NULL);
    
    NSLog(@"rtpSeqNum: %d - rtpTimestamp: %d" , rtpSeqNum, rtpTimestamp);
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
