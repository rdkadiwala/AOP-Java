import java.util.ArrayList;
import java.util.List;

public privileged aspect Authentication {
	/*
	 * Capture getClients message from client
	 */
	pointcut serverGetClient(Client client, Server server): call(* Server.getClients(..)) && this(client) && target(server);
	
	/*
	 * Introducing an attribute to store blacklisted domain of each server 
	 */
	private List<String> Server.blackListed = new ArrayList<String>();

	/*
	 * Add domain to blacklist database
	 */
	private void Server.blackList(String domain) {
		this.blackListed.add(domain);
	}
	
	/*
	 * Validating domain with blacklisted database 
	 */
	private boolean Server.isBlackListed(String domain) {
		return this.blackListed.size() > 0 ? this.blackListed.contains(domain) : false;
	}
	
	/*
	 * Before making any server call from client valid client domain.
	 * If client domain is blacklisted then stop further processing and if client is connected to server disconnect client.
	 * Otherwise proceed with serve code.
	 */
	Object around(Client client, Server server): call(* Server.*(..)) && this(client) && target(server) {
		if(server.isBlackListed(client.getAddress())) {
			if(server.isClient(client)) {
				server.detach(client);
			}
			return null;
		} else {
			return proceed(client, server);
		}
	}
	
	/*
	 * Addition validation for getAllClient message
	 * 1. If domain is not blacklisted then add domain to blacklisted list and disconnect current client
	 * 2. If domain is already blacklisted and other clients of blacklisted domain tries to access method
	 * 	  block their call and disconnect them as well 
	 */
	void around(Client client, Server server): serverGetClient(client, server) {
		if(!server.isBlackListed(client.getAddress())) {
			System.out.println("\nWARNING >>> Suspicious call from "+ client.getAddress() +": " + thisJoinPoint);
			server.blackList(client.getAddress());
		}
		if(server.isClient(client)) {
			server.detach(client);
		}
	}
	
}
