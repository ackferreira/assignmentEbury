public with sharing class SObjectRepository {

    public List<sObject> getRecords(String query) {
        return Database.query(query);
    }
    public void insertRecords(List<SObject> records) {
        insert records;
    }
    public void updateRecords(List<SObject> records) {
        update records;
    }
}
