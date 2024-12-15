import java.util.List;

import com.google.gson.*;

public class RequestHandler {
	private String requestType;
	private String requestBody;
	private String requestSender;
	private ClientThread t;
	private List<ClientThread> clientList;
	private ServerMain server;
	private EvidenceFetcher e;
	
	public RequestHandler(ClientThread t, ServerMain server, List<ClientThread> clientList) {
		this.t = t;
		this.server = server;
		this.clientList = clientList;
		e = new EvidenceFetcher(server.getCriminalName());
	}
	
	public void fetchRequest(RequestDTO req) {
		this.requestType = req.getRequestType();
		this.requestBody = req.getRequestBody();
		this.requestSender = req.getSender();
	}
	
	public void processResponse() {
	    ResponseDTO res = new ResponseDTO();
	    NotifyDTO noti = new NotifyDTO();
	    Gson gson = new Gson();

	    try {
	        // 공통 유효성 검사
	        validateRequestBody(requestType, requestBody);

	        switch (requestType) {
	            case "CHAT":
	                res.setResponseType("ACK");
	                res.setResponseBody(null);
	                res.setSender("SERVER");

	                noti.setNotifyType("CHAT");
	                noti.setNotifyBody(requestBody);
	                noti.setSender(requestSender);

	                t.sendResponse(res);
	                t.broadcast(noti);
	                break;

	            case "SETNAME":
	                res.setResponseType("ACK");
	                res.setResponseBody(requestBody);
	                res.setSender("SERVER");
	                t.setClientName(requestBody);
	                t.sendResponse(res);
	                break;

	            case "GETEVIDENCE":
	                String[] parts = requestBody.split("/");
	                if (parts.length != 3) throw new IllegalArgumentException("Invalid GETEVIDENCE format.");

	                String evidence = e.fetchEvidence(parts[0], parts[1], Integer.parseInt(parts[2]));
	                if (evidence == null) throw new IllegalArgumentException("Evidence not found.");

	                res.setResponseType("EVIDENCE");
	                res.setResponseBody(evidence);
	                res.setSender("SERVER");
	                t.sendResponse(res);
	                break;

	            case "GETROLE":
	                res.setResponseType("YOURROLE");
	                res.setResponseBody(t.getRole());
	                res.setSender("SERVER");
	                t.sendResponse(res);
	                break;

	            case "GETJOB":
	                res.setResponseType("YOURJOB");
	                res.setResponseBody(t.getJob());
	                res.setSender("SERVER");
	                t.sendResponse(res);
	                break;

	            case "GETCRIMINAL":
	                res.setResponseType("CRIMINAL");
	                res.setResponseBody(server.getCriminalName());
	                res.setSender("SERVER");
	                t.sendResponse(res);
	                break;
	                
	            case "VOTE":
	                boolean validVote = false;
	                for (ClientThread temp : clientList) {
	                    if (requestBody.equals(temp.getRole())) {
	                        temp.addVoteCount();
	                        validVote = true;
	                    }
	                }
	                if (!validVote) throw new IllegalArgumentException("Invalid vote target.");
	                
	                server.addVoteCompleteCount();
	                res.setResponseType("ACK");
	                res.setResponseBody(null);
	                res.setSender("SERVER");
	                t.sendResponse(res);
	                break;

	            case "VOTETIMEOUT":
	                server.addVoteCompleteCount();
	                break;

	            default:
	                throw new IllegalArgumentException("Unsupported request type.");
	        }
	    } catch (Exception e) {
	        System.err.println("Error processing request: " + e.getMessage());

	        res.setResponseType("BADREQUEST");
	        res.setResponseBody("Error: " + e.getMessage());
	        res.setSender("SERVER");
	        t.sendResponse(res);
	    }
	}
	
	private void validateRequestBody(String requestType, String requestBody) throws IllegalArgumentException {
	    switch (requestType) {
	        case "CHAT":
	            if (requestBody == null || requestBody.trim().isEmpty()) {
	                throw new IllegalArgumentException("Chat message cannot be empty.");
	            }
	            break;

	        case "SETNAME":
	            if (requestBody == null || requestBody.trim().isEmpty()) {
	                throw new IllegalArgumentException("Name cannot be empty.");
	            }
	            break;

	        case "GETEVIDENCE":
	            if (requestBody == null || !requestBody.matches(".+/\\w+/\\d+")) {
	                throw new IllegalArgumentException("Invalid GETEVIDENCE format. Expected: location/entity/targetID.");
	            }
	            break;

	        case "VOTE":
	            if (requestBody == null || requestBody.trim().isEmpty()) {
	                throw new IllegalArgumentException("Vote target cannot be empty.");
	            }
	            break;
	            
	        default:
	            break;
	    }
	}


}
