@isTest
private class ChatterServiceTest {
    @isTest
    private static void postMessagesTo_shouldInsert() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SObjectRepository sObjectRepoMock = 
            (SObjectRepository)mocks.mock(SObjectRepository.class);
            
        Id userId = fflib_IDGenerator.generate(User.SObjectType);
        Set<Id> userIds = new Set<Id>{ userId };
        List<String> msgs = new List<String>{ 'message' };
        List<FeedItem> listMock = new List<FeedItem>{new FeedItem(
            ParentId = userId,
            Body = msgs[0]
        )};     
        // When
        ChatterService chatterSrv = new ChatterService(sObjectRepoMock);
        chatterSrv.postMessagesTo(userIds, msgs);
        // Then
        ((SObjectRepository) mocks.verify(sObjectRepoMock, 1))
            .insertRecords(listMock);
    }
    
    @isTest
    private static void postMessagesTo_nullUserIds_shouldThrowException() {
        ChatterService chatterSrv = new ChatterService();
        List<String> msgs = new List<String>{ 'message' };
        try {
            chatterSrv.postMessagesTo(null, msgs);
        }
        catch(Exception ex) {
            system.assertEquals('User Ids list not provided.', ex.getMessage());
        }
    }
    
    @isTest
    private static void postMessagesTo_nullMessage_shouldThrowException() {
        ChatterService chatterSrv = new ChatterService();
        Id userId = fflib_IDGenerator.generate(User.SObjectType);
        Set<Id> userIds = new Set<Id>{ userId };
        try {
            chatterSrv.postMessagesTo(userIds, null);
        }
        catch(Exception ex) {
            system.assertEquals('Messages not provided.', ex.getMessage());
        }
    }
}