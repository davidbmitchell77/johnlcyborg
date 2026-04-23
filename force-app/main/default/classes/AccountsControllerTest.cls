@isTest
private class AccountsControllerTest {
    @TestSetup
    private static void dataFactory() {
        Account a = new Account(
            Name    = 'Test Account',
            Website = 'test.account.com'
        );
        insert a;
        List<Contact> contacts = new List<Contact>();
        for (Integer i=0; i<10; i++) {
            Contact c = new Contact(
                FirstName = UUID.randomUUID().toString(),
                LastName  = ('0000' + String.valueOf(i + 1)).right(4),
                Phone     = '(000) 000-0000',
                AccountId = a.Id
            );
            contacts.add(c);
        }
        insert contacts;
    }

    @isTest
    private static void test01_getContacts() {
        Account a = [Select Id, Name FROM Account LIMIT 1];
        Test.startTest();
        List<Contact> contacts = AccountsController.getContacts(a.Id);
        Test.stopTest();
        System.assertEquals(10, contacts.size());
    }
}