public class ApprovalRequest {
    private final String processNameOrId;
    private final String apexClassName;

    public ApprovalRequest(String s) {
        this.processNameOrId = s;
        this.apexClassName   = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }

    public List<Approval.ProcessResult> submit(List<String> recordIds) {
        List<Approval.ProcessResult> results = new List<Approval.ProcessResult>();
        for (String recordId : recordIds) {
            results.add(submit(recordId));
        }
        return results;
    }

    public Approval.ProcessResult submit(String recordId) {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(recordId);
        req.setProcessDefinitionNameOrId(this.processNameOrId);
        req.setSubmitterId(UserInfo.getUserId());
        req.setSkipEntryCriteria(Test.isRunningTest() ? true : false);
        req.setComments(System.Label.SUBMITTING_REQUEST_FOR_APPROVAL);
        Approval.ProcessResult result = Approval.process(req);
        System.debug((result.isSuccess() ? LoggingLevel.INFO : LoggingLevel.ERROR), (this.apexClassName + ' approval request status: ' + result.getInstanceStatus()));
        return result;
    }

    public List<Approval.ProcessResult> approve(List<String> workItemIds) {
        List<Approval.ProcessResult> results = new List<Approval.ProcessResult>();
        for (Id wid : workItemIds) {
            results.add(approve(wid));
        }
        return results;
    }

    public Approval.ProcessResult approve(String workItemId) {
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction('Approve');
        req.setNextApproverIds(new List<Id>{ UserInfo.getUserId() });
        req.setComments(System.Label.APPROVING_REQUEST);
        req.setWorkitemId(workItemId);
        Approval.ProcessResult result = Approval.process(req);
        System.debug((result.isSuccess() ? LoggingLevel.INFO : LoggingLevel.ERROR), (this.apexClassName + ' approval request status: ' + result.getInstanceStatus()));
        return result;
    }
}