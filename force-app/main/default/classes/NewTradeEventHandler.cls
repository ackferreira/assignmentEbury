public with sharing class NewTradeEventHandler extends TriggerHandler {
    private String TRADE_REVIEWERS_QUEUE = 'TradeReviewers';
    private TradeEventService tradeEventService;

    public NewTradeEventHandler() {
        this.tradeEventService = new TradeEventService();
    }

    public override void afterInsert() {
        List<Id> tradeIds = new List<Id>();
        for (NewTradeEvent__e trade : (List<NewTradeEvent__e>) Trigger.new) {
            tradeIds.addAll((List<Id>)JSON.deserialize(trade.EventBody__c, List<Id>.class));
        }
        this.tradeEventService.postNewTradeMessageToQueueMembers(tradeIds, TRADE_REVIEWERS_QUEUE);
    }
}
