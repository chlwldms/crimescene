public class NotifyDTO {
	private final String msgType = "NOTIFY";
	private String notifyType;
	private String sender;
	private String notifyBody;
	
	public NotifyDTO() {}
	
	public NotifyDTO(String notifyType, String sender, String notifyBody) {
        this.notifyType = notifyType;
        this.sender = sender;
        this.notifyBody = notifyBody;
    }
	
	public String getNotifyType() {
		return notifyType;
	}
	public void setNotifyType(String notifyType) {
		this.notifyType = notifyType;
	}
	public String getSender() {
		return sender;
	}
	public void setSender(String sender) {
		this.sender = sender;
	}
	public String getNotifyBody() {
		return notifyBody;
	}
	public void setNotifyBody(String notifyBody) {
		this.notifyBody = notifyBody;
	}
}
