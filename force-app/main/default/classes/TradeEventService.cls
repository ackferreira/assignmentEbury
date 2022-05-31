public with sharing class TradeEventService {
    private String LATEST_RATE_CREDENTIAL = '5IAvTHrI45AxOzRrUSLckZGrAO6Ne2F7';
    private String LATEST_RATE_PATH       = 'FixerAPI/latest?symbols={0}&base={1}';
    private Integer DEFAULT_LIMIT         = 10;
    private String MESSAGE_BODY_MODEL     = Label.NewTradeChatterMessage;

    private TradeSelector tradeSelector;
    private SObjectRepository objectRepo;
    private ChatterService chatterService;

    public TradeEventService() {
        this(new SObjectRepository(), new ChatterService());
    }

    public TradeEventService(SObjectRepository objectRepo, ChatterService chatterService) {
        this.tradeSelector = new TradeSelector();
        this.objectRepo = objectRepo;
        this.chatterService = chatterService;
    }

    public void postNewTradeMessageToQueueMembers(List<Id> tradeIds, String queueName) {
        List<Trade__c> trades = this.tradeSelector.getTradesWithIds(tradeIds).getData();
        Set<Id> userIdsToPost = this.getQueueMembersIds(queueName);

        List<String> messages = new List<String>();
        for (Trade__c trade : trades) {
            messages.add(buildMessage(trade));
        }
        chatterService.postMessagesTo(userIdsToPost, messages);
    }

    private Set<Id> getQueueMembersIds(String queueName) {
        Set<Id> userIds = new Set<Id>();
        List<Group> groups = (List<Group>)this.objectRepo.getRecords(
            'SELECT Id FROM Group WHERE Type=\'Queue\' AND DeveloperName=\'' + queueName + '\''
        );
        Set<Id> queuesIds = (new Map<Id, Group>(groups)).keySet();
        List<GroupMember> members = (List<GroupMember>)this.objectRepo.getRecords(
            'SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN (\''+ String.join(new List<Id>(queuesIds),'\',\'') +'\')'
        );
        for (GroupMember member : members) {
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
