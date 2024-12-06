public class ResponseDTO {
	private final String msgType = "RESPONSE";
	private String responseType;
	private String sender;
	private String responseBody;
	
	public ResponseDTO() {}
	
	public ResponseDTO(String responseType, String sender, String responseBody) {
        this.responseType = responseType;
        this.sender = sender;
        this.responseBody = responseBody;
    }
	
	public String getResponseType() {
		return responseType;
	}
	public void setResponseType(String responseType) {
		this.responseType = responseType;
	}
	public String getSender() {
		return sender;
	}
	public void setSender(String sender) {
		this.sender = sender;
	}
	public String getResponseBody() {
		return responseBody;
	}
	public void setResponseBody(String responseBody) {
		this.responseBody = responseBody;
	}
}
