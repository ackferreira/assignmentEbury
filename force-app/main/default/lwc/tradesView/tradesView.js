import { LightningElement, wire } from 'lwc';
import getTrades from '@salesforce/apex/TradesViewController.getTrades';
import { refreshApex } from '@salesforce/apex';

export default class TradesView extends LightningElement {
    columns = [
        { label: 'Sell CCY', fieldName: 'SellCurrency__c', type: 'text' },
        { label: 'Sell Amount', fieldName: 'SellAmount__c', type: 'number', typeAttributes: { minimumFractionDigits:'2' } },
        { label: 'Buy CCY', fieldName: 'BuyCurrency__c', type: 'text' },
        { label: 'Buy Amount', fieldName: 'BuyAmount__c', type: 'number', typeAttributes: { minimumFractionDigits:'2' } },
        { label: 'Rate', fieldName: 'Rate__c', type: 'number', typeAttributes: { minimumFractionDigits:'4' } },
        { label: 'Date booked', fieldName: 'CreatedDate', type: 'date', typeAttributes: { year:"numeric", month:"numeric", day:"numeric", hour:"2-digit", minute:"2-digit" } }
    ];

    pageSize = 20;
    wiredTrades;
    trades;

    @wire(getTrades, {limitOf: '$pageSize'})
    wiredTrades( result ) {
        this.trades = result;
    }
}