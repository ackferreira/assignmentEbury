@isTest
private class NewTradeEventTest {
    @isTest
    private static void insertEvent_shouldinsertEvents() {
        Id tradeId = fflib_IDGenerator.generate(Trade__c.SObjectType);
        List<Id> tradeIds = new List<Id>{tradeId};
        NewTradeEvent__e newEvent = new NewTradeEvent__e(
            EventBody__c = JSON.serialize(tradeIds)
        );
        Test.startTest();
        Database.SaveResult eventResult = EventBus.publish(newEvent);
        Test.stopTest();
        System.assertEquals(true, eventResult.isSuccess());
    }
}
