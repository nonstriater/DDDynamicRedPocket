/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.
*/

#import "DDDynamicRedPocket.h"

%hook  DTConversationListDataSource

-  (void)controller:(id)controller
    didChangeObject:(id)conversation
            atIndex:(NSInteger)index
      forChangeType:(NSInteger)type
           newIndex:(NSUInteger)newIndex {
    
    %log((NSString *)@"[DDDynamicRedPocket] hook !!!");

    if (![conversation isKindOfClass:%c(WKBizConversation)]){
        %log(@"[DDDynamicRedPocket] conversation is %@ not WKBizConversation class",conversation);
        %orig;
        return;
    }
    
    WKBizMessage *latestMessage = [(WKBizConversation *)conversation latestMessage];
    NSString *attachmentsJson = latestMessage.attachmentsJson;
    
    if ([attachmentsJson length] == 0){
        %log(@"[DDDynamicRedPocket] attachmentsJson is nil");
        %orig;
        return;
    }
    
    NSData *data = [attachmentsJson dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        %log(@"[DDDynamicRedPocket] nil after attachmentsJson convert to data .attachmentsJson = %@", attachmentsJson);
        %orig;
        return;
    }
    
    NSDictionary *rpMsg = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if(![rpMsg isKindOfClass:NSDictionary.class]){
    	%log(@"[DDDynamicRedPocket] attachs is not NSDictionary after JSONSerialization,It may not a red pocket message:%@", attachmentsJson);
    	%orig;
    	return;

    }

    int msgType = [rpMsg[@"contentType"] integerValue];
    if (msgType != 901 && msgType != 902 && msgType != 905){
    	%log(@"[DDDynamicRedPocket] it's not a red pocket message:%@", attachmentsJson);
    	%orig;
    	return;
    }

    NSArray *attachs = rpMsg[@"attachments"];
    if(![attachs isKindOfClass:NSArray.class]){
    	%log(@"[DDDynamicRedPocket] attachments is not a NSArray Type:%@", attachmentsJson);
    	%orig;
    	return;
    }
    
    if(attachs.count == 0){
    	%log(@"[DDDynamicRedPocket] attachments is empty:%@", attachmentsJson);
    	%orig;
    	return;
    }

    NSDictionary *pockee = attachs[0];
    if (![pockee isKindOfClass:NSDictionary.class]) {
        %log(@"[DDDynamicRedPocket] first obj in attachs not a NSDictionary Type, but a %@", pockee);
        %orig;
        return;
    }
    
    NSDictionary *extension = pockee[@"extension"];
    if (![extension isKindOfClass:NSDictionary.class]) {
        %log(@"[DDDynamicRedPocket] attachments[0]->extension is not a NSDictionary Type, but a %@", pockee);
        %orig;
        return;
    }

    %log(@"[DDDynamicRedPocket] !!!!! GET red pocket !!!!!! \n %@ ", attachmentsJson);
    NSString *clusterId = extension[@"clusterid"];
	NSInteger sender = [extension[@"sid"] integerValue];
    [[%c(DTRedEnvelopServiceFactory) defaultServiceIMP] pickRedEnvelopCluster:sender clusterId:clusterId successBlock:nil failureBlock:nil];

    %orig;
}

%end

