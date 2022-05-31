public with sharing class ChatterService {
    private SObjectRepository objectRepo;

    public ChatterService() {
        this(new SObjectRepository());
    }
    
    public ChatterService(SObjectRepository objectRepo) {
        this.objectRepo = objectRepo;
    }

    public void postMessagesTo(Set<Id> userIds, List<String> messages) {
        if (userIds == null || userIds.isEmpty()) {
            throw new ChatterServiceException('User Ids list not provided.');
        }

        if (messages == null || messages.isEmpty()) {
            throw new ChatterServiceException('Messages not provided.');
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
        this.objectRepo.insertRecords(messagesToPost);
    }
    
    public class ChatterServiceException extends Exception {} 
}
