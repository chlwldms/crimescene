public class RequestDTO {
	private String requestType;
	private String sender;
	private String requestBody;
	
	public RequestDTO() {}
	
	public RequestDTO(String requestType, String sender, String requestBody) {
        this.requestType = requestType;
        this.sender = sender;
        this.requestBody = requestBody;
    }
	
	public String getRequestType() {
		return requestType;
	}
	public void setRequestType(String requestType) {
		this.requestType = requestType;
	}
	public String getSender() {
		return sender;
	}
	public void setSender(String sender) {
		this.sender = sender;
	}
	public String getRequestBody() {
		return requestBody;
	}
	public void setRequestBody(String requestBody) {
		this.requestBody = requestBody;
	}
}
