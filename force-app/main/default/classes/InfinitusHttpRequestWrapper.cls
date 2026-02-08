public class InfinitusHttpRequestWrapper {
    public rd RequestDetails        { get; set; }
    public pd PatientDetails        { get; set; }
    public ii InsuranceInformation  { get; set; }
    public pi ProviderInformation   { get; set; }
    public sd ServiceDetails        { get; set; }

    public class rd {
        public String requestId     { get; set; }
        public String requestDate   { get; set; }
    }

    public class pd {
        public String firstName     { get; set; }
        public String lastName      { get; set; }
        public String dateOfBirth   { get; set; }
        public String gender        { get; set; }
    }

    public class ii {
        public String providerName  { get; set; }
        public String policyNumber  { get; set; }
        public String groupNumber   { get; set; }
        public String subscriberId  { get; set; }
    }

    public class pi {
        public String npi           { get; set; }
        public String firstName     { get; set; }
        public String lastName      { get; set; }
    }

    public class sd {
        public String serviceType   { get; set; }
        public String serviceDate   { get; set; }
        public String diagnosisCode { get; set; }
        public String procedureCode { get; set; }
    }

    public InfinitusHttpRequestWrapper() {
        this.RequestDetails       = new rd();
        this.PatientDetails       = new pd();
        this.InsuranceInformation = new ii();
        this.ProviderInformation  = new pi();
        this.ServiceDetails       = new sd();
    }
}