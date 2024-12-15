import java.io.*;
import java.net.*;
import java.util.List;
import com.google.gson.*;

public class ClientThread extends Thread {
	private boolean running = true;
	private Socket sock;
	private List<ClientThread> clientList;
	private String clientName, role, job;
	private ServerMain server;
	private int voteCount = 0;
	
	private BufferedReader in;
	private PrintWriter out;
	Gson gson = new Gson();

	//Constructor to make new thread object.
	public ClientThread(Socket sock, List<ClientThread> clientList, ServerMain server) {
		this.sock = sock;
		this.clientList = clientList;
		this.server = server;
		
		try {
	        this.sock.setSoTimeout(5000);	// 의도적인 소켓 타임아웃 지정입니다!!(커넥션 확인용)
	    } catch (SocketException e) {
	        e.printStackTrace();
	    }
	}

	public void run() {
        System.out.println("New connection socket and client handler thread successfully established!");

        try {
            in = new BufferedReader(new InputStreamReader(sock.getInputStream(), "UTF-8"));
            out = new PrintWriter(new OutputStreamWriter(sock.getOutputStream(), "UTF-8"), true);
            handleClient();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (sock != null && !sock.isClosed()) sock.close();
                if (in != null) in.close();
                if (out != null) out.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
	
	private void handleClient() throws Exception {
	    RequestHandler requestHandler = new RequestHandler(this, server, clientList);

	    while (running) {
	        try {
	            String receivedJson = in.readLine();
	            if (receivedJson == null) {
	                System.out.println("Client disconnected.");
	                break;
	            }
	            RequestDTO req = gson.fromJson(receivedJson, RequestDTO.class);
	            requestHandler.fetchRequest(req);
	            requestHandler.processResponse();
	        } catch (SocketTimeoutException e) {
	            System.err.println("Socket read timed out, checking running state...");
	        } catch (JsonSyntaxException e) {
	            System.err.println("Invalid JSON received.");
	        } catch (IOException e) {
	            System.err.println("Error in communication: " + e.getMessage());
	            break;
	        } catch (Exception e) {
	            System.err.println("Error processing request: " + e.getMessage());
	        }
	    }
	}

	
	public synchronized void sendNotify(NotifyDTO noti) {
		try {
			if(out != null) {
				String json = gson.toJson(noti);
				out.println(json);
				out.flush();
			}
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	
	public synchronized void sendResponse(ResponseDTO res) {
		try {
			if(out != null) {
				String json = gson.toJson(res);
				out.println(json);
				out.flush();
			}
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	
	// 여기에도 Synchronized 추가하면 Deadlock 발생 가능성 존재!
	public void broadcast(NotifyDTO noti) {
		for(ClientThread client : clientList) {
			if(client != this) {
				client.sendNotify(noti);
			}
		}
	}
	
	public void setClientName(String name) {
		this.clientName = name;
	}
	public String getClientName() {
		return this.clientName;
	}
	public void setRole(String role) {
		this.role = role;
	}
	public String getRole() {
		return this.role;
	}
	public void setJob(String job) {
		this.job = job;
	}
	public String getJob() {
		return this.job;
	}
	public int getVoteCount(){
		return this.voteCount;
	}
	
	public synchronized void addVoteCount() {
		this.voteCount ++;
	}
	
	public void stopThread() {
	    running = false;
	}
}
