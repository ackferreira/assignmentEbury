public with sharing class TradeEventService {
    private String LATEST_RATE_CREDENTIAL = '5IAvTHrI45AxOzRrUSLckZGrAO6Ne2F7';
    private String LATEST_RATE_PATH       = 'FixerAPI/latest?symbols={0}&base={1}';
    private Integer DEFAULT_LIMIT         = 10;
    private String MESSAGE_BODY_MODEL     = Label.NewTradeChatterMessage;

    private TradeSelector tradeSelector;

    public TradeEventService() {
        this.tradeSelector = new TradeSelector();
    }

    public void postNewTradeMessageToQueueMembers(List<Id> tradeIds, String queueName) {
        List<Trade__c> trades = this.tradeSelector.getTradesWithIds(tradeIds).getData();
        Set<Id> userIdsToPost = this.getQueueMembersIds(queueName);

        List<String> messages = new List<String>();
        for (Trade__c trade : trades) {
            messages.add(buildMessage(trade));
        }
        ChatterUtils.postMessagesTo(userIdsToPost, messages);
    }

    private Set<Id> getQueueMembersIds(String queueName) {
        Set<Id> userIds = new Set<Id>();
        Map<Id, Group> queues = new Map<Id, Group>([SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName=:queueName]);
        for (GroupMember member : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN :queues.keySet()]) {
            userIds.add(member.UserOrGroupId);
        }
        return userIds;
    }

    private String buildMessage(Trade__c trade) {
        List<Object> msgInfo = new List<Object>{
            trade.SellCurrency__c,
            trade.SellAmount__c.format(),
            trade.BuyCurrency__c,
            trade.BuyAmount__c.format(),
            trade.Rate__c.format(),
            Trade.CreatedDate.format(),
            URL.getSalesforceBaseUrl().toExternalForm() + '/' + trade.Id
        };
        return String.format(MESSAGE_BODY_MODEL, msgInfo);
    }
}
