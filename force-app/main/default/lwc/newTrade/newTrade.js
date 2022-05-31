import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRates from '@salesforce/apex/TradesViewController.getRates';
import publishTradeEvent from '@salesforce/apex/TradesViewController.publishTradeEvent';
import TRADE_OBJECT from '@salesforce/schema/Trade__c';
import SELL_CURRENCY from '@salesforce/schema/Trade__c.SellCurrency__c';
import BUY_CURRENCY from '@salesforce/schema/Trade__c.BuyCurrency__c';
import SELL_AMOUNT from '@salesforce/schema/Trade__c.SellAmount__c';
import BUY_AMOUNT from '@salesforce/schema/Trade__c.BuyAmount__c';
import RATE from '@salesforce/schema/Trade__c.Rate__c';

const ERROR_VARIANT = 'error';
const SUCCESS_VARIANT = 'success';

export default class NewTrade extends LightningElement {
    sellCurrencyOptions;
    buyCurrencyOptions;
    tradeObject       = TRADE_OBJECT;
    sellCurrencyField = SELL_CURRENCY;
    buyCurrencyField  = BUY_CURRENCY;
    sellAmountField   = SELL_AMOUNT;
    buyAmountField    = BUY_AMOUNT;
    rateField         = RATE;

    isLoading = true;
    rates = {};

    selectedSellCurrency;
    selectedBuyCurrency;

    async handleCurrencyChange(event) {
        if (event.target.name == 'sellCurrency') {
            await this.handleAvailableRate(event.detail.value);
            this.selectedSellCurrency = event.detail.value;
        }
        else if (event.target.name == 'buyCurrency') {
            this.selectedBuyCurrency = event.detail.value;
        }
        this.calculateRate();
        this.calculateBuyAmount();
    }

    async handleAvailableRate(baseCurrency) {
        if (this.rates[baseCurrency]) {
            return;
        }
        else {
            await this.getRatesForBaseCurrency(baseCurrency);
        }
    }

    async getRatesForBaseCurrency(baseCurrency) {
        this.isLoading = true;
        try {
            let ratesForCurrency = await getRates({
                baseCurrency: baseCurrency
            });

            this.rates[baseCurrency] = ratesForCurrency.map(rate => {
                let crryRate = {};
                crryRate[rate.toCurrency] = rate.value;
                return crryRate;
            });
        }
        catch (ex) {
            let errorMessage = 'Error retrieving rates for selected Currency';
            this.toastMessage(`${errorMessage} - ${ex.body.message}`, 'ERROR', ERROR_VARIANT);
            console.log(e);
        }
        finally {
            this.isLoading = false;
        }
    }

    async sendTradeEvent(tradeId) {
        try {
            let eventBusId = await publishTradeEvent({
                tradeId: tradeId
            });
            console.log('sendTradeEvent', eventBusId);
            return eventBusId;
        }
        catch (ex) {
            let errorMessage = 'Error publishing event';
            this.toastMessage(`${errorMessage} - ${ex.body.message}`, 'ERROR', ERROR_VARIANT);
            console.log(ex);
        }
        finally {
            this.isLoading = false;
        }
    }
    
    async handleSaveSuccess(event) {
        this.isLoading = true;
        this.toastMessage('Trade saved with success!', 'Success', SUCCESS_VARIANT);

        await this.sendTradeEvent(event.detail.id);
        
        const saveTrade = new CustomEvent('save');
        this.dispatchEvent(saveTrade);
    }

    handleSellAmountChange() {
        this.calculateBuyAmount();
    }

    calculateRate() {
        let rate = 0;
        this.rates[this.selectedSellCurrency]?.forEach(curr => {
            if (curr[this.selectedBuyCurrency]) {
                rate = curr[this.selectedBuyCurrency];
            }
        });
        this.updateFormValue('rate', rate);
    }

    calculateBuyAmount() {
        let sellAmount, rate;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if (element.name == 'sellAmount') {
                sellAmount = element.value;
            }
            else if (element.name == 'rate') {
                rate = element.value;
            }
        });
        this.updateFormValue('buyAmount', rate*sellAmount);
    }
    
    closeModal() {
        const finishModal = new CustomEvent('finishmodal');
        this.dispatchEvent(finishModal);
    }

    handleFormLoad() {
        this.isLoading = false;
    }

    updateFormValue(elementName, value) {
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if (element.name == elementName) {
                element.value = value;
            }
        });
    }

    toastMessage(message, title, eventVariant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: eventVariant
        });
        this.dispatchEvent(event);
    }
}