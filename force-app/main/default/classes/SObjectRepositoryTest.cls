@isTest
private class SObjectRepositoryTest {
    @isTest
    private static void insertRecords_shouldHaveId() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'test')
        };
        SObjectRepository objRepo = new SObjectRepository();
        objRepo.insertRecords(accounts);
        system.assertNotEquals(null, accounts[0].Id);
    }

    @isTest
    private static void updateRecords_shouldUpdateName() {
        SObjectRepository objRepo = new SObjectRepository();
        List<Account> accounts = new List<Account>{
            new Account(Name = 'test')
        };
        objRepo.insertRecords(accounts);

        accounts[0].Name = 'test2';
        objRepo.updateRecords(accounts);

        List<Account> accountsFromDB = objRepo.getRecords('SELECT Id, Name FROM Account WHERE Id = \'' + accounts[0].Id + '\'');
        system.assertEquals('test2', accountsFromDB[0].Name);
    }
}