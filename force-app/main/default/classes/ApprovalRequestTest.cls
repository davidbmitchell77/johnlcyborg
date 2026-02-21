@isTest
private class ApprovalRequestTest {
    @TestSetup
    private static void dataFactory() {
        Account a = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId(),
            Name    = 'Test ' + UUID.randomUUID().toString(),
            Phone   = '(000) 000-0000',
            Website = 'www.foobar.com'
        );
        insert a;
    }

    @isTest
    private static void test01_submit() {
        ProcessDefinition pd = [SELECT Id, DeveloperName FROM ProcessDefinition WHERE DeveloperName = 'BigDiscount'];
        Account a = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity o = new Opportunity(
            Name        = 'Test Opportunity #1',
            StageName   = 'Prospecting',
            CloseDate   = Date.today().addDays(28),
            Amount      = 100000.00,
            Probability = 100,
            Discount__c = 0.26,
            Type        = 'New Business',
            Description = 'FOR TESTING PURPOSES ONLY.',
            AccountId   = a.Id
        );
        insert o;
        Test.startTest();
        ApprovalRequest ar = new ApprovalRequest(pd.DeveloperName);
        List<Approval.ProcessResult> submitResults = ar.submit(new List<String>{ o.Id });
        Test.stopTest();
        for (Approval.ProcessResult pr : submitResults) {
            System.assertEquals(true, pr.isSuccess());
        }
    }

    @isTest
    private static void test02_approve() {
        ProcessDefinition pd = [SELECT Id, DeveloperName FROM ProcessDefinition WHERE DeveloperName = 'BigDiscount'];
        Account a = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity o = new Opportunity(
            Name        = 'Test Opportunity #2',
            StageName   = 'Prospecting',
            CloseDate   = Date.today().addDays(28),
            Amount      = 100000.00,
            Probability = 100,
            Discount__c = 0.26,
            Type        = 'New Business',
            Description = 'FOR TESTING PURPOSES ONLY.',
            AccountId   = a.Id
        );
        insert o;
        Test.startTest();
        ApprovalRequest ar = new ApprovalRequest(pd.DeveloperName);
        List<Approval.ProcessResult> submitResults  = ar.submit(new List<String>{ o.Id });
        List<Approval.ProcessResult> approveResults = ar.approve(submitResults[0].getNewWorkitemIds());
        Test.stopTest();
        for (Approval.ProcessResult pr : approveResults) {
            System.assertEquals(true, pr.isSuccess());
        }
    }
}