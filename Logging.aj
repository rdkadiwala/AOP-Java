
public privileged aspect Logging {

	// System should log everything regardless of user is authenticate or not.
	declare precedence: Logging, Authentication;

	/*
	 * This will be last step to connect/disconnect client. After successful
	 * completion of this method client will be add or remove from server. That is
	 * why logging connection status on server method instead of client.
	 */
	pointcut successCD(Server server, Client client): (execution(void Server.attach(Client)) || execution(void Server.detach(Client))) && target(server) && args(client);

	/*
	 * For unconditional logging of each request
	 */
	before(Client client, Server server): call(void Client.connect(Server)) && target(client) && args(server)  {
		System.out.println(
				"\nCONNECTION REQUEST >>> " + client.toString() + " requests connection to " + server.toString() + ".");
	}

	/*
	 * For capturing successful connect and disconnect of client to server Capturing
	 * it after execution of server attach and detach
	 */
	after(Server server, Client client): successCD(server, client) {
		if (server.isClient(client)) {
			System.out.println(
					"\nConnection established between " + client.toString() + " and " + server.toString() + ".");
		} else {
			System.out.println("\nConnection broken between " + client.toString() + " and " + server.toString() + ".");
		}
		System.out.println("Clients logged in: " + server.clients);
	}

}
