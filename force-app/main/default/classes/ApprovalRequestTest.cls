@isTest
private class ApprovalRequestTest {
    @TestSetup
    private static void dataFactory() {
    }

    @isTest
    private static void test01_submit() {
        ProcessDefinition pd = [SELECT Id, DeveloperName FROM ProcessDefinition WHERE Name = ''];
        Account a = new Account(
            Name = 'Test Account #1',
            AnnualRevenue = 100000.00
        );
        insert a;
        Test.startTest();
        ApprovalRequest ar = new ApprovalRequest(pd.Id);
        List<Approval.ProcessResult> submitResults = ar.submit(new List<String>{ a.Id });
        Test.stopTest();
        for (Approval.ProcessResult pr : submitResults) {
            System.assertEquals(true, pr.isSuccess());
        }
    }

    @isTest
    private static void test02_approve() {
        ProcessDefinition pd = [SELECT Id, DeveloperName FROM ProcessDefinition WHERE Name = ''];
        Account a = new Account(
            Name = 'Test Account #2',
            AnnualRevenue = 100000.00
        );
        insert a;
        Test.startTest();
        ApprovalRequest ar = new ApprovalRequest(pd.Id);
        List<Approval.ProcessResult> submitResults  = ar.submit(new List<String>{ a.Id });
        List<Approval.ProcessResult> approveResults = ar.approve(submitResults[0].getNewWorkitemIds());
        Test.stopTest();
        for (Approval.ProcessResult pr : approveResults) {
            System.assertEquals(true, pr.isSuccess());
        }
    }
}
