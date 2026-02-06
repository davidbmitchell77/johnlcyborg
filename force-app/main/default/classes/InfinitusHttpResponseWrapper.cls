public class InfinitusHttpResponseWrapper {
    public String status       { get; set; }
    public String statusReason { get; set; }

    public static InfinitusHttpResponseWrapper parse(String s) {
        return (InfinitusHttpResponseWrapper)JSON.deserialize(s, InfinitusHttpResponseWrapper.class);
    }
}
