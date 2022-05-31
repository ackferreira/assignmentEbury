trigger NewTradeEvent on NewTradeEvent__e (after insert) {
    new NewTradeEventHandler().run();
}