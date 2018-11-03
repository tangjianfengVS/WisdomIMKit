//
//  WisdomGCDAsyncSocketDelegate.swift
//  WisdomIMKit
//
//  Created by jianfeng on 2018/11/3.
//  Copyright © 2018年 All over the sky star. All rights reserved.
//

import UIKit

@objc public protocol WisdomGCDAsyncSocketDelegate {

    
}
///**
// * This method is called immediately prior to socket:didAcceptNewSocket:.
// * It optionally allows a listening socket to specify the socketQueue for a new accepted socket.
// * If this method is not implemented, or returns NULL, the new accepted socket will create its own default queue.
// *
// * Since you cannot autorelease a dispatch_queue,
// * this method uses the "new" prefix in its name to specify that the returned queue has been retained.
// *
// * Thus you could do something like this in the implementation:
// * return dispatch_queue_create("MyQueue", NULL);
// *
// * If you are placing multiple sockets on the same queue,
// * then care should be taken to increment the retain count each time this method is invoked.
// *
// * For example, your implementation might look something like this:
// * dispatch_retain(myExistingQueue);
// * return myExistingQueue;
// **/
//- (nullable dispatch_queue_t)newSocketQueueForConnectionFromAddress:(NSData *)address onSocket:(GCDAsyncSocket *)sock;
//
///**
// * Called when a socket accepts a connection.
// * Another socket is automatically spawned to handle it.
// *
// * You must retain the newSocket if you wish to handle the connection.
// * Otherwise the newSocket instance will be released and the spawned connection will be closed.
// *
// * By default the new socket will have the same delegate and delegateQueue.
// * You may, of course, change this at any time.
// **/
//- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket;
//
///**
// * Called when a socket connects and is ready for reading and writing.
// * The host parameter will be an IP address, not a DNS name.
// **/
//- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port;
//
///**
// * Called when a socket connects and is ready for reading and writing.
// * The host parameter will be an IP address, not a DNS name.
// **/
//- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url;
//
///**
// * Called when a socket has completed reading the requested data into memory.
// * Not called if there is an error.
// **/
//- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
//
///**
// * Called when a socket has read in data, but has not yet completed the read.
// * This would occur if using readToData: or readToLength: methods.
// * It may be used to for things such as updating progress bars.
// **/
//- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag;
//
///**
// * Called when a socket has completed writing the requested data. Not called if there is an error.
// **/
//- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag;
//
///**
// * Called when a socket has written some data, but has not yet completed the entire write.
// * It may be used to for things such as updating progress bars.
// **/
//- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag;
//
///**
// * Called if a read operation has reached its timeout without completing.
// * This method allows you to optionally extend the timeout.
// * If you return a positive time interval (> 0) the read's timeout will be extended by the given amount.
// * If you don't implement this method, or return a non-positive time interval (<= 0) the read will timeout as usual.
// *
// * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
// * The length parameter is the number of bytes that have been read so far for the read operation.
// *
// * Note that this method may be called multiple times for a single read if you return positive numbers.
// **/
//- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
//elapsed:(NSTimeInterval)elapsed
//bytesDone:(NSUInteger)length;
//
///**
// * Called if a write operation has reached its timeout without completing.
// * This method allows you to optionally extend the timeout.
// * If you return a positive time interval (> 0) the write's timeout will be extended by the given amount.
// * If you don't implement this method, or return a non-positive time interval (<= 0) the write will timeout as usual.
// *
// * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
// * The length parameter is the number of bytes that have been written so far for the write operation.
// *
// * Note that this method may be called multiple times for a single write if you return positive numbers.
// **/
//- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
//elapsed:(NSTimeInterval)elapsed
//bytesDone:(NSUInteger)length;
//
///**
// * Conditionally called if the read stream closes, but the write stream may still be writeable.
// *
// * This delegate method is only called if autoDisconnectOnClosedReadStream has been set to NO.
// * See the discussion on the autoDisconnectOnClosedReadStream method for more information.
// **/
//- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock;
//
///**
// * Called when a socket disconnects with or without error.
// *
// * If you call the disconnect method, and the socket wasn't already disconnected,
// * then an invocation of this delegate method will be enqueued on the delegateQueue
// * before the disconnect method returns.
// *
// * Note: If the GCDAsyncSocket instance is deallocated while it is still connected,
// * and the delegate is not also deallocated, then this method will be invoked,
// * but the sock parameter will be nil. (It must necessarily be nil since it is no longer available.)
// * This is a generally rare, but is possible if one writes code like this:
// *
// * asyncSocket = nil; // I'm implicitly disconnecting the socket
// *
// * In this case it may preferrable to nil the delegate beforehand, like this:
// *
// * asyncSocket.delegate = nil; // Don't invoke my delegate method
// * asyncSocket = nil; // I'm implicitly disconnecting the socket
// *
// * Of course, this depends on how your state machine is configured.
// **/
//- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err;
//
///**
// * Called after the socket has successfully completed SSL/TLS negotiation.
// * This method is not called unless you use the provided startTLS method.
// *
// * If a SSL/TLS negotiation fails (invalid certificate, etc) then the socket will immediately close,
// * and the socketDidDisconnect:withError: delegate method will be called with the specific SSL error code.
// **/
//- (void)socketDidSecure:(GCDAsyncSocket *)sock;
//
///**
// * Allows a socket delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
// *
// * This is only called if startTLS is invoked with options that include:
// * - GCDAsyncSocketManuallyEvaluateTrust == YES
// *
// * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
// *
// * Note from Apple's documentation:
// *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
// *   [it] might block while attempting network access. You should never call it from your main thread;
// *   call it only from within a function running on a dispatch queue or on a separate thread.
// *
// * Thus this method uses a completionHandler block rather than a normal return value.
// * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
// * It is safe to invoke the completionHandler block even if the socket has been closed.
// **/
//- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust
//completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler;
//
//@end
//NS_ASSUME_NONNULL_END
