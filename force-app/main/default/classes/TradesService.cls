public with sharing class TradesService {
    private String LATEST_RATE_CREDENTIAL = '5IAvTHrI45AxOzRrUSLckZGrAO6Ne2F7';
    private String LATEST_RATE_PATH       = 'FixerAPI/latest?symbols={0}&base={1}';

    private TradeSelector tradeSelector;

    public TradesService() {
        this(new TradeSelector());
    }

    public TradesService(TradeSelector tradeSelector) {
        this.tradeSelector = tradeSelector;
    }

    public List<Trade__c> getTrades(Integer limitOf) {
        return tradeSelector.getOrderByCreatedDateDesc().getWithLimit(limitOf).getData();
    }

    public LatestRates getLatestRates(String baseCurrency, List<String> currencies) {
        String namedCredentialPath = String.format(LATEST_RATE_PATH, new List<Object>{ String.join(currencies, ','), baseCurrency });
        Map<String, String> mapHeader =  new Map<String, String>{ 'apikey' => LATEST_RATE_CREDENTIAL };

        HTTPResponse res = RestHttpRequester.send('GET', namedCredentialPath, null, mapHeader);

        if (res.getStatusCode() == 200) {
            return new LatestRates(res.getBody());
        }
        throw new TradesServiceException('Error retrieving latest trades');
    }

    public class LatestRates {
        private String baseCurrency;
        private Date rateDate;
        private List<Rate> rates;
        private String success;
        private String timestamp;

        public LatestRates(String bodyLatestRates) {
            Map<String, Object> latestRatesMap  = (Map<String, Object>)JSON.deserializeUntyped(bodyLatestRates);
            Map<String, Object> currenciesRates = (Map<String, Object>)latestRatesMap.get('rates');

            this.baseCurrency = (String)latestRatesMap.get('base');
            this.rateDate     = Date.valueOf((String)latestRatesMap.get('date'));

            for (String currencyName : currenciesRates.keySet()) {
                if (this.rates == null) {
                    this.rates = new List<Rate>();
                }
                this.rates.add(new Rate(currencyName, (Double)currenciesRates.get(currencyName)));
            }
        }
    }

    public class Rate {
        private String currencyName;
        private Double rate;

        public Rate(String currencyName, Double rate) {
            this.currencyName = currencyName;
            this.rate = rate;
        }
    }

    public class TradesServiceException extends Exception {} 
}
