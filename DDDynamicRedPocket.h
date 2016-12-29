

@interface  WKBizMessage:NSObject
@property(nonatomic,retain) NSString *attachmentsJson;
@end



@interface WKBizConversation:NSObject
@property(nonatomic,retain) WKBizMessage *latestMessage;
@end


@interface DTRedEnvelopServiceFactory:NSObject

+ (DTRedEnvelopServiceFactory *)defaultServiceIMP;
- (void)pickRedEnvelopCluster:(NSInteger)cluster 
					clusterId:(NSString *)clusterId 
					successBlock:(NSString *)suc
					failureBlock:(NSString *)fail;

@end
