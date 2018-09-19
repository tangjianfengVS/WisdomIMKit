// ZKAFJSONRPCClient.m
//
// Created by wiistriker@gmail.com
// Copyright (c) 2016 zhengkai
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZKAFJSONRPCClient.h"
#import "AFNetworking.h"
//#import "SPDYProtocol.h"
#import <objc/runtime.h>

NSString * const AFJSONRPCErrorDomain = @"com.alamofire.networking.json-rpc";

static NSString * AFJSONRPCLocalizedErrorMessageForCode(NSInteger code) {
    switch(code) {
        case -32700:
            return @"Parse Error";
        case -32600:
            return @"Invalid Request";
        case -32601:
            return @"Method Not Found";
        case -32602:
            return @"Invalid Params";
        case -32603:
            return @"Internal Error";
        default:
            return @"Server Error";
    }
}

@interface AFJSONRPCProxy : NSProxy
- (id)initWithClient:(ZKAFJSONRPCClient *)client
            protocol:(Protocol *)protocol;
@end

#pragma mark -
@interface ZKAFJSONRPCClient ()
@property (nonatomic,strong)AFHTTPSessionManager *manager;
@end

@implementation ZKAFJSONRPCClient

- (id)initWithEndpointURL:(NSURL *)URL AndClientP12fileName:(NSString *)P12Name andServerCerfileName:(NSString *)serverCerName andP12Password:(NSString *)P12Password{
    NSParameterAssert(URL);
    self = [super init];
    if (!self) {
        return nil;
    }
    self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:URL];
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    self.manager.requestSerializer.timeoutInterval = 55.f;
    [self.manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    self.manager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json", @"application/json-rpc", @"application/jsonrequest", @"text/html",@"text/plain",nil];
    //self.manager.securityPolicy = [self customSecurityPolicy:serverCerName];
    self.manager.securityPolicy.allowInvalidCertificates = YES;
    self.manager.securityPolicy.validatesDomainName = NO;
    self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //self.manager.session.configuration.protocolClasses=@[[SPDYURLSessionProtocol class]];
    [self.manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession*session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing*_credential) {
        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        __autoreleasing NSURLCredential *credential =nil;
        if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            if([self.manager.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                if(credential) {
                    disposition =NSURLSessionAuthChallengeUseCredential;
                } else {
                    disposition =NSURLSessionAuthChallengePerformDefaultHandling;
                }
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            SecIdentityRef identity = NULL;
            SecTrustRef trust = NULL;
            NSString *p12;
            NSLog(@"p12Name===%@",P12Name);
            if ([P12Name isEqualToString:@"trllojtej3cnd6cgclyw.6"]) {
                p12 = [[NSBundle mainBundle] pathForResource:P12Name ofType:@"p12"];
            }else{
                NSString *sandboxPath = NSHomeDirectory();
                NSString *documentPath = [sandboxPath stringByAppendingPathComponent:@"Documents"];
                NSString *p12str=[NSString stringWithFormat:@"%@.p12",P12Name];
                p12=[documentPath stringByAppendingPathComponent:p12str];
            }
            NSLog(@"P12地址。。。%@",p12);
            NSFileManager *fileManager =[NSFileManager defaultManager];
            if(![fileManager fileExistsAtPath:p12]){
                //NSLog(@"client.p12:not exist");
            }else{
                NSData *PKCS12Data = [NSData dataWithContentsOfFile:p12];
                if ([[self class]extractIdentity:&identity andTrust:&trust fromPKCS12Data:PKCS12Data andP12Password:P12Password]){
                    SecCertificateRef certificate = NULL;
                    SecIdentityCopyCertificate(identity, &certificate);
                    const void*certs[] = {certificate};
                    CFArrayRef certArray =CFArrayCreate(kCFAllocatorDefault, certs,1,NULL);
                    credential =[NSURLCredential credentialWithIdentity:identity certificates:(__bridge  NSArray*)certArray persistence:NSURLCredentialPersistencePermanent];
                    disposition =NSURLSessionAuthChallengeUseCredential;
                }
            }
        }
        *_credential = credential;
        return disposition;
    }];
    self.endpointURL = URL;
    return self;
}


- (AFSecurityPolicy*)customSecurityPolicy:(NSString *)CerNameOfServer{
    // /先导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:CerNameOfServer ofType:@"cer"];//证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    securityPolicy.pinnedCertificates = [NSSet setWithObjects:certData, nil];
    return securityPolicy;
}



+ (BOOL)extractIdentity:(SecIdentityRef*)outIdentity andTrust:(SecTrustRef *)outTrust fromPKCS12Data:(NSData *)inPKCS12Data andP12Password:(NSString *)P12Password{
    OSStatus securityError = errSecSuccess;
//    MyLog(@"p12Password::::%@",P12Password);
    //client certificate password
    NSDictionary*optionsDictionary = [NSDictionary dictionaryWithObject:P12Password forKey:(__bridge id)kSecImportExportPassphrase];
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import((__bridge CFDataRef)inPKCS12Data,(__bridge CFDictionaryRef)optionsDictionary,&items);
    
    if(securityError == 0) {
        CFDictionaryRef myIdentityAndTrust =CFArrayGetValueAtIndex(items,0);
        const void*tempIdentity =NULL;
        tempIdentity= CFDictionaryGetValue (myIdentityAndTrust,kSecImportItemIdentity);
        *outIdentity = (SecIdentityRef)tempIdentity;
        const void*tempTrust =NULL;
        tempTrust = CFDictionaryGetValue(myIdentityAndTrust,kSecImportItemTrust);
        *outTrust = (SecTrustRef)tempTrust;
    } else {
        NSLog(@"Failedwith error code %d",(int)securityError);
        return NO;
    }
    return YES;
}


- (void)invokeMethod:(NSString *)method
             success:(void (^)(NSURLSessionDataTask *operation, id responseObject))success
             failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))failure{
    [self invokeMethod:method withParameters:@[] success:success failure:failure];
}

- (void)invokeMethod:(NSString *)method
      withParameters:(id)parameters
             success:(void (^)(NSURLSessionDataTask *operation, id responseObject))success
             failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))failure{
    [self invokeMethod:method withParameters:parameters interface:@"" success:success failure:failure];
}

- (void)invokeMethod:(NSString *)method
      withParameters:(id)parameters
           requestId:(id)requestId
             success:(void (^)(NSURLSessionDataTask *operation, id responseObject))success
             failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))failure {
    [self invokeMethod:method withParameters:parameters  interface:@"" success:success failure:failure];
}

- (void)invokeMethod:(NSString *)method
      withParameters:(id)parameters
           interface:(NSString*)interface
           requestID:(NSString *)requestID
             success:(void (^)(NSURLSessionDataTask *operation, id responseObject))success
             failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))failure{
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"jsonrpc"] = @"2.0";
    payload[@"method"] = method;
    payload[@"params"] = parameters;
    payload[@"id"] = requestID;
//    MyLog(@"访问地址%@",[NSString stringWithFormat:@"%@/%@",self.endpointURL,interface]);
    [self.manager POST:[[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.endpointURL,interface]] absoluteString]
            parameters:payload
              progress:^(NSProgress * _Nonnull uploadProgress) {
                  
              } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  NSInteger code = 0;
                  NSString *message = nil;
                  id data = nil;
                  if ([responseObject isKindOfClass:[NSDictionary class]]) {
                      id result = responseObject[@"result"];
                      id error = responseObject[@"error"];
                      if (result && result != [NSNull null]) {
                          if (success) {
                              success(task, result);
                              return;
                          }
                      } else if (error && error != [NSNull null]) {
                          if ([error isKindOfClass:[NSDictionary class]]) {
                              if (error[@"code"]) {
                                  code = [error[@"code"] integerValue];
                              }
                              if (error[@"message"]) {
                                  message = error[@"message"];
                              } else if (code) {
                                  message = AFJSONRPCLocalizedErrorMessageForCode(code);
                              }
                              data = error[@"data"];
                          } else {
                              message = NSLocalizedStringFromTable(@"Unknown Error", @"ZKAFJSONRPCClient", nil);
                          }
                      } else {
                          message = NSLocalizedStringFromTable(@"Unknown JSON-RPC Response", @"ZKAFJSONRPCClient", nil);
                      }
                  } else {
                      NSLog(@"JSON: %@", responseObject);
                      message = NSLocalizedStringFromTable(@"Unknown JSON-RPC Response", @"ZKAFJSONRPCClient", nil);
                  }
                  
                  if (failure) {
                      NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                      if (message) {
                          userInfo[NSLocalizedDescriptionKey] = message;
                      }
                      if (data) {
                          userInfo[@"data"] = data;
                      }
                      NSError *error = [NSError errorWithDomain:@"" code:code userInfo:userInfo];
                      failure(task, error);
                  }
              }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                   if (failure) {
                       failure(task, error);
                   }
               }];
}

- (void)invokeMethod:(NSString *)method
      withParameters:(id)parameters
           interface:(NSString*)interface
             success:(void (^)(NSURLSessionDataTask *operation, id responseObject))success
             failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))failure{
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"jsonrpc"] = @"2.0";
    payload[@"method"] = method;
    payload[@"params"] = parameters;
    payload[@"id"] = @"1";
    
    [self.manager POST:[[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.endpointURL,interface]] absoluteString]
            parameters:payload
              progress:^(NSProgress * _Nonnull uploadProgress) {
                  
              } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  NSInteger code = 0;
                  NSString *message = nil;
                  id data = nil;
                  if ([responseObject isKindOfClass:[NSDictionary class]]) {
                      id result = responseObject[@"result"];
                      id error = responseObject[@"error"];
                      
                      if (result && result != [NSNull null]) {
                          if (success) {
                              success(task, result);
                              return;
                          }
                      } else if (error && error != [NSNull null]) {
                          if ([error isKindOfClass:[NSDictionary class]]) {
                              if (error[@"code"]) {
                                  code = [error[@"code"] integerValue];
                              }
                              
                              if (error[@"message"]) {
                                  message = error[@"message"];
                              } else if (code) {
                                  message = AFJSONRPCLocalizedErrorMessageForCode(code);
                              }
                              
                              data = error[@"data"];
                          } else {
                              message = NSLocalizedStringFromTable(@"Unknown Error", @"ZKAFJSONRPCClient", nil);
                          }
                      } else {
                          message = NSLocalizedStringFromTable(@"Unknown JSON-RPC Response", @"ZKAFJSONRPCClient", nil);
                      }
                  } else {
                      NSLog(@"JSON: %@", responseObject);
                      message = NSLocalizedStringFromTable(@"Unknown JSON-RPC Response", @"ZKAFJSONRPCClient", nil);
                  }
                  
                  if (failure) {
                      NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                      if (message) {
                          userInfo[NSLocalizedDescriptionKey] = message;
                      }
                      if (data) {
                          userInfo[@"data"] = data;
                      }
                      NSError *error = [NSError errorWithDomain:@"" code:code userInfo:userInfo];
                      failure(task, error);
                  }
              }
               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                   if (failure) {
                       failure(task, error);
                   }
               }];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                parameters:(id)parameters
                                 requestId:(id)requestId{
    NSParameterAssert(method);
    if (!parameters) {
        parameters = @[];
    }
    NSAssert([parameters isKindOfClass:[NSDictionary class]] || [parameters isKindOfClass:[NSArray class]], @"Expect NSArray or NSDictionary in JSONRPC parameters");
    if (!requestId) {
        requestId = @(0);
    }
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"jsonrpc"] = @"2.0";
    payload[@"method"] = method;
    payload[@"params"] = @[parameters];
    payload[@"id"] = @"0";
    return [self.manager.requestSerializer requestWithMethod:@"POST" URLString:[self.endpointURL absoluteString] parameters:payload error:nil];
}

#pragma mark - AFHTTPClient
- (id)proxyWithProtocol:(Protocol *)protocol {
    return [[AFJSONRPCProxy alloc] initWithClient:self protocol:protocol];
}
@end

#pragma mark -
typedef void (^AFJSONRPCProxySuccessBlock)(id responseObject);
typedef void (^AFJSONRPCProxyFailureBlock)(NSError *error);

@interface AFJSONRPCProxy ()
@property (readwrite, nonatomic, strong) ZKAFJSONRPCClient *client;
@property (readwrite, nonatomic, strong) Protocol *protocol;
@end

@implementation AFJSONRPCProxy

- (id)initWithClient:(ZKAFJSONRPCClient*)client
            protocol:(Protocol *)protocol{
    self.client = client;
    self.protocol = protocol;
    
    return self;
}

- (BOOL)respondsToSelector:(SEL)selector {
    struct objc_method_description description = protocol_getMethodDescription(self.protocol, selector, YES, YES);
    return description.name != NULL;
}

- (NSMethodSignature *)methodSignatureForSelector:(__unused SEL)selector {
    // 0: v->RET || 1: @->self || 2: :->SEL || 3: @->arg#0 (NSArray) || 4,5: ^v->arg#1,2 (block)
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:@^v^v"];
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSParameterAssert(invocation.methodSignature.numberOfArguments == 5);
    NSString *RPCMethod = [NSStringFromSelector([invocation selector]) componentsSeparatedByString:@":"][0];
    
    __unsafe_unretained id arguments;
    __unsafe_unretained AFJSONRPCProxySuccessBlock unsafeSuccess;
    __unsafe_unretained AFJSONRPCProxyFailureBlock unsafeFailure;
    
    [invocation getArgument:&arguments atIndex:2];
    [invocation getArgument:&unsafeSuccess atIndex:3];
    [invocation getArgument:&unsafeFailure atIndex:4];
    
    [invocation invoke];
    
    __strong AFJSONRPCProxySuccessBlock strongSuccess = [unsafeSuccess copy];
    __strong AFJSONRPCProxyFailureBlock strongFailure = [unsafeFailure copy];
    
    [self.client invokeMethod:RPCMethod withParameters:arguments success:^(__unused NSURLSessionDataTask *operation, id responseObject) {
        if (strongSuccess) {
            strongSuccess(responseObject);
        }
    } failure:^(__unused NSURLSessionDataTask *operation, NSError *error) {
        if (strongFailure) {
            strongFailure(error);
        }
    }];
}

@end
