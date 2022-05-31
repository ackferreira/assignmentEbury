@isTest
private class TradeEventServiceTest {
    @isTest
    private static void postNewTradeMessageToQueueMembers_shouldInvokeMethod() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ChatterService chatterSrvMock = (ChatterService)mocks.mock(ChatterService.class);
        TradeSelector tradeSelectorMock  = (TradeSelector)mocks.mock(TradeSelector.class);
            
        Id tradeId = fflib_IDGenerator.generate(Trade__c.SObjectType);
        Trade__c trade = new Trade__c(
            Id = tradeId
        );
        List<Id> tradesIds = new List<Id>{ tradeId };
        String queueName = 'Test_TradeReviewers';

        mocks.startStubbing();
		mocks.when(tradeSelectorMock.getData()).thenReturn(new List<Trade__c>{ trade });
		mocks.when(tradeSelectorMock.getTradesWithIds(tradesIds)).thenReturn(tradeSelectorMock);
		mocks.stopStubbing();

        // When
        TradeEventService tradeEvtSrv = new TradeEventService(tradeSelectorMock, new SObjectRepository(), chatterSrvMock);
        List<String> messages = new List<String>{ tradeEvtSrv.buildMessage(trade) };
        tradeEvtSrv.postNewTradeMessageToQueueMembers(tradesIds, queueName);
        // Then
        ((ChatterService) mocks.verify(chatterSrvMock, 1))
            .postMessagesTo(new Set<Id>(), messages);
    }

    @isTest
    private static void getQueueMembersIds_shouldReturnUserIds() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SObjectRepository objRepoMock = (SObjectRepository)mocks.mock(SObjectRepository.class);

        Id groupId = fflib_IDGenerator.generate(Group.SObjectType);
        Group myGroup = new Group(
            Id = groupId
        );
        Id userId = fflib_IDGenerator.generate(User.SObjectType);
        GroupMember member = new GroupMember(
            UserOrGroupId = userId
        );
        String queueName = 'Test_TradeReviewers';

        mocks.startStubbing();
		mocks.when(objRepoMock.getRecords(
            'SELECT Id FROM Group WHERE Type=\'Queue\' AND DeveloperName=\'' + queueName + '\''
        )).thenReturn(new List<Group>{ myGroup });
		mocks.when(objRepoMock.getRecords(
            'SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN (\''+ String.join(new List<Id>{groupId},'\',\'') +'\')'
        )).thenReturn(New List<GroupMember>{ member });
		mocks.stopStubbing();

        // When
        TradeEventService tradeEvtSrv = new TradeEventService(new TradeSelector(), objRepoMock, new ChatterService());
        Set<Id> returnIds = tradeEvtSrv.getQueueMembersIds(queueName);
        // Then
        system.assertEquals(new Set<Id>{ userId }, returnIds);
    }
}