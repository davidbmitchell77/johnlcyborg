@isTest
private class ApprovalRequestTest_v2 {
    @TestSetup
    private static void dataFactory() {
        String convertedStatus = [SELECT ApiName FROM LeadStatus WHERE IsConverted = true LIMIT 1].ApiName;
        String defaultStatus   = [SELECT ApiName FROM LeadStatus WHERE IsDefault = true LIMIT 1].ApiName;
        Lead l = new Lead(
            FirstName     = 'Test',
            LastName      = 'Customer',
            Company       = 'Test Company Inc.',
            Phone         = '(000) 000-0000',
            Email         = 'test.customer@testcompany.com',
            Website       = 'www.testcompany.com',
            AnnualRevenue = 100000.00,
            Description   = UUID.randomUUID().toString(),
            Status        = defaultStatus
        );
        insert l;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus(convertedStatus);
        lc.setDoNotCreateOpportunity(false);
        lc.setOpportunityName(l.Company);
        for (Database.LeadConvertResult lcr : Database.convertLead(new List<Database.LeadConvert>{ lc }, false)) {
            if (!lcr.isSuccess()) {
                for (Database.Error e : lcr.getErrors()) {
                    System.debug(LoggingLevel.Error, ('OpportunityTriggerTest.dataFactory: ' + e.getStatusCode() + '|' + e.getMessage()));
                }
            }
        }
        Opportunity o = [SELECT Id, Name FROM Opportunity LIMIT 1];
        o.Amount      = l.AnnualRevenue;
        o.Probability = 100;
        o.Discount__c = 0.37;
        update o;
    }

    @isTest
    private static void test01_submit() {
        ProcessDefinition pd = [SELECT Id, DeveloperName
                                  FROM ProcessDefinition
                                 WHERE Type = 'Approval'
                                   AND TableEnumOrId = 'Opportunity'
                                   AND State = 'Active'
                                 LIMIT 1
        ];
        Opportunity o = [SELECT Id, Name FROM Opportunity LIMIT 1];
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
        ProcessDefinition pd = [SELECT Id, DeveloperName
                                  FROM ProcessDefinition
                                 WHERE Type = 'Approval'
                                   AND TableEnumOrId = 'Opportunity'
                                   AND State = 'Active'
                                 LIMIT 1
        ];
        Opportunity o = [SELECT Id, Name FROM Opportunity LIMIT 1];
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
