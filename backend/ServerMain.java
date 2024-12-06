import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class ServerMain {
	static List<ClientThread> clientList = Collections.synchronizedList(new ArrayList<ClientThread>());
	private int threadCount = 0, voteCompleteCount = 0, evidenceCompleteCount = 0;
	private final int MAX_PLAYERS = 5;
	private int criminalIndex, detectiveIndex;
	private String criminalName, CauseofDeath;
	
	public void startServer(int port) {
		try(ServerSocket servSock = new ServerSocket(port)){
			System.out.println("Server initiated on port " + port + ". Waiting new connection...");
			
			while(true) {
				if(threadCount == MAX_PLAYERS) {
					System.out.println("All players connected, starting game...");
					break;
				}

				Socket connectionSock = servSock.accept();
				System.out.println("New connection request arrived!");

				ClientThread t = new ClientThread(connectionSock, clientList, this);
				clientList.add(t);
				threadCount ++;
				t.start();
			}
			startGame();
		} catch(IOException e) {
			e.printStackTrace();
		}
	}
	
	private void startGame() {
		NotifyDTO noti = new NotifyDTO();
		// Initial role, job setup. After that, notify.
		gameInitialSetup();
		noti.setNotifyType("GAMEREADY");
		noti.setSender("SERVER");
		noti.setNotifyBody(null);
		notifyClients(noti);
		// Wait for clients to complete vote.
		waitForVotes();
		// Process & notify vote results.
		determineVoteResults();
	}
	
	private void notifyClients(NotifyDTO noti) {
		synchronized(clientList) {
			for(ClientThread t : clientList) {
				t.sendNotify(noti);
			}
		}
	}
	
	private void gameInitialSetup(){
		List<String> jobs = new ArrayList<>(List.of("범인", "탐정"));
		jobs.addAll(Collections.nCopies(MAX_PLAYERS - 2, "시민"));
		List<String> roles = new ArrayList<>(List.of("한규상", "황윤서", "신예슬", "김윤복"));
		
        Collections.shuffle(jobs);
        Collections.shuffle(roles);
        
        for (int i = 0; i < MAX_PLAYERS; i++) {
        	ClientThread client = clientList.get(i);
        	String job = jobs.get(i);
        	if (job.equals("탐정")) {
        		client.setJob(job);
        		client.setRole("김전일");
        		this.detectiveIndex = i;
        	} else {
        		if(job.equals("범인")) {
        			this.criminalIndex = i;
        			this.criminalName = roles.getFirst();
        		}
        		client.setJob(job);
        		client.setRole(roles.remove(0));
        	}
        }
	}
	
	private synchronized void waitForVotes() {
	    while (voteCompleteCount < MAX_PLAYERS) {
	        try {
	            System.out.println("Waiting for votes to complete... Current: " + voteCompleteCount);
	            this.wait(); // 대기 상태로 전환
	        } catch (InterruptedException e) {
	            e.printStackTrace();
	        }
	    }
	    System.out.println("All votes completed!");
	}
	
	private void determineVoteResults() {
	    int[] voteCounts = new int[MAX_PLAYERS];
	    String[] clientRoles = new String[MAX_PLAYERS];
	    
	    for (int i = 0; i < MAX_PLAYERS; i++) {
	        ClientThread client = clientList.get(i);
	        voteCounts[i] = client.getVoteCount();
	        clientRoles[i] = client.getRole();
	    }
	    
	    // Determine the highest vote count
	    int maxVotes = -1;
	    List<Integer> candidates = new ArrayList<>();
	    for (int i = 0; i < voteCounts.length; i++) {
	        if (voteCounts[i] > maxVotes) {
	            maxVotes = voteCounts[i];
	            candidates.clear();
	            candidates.add(i);
	        } else if (voteCounts[i] == maxVotes) {
	            candidates.add(i);
	        }
	    }
	    
	    // Handle tie
	    String result;
	    NotifyDTO noti = new NotifyDTO();
	    if (candidates.size() == 1) {
	        int index = candidates.get(0);
	        result = clientRoles[index] + "/" + maxVotes;
	        
	        noti.setNotifyType("VOTECOMPLETE");
		    noti.setSender("SERVER");
		    noti.setNotifyBody(result);
		    notifyClients(noti);
	    } else {
	        result = candidates.size() + "/";
	        for (int index : candidates) {
	            result += clientRoles[index] + "/";
	        }
	        result += maxVotes;
	        
	        noti.setNotifyType("VOTETIE");
		    noti.setSender("SERVER");
		    noti.setNotifyBody(result);
		    notifyClients(noti);
	    }
	}
	
	public synchronized void addVoteCompleteCount() {
	    voteCompleteCount++;
	    System.out.println("Vote completed by a client. Current count: " + voteCompleteCount);
	    if (voteCompleteCount >= MAX_PLAYERS) {
	        System.out.println("All clients have voted. Notifying...");
	        this.notifyAll(); // 대기 중인 스레드 깨움
	    }
	}
	
	public synchronized void addEvidenceCompleteCount() {
		this.evidenceCompleteCount ++;
	}
	public String getCriminalName() {
		return this.criminalName;
	}
	
	public static void main(String[] args) {
		ServerMain server = new ServerMain();
		server.startServer(35398);
	}
}
