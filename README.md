# Aspect Oriented Programming-Java

## _Logging Aspect_

**Connection Request**

Define an aspect Logging that will record connection requests and successful connections, keeping track of the clients who are logged. For the scenario below

**Testcases**
```java
Server host = new Server("My Server");
Client jack = new Client("Jack", "evil.net");
Client jill = new Client("Jill", "evil.net");
Client jekyll = new Client("Jekyll", "student.net");
Client hyde = new Client("Hyde", "evil.net");
jack.connect(host); // accommodate
jill.connect(host); // accommodate
jekyll.connect(host); // accommodate
```

**Output**
```
CONNECTION REQUEST >>> Jack@evil.net requests connection to My Server.
Connection established between Jack@evil.net and My Server.
Clients logged in: [Jack@evil.net]

CONNECTION REQUEST >>> Jill@evil.net requests connection to My Server.
Connection established between Jill@evil.net and My Server.
Clients logged in: [Jack@evil.net, Jill@evil.net]

CONNECTION REQUEST >>> Jekyll@student.net requests connection to My Server.
Connection established between Jekyll@student.net and My Server.
Clients logged in: [Jack@evil.net, Jill@evil.net, Jekyll@student.net]
```
---------------------------------------------
**Disconnect Request**

Logging disconnects extend Logging to record disconnects. For example, for the statement below

**Testcases**
```java
jekyll.disconnect(host); // accommodate
```
**Output**
```
Connection broken between Jekyll@student.net and My Server.
Clients logged in: [Jack@evil.net, Jill@evil.net]
````
--------------------------------------------
**Revisiting Logging**

Ensuring an unconditional logging of connection requests. We want to extend Logging to guarantee that even in the presence of a blacklisted address, connection requests made by clients from those addresses will still be logged. For example, for the following scenario

**Testcases**
```java
jill.connect(host); // recorded, but not accommodated
hyde.connect(host); // recorded, but not accommodated
host.getClients();
```
**Output**
```
CONNECTION REQUEST >>> Jill@evil.net requests connection to My Server.
CONNECTION REQUEST >>> Hyde@evil.net requests connection to My Server.
Clients: []
```

## _Authentication_

**Capturing suspicious calls**

Let us now consider that any request to obtain all current clients breaks the terms of service and any client who makes such a request should be disconnected and their address should be blacklisted. Define aspect Authentication that will capture any suspicious calls and proceed to 
1. Disconnect the client, and 
2. Blacklist the client’s domain (which will subsequently deny access to any client from the same domain). 

**Testcases**
```java
jack.getAllClients(); // suspicious: Do not accommodate, blacklist and disconnect
```
**Output**
```
WARNING >>> Suspicious call from evil.net: call(Server.getClients())
Connection broken between Jack@evil.net and My Server.
Clients logged in: [Jill@evil.net]
```

Why is Jill still a client? After all, her address has been blacklisted. Indeed her address has been blacklisted, but this occurred only after she logged in to the server (due to the actions of another evil.net client). In fact, Jill was never disconnected. We will have to
fix this as follows: From this moment onwards (i.e. the moment Jill’s address has been blacklisted) once she sends any message, not only it will not be accommodated, but Jill will be disconnected. For example, for the following scenario

**Testcases**
```java
jill.getAllClients(); // already blacklisted; Do not accommodate and disconnect
jill.getAllClients(); // not accommodated
jill.disconnect(host); // not accommodated
```
**Output**
```
Connection broken between Jill@evil.net and My Server.
Clients logged in: []
```
