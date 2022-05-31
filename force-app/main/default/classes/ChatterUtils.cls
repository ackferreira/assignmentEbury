public with sharing class ChatterUtils {
    public static void postMessagesTo(Set<Id> userIds, List<String> messages) {
        if (userIds == null || userIds.isEmpty()) {
            throw new ChatterUtilsException('User Ids list not provided.');
        }

        if (messages == null || messages.isEmpty()) {
            throw new ChatterUtilsException('Messages not provided.');
        }

        List<FeedItem> messagesToPost = new List<FeedItem>();
        for (String message : messages) {
            for (Id userId : userIds) {
                messagesToPost.add(new FeedItem(
                    ParentId = userId,
                    Body = message
                ));
            }
        }
        insert messagesToPost;
    }
    
    public class ChatterUtilsException extends Exception {} 
}
