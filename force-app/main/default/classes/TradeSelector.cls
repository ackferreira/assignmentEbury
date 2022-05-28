public class TradeSelector {
    private String query;
    private Set<String> fields;
    private String conditions;
    private String orderBy;
    private Integer limitOf;

    private static Set<String> DEFAULT_FIELDS = new Set<String>{
        'Id',
        'BuyAmount__c',
        'BuyCurrency__c',
        'CreatedDate',
        'Rate__c',
        'SellAmount__c',
        'SellCurrency__c',
        'Name'
    };

    public TradeSelector () {
        this(DEFAULT_FIELDS);
    }

    public TradeSelector (Set<String> fields) {
        this.fields = fields;
        this.query = 'SELECT ';
    }

    public TradeSelector getOrderByCreatedDateDesc() {
        orderBy = orderBy == null ? 'CreatedDate DESC' : orderBy + ', CreatedDate DESC';
        return this;
    }

    public TradeSelector getWithLimit(Integer limitOf) {
        this.limitOf = limitOf;
        return this;
    }

    public String buildQuery() {
        query += String.join(new List<String>( this.fields ), ',') + ' FROM Trade__c';
        if (this.conditions != null) {
            query += ' WHERE ' + this.conditions;
        }

        if (this.orderBy != null) {
            query += ' ORDER BY ' + this.orderBy;
        }

        if (this.limitOf != null) {
            query += ' LIMIT ' + this.limitOf;
        }
        return this.query;
    }

    public List<Trade__c> getData() {
        try {
            return (List<Trade__c>) Database.query( this.buildQuery() );
        }
        catch(Exception ex) {
            throw new SelectorException('Error retrieving trade: ' + ex.getMessage() + ex.getStackTraceString());
        }
    }

    public class SelectorException extends Exception {} 
}
