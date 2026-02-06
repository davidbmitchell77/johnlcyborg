public class InfinitusHttpRequestWrapper {
    public RequestDetails rd       { get; set; }
    public PatientDetails pd       { get; set; }
    public InsuranceInformation ii { get; set; }
    public ProviderInformation pi  { get; set; }
    public ServiceDetails sd       { get; set; }

    public class RequestDetails {
        public String requestId     { get; set; }
        public String requestDate   { get; set; }
    }

    public class PatientDetails {
        public String firstName     { get; set; }
        public String lastName      { get; set; }
        public String dateOfBirth   { get; set; }
        public String gender        { get; set; }
    }

    public class InsuranceInformation {
        public String providerName  { get; set; }
        public String policyNumber  { get; set; }
        public String groupNumber   { get; set; }
        public String subscriberId  { get; set; }
    }

    public class ProviderInformation {
        public String npi           { get; set; }
        public String firstName     { get; set; }
        public String lastName      { get; set; }
    }

    public class ServiceDetails {
        public String serviceType   { get; set; }
        public String serviceDate   { get; set; }
        public String diagnosisCode { get; set; }
        public String procedureCode { get; set; }
    }

    public InfinitusHttpRequestWrapper() {
        this.rd = new RequestDetails();
        this.pd = new PatientDetails();
        this.ii = new InsuranceInformation();
        this.pi = new ProviderInformation();
        this.sd = new ServiceDetails();
    }
}