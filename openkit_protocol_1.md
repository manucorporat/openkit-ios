OPENKIT'S PROTOCOL 1.0 draft3
=======

###0. Legend

```
	#comments
	(( )) variables
```



##1. APPLICATION PROTOCOL

1. **HTTP header (POST and GET)**  

	```
Accept				application/json
Content-Type		application/json
Accept-Encoding		gzip, deflate  # performance improvement 
Authorization		# defined in oauth 1.0a specification
```


2. ***Openkit* should use HTTPS**  
HTTPS is recommended for a superior security level. ***Oauth 1.0a* protocol** is safe even over HTTP but *openkit* sends the credentials(see 3.4) in plaintext during login.


3. **Security configurations**  
	1. [Low security] No SSL certificate (plain http).
	2. [Medium security] CA signed SSL certificate in server side.
	3. [High security] CA or self-signed SSL certificate shared in both sides, server and client. [trusted-ssl-certificates](http://www.indelible.org/ink/trusted-ssl-certificates/)  
	This method provides the maximum security level. Invulnerable to man-in-the-middle attacks.
This method needs additional logic in the client side.



##2. DEFINITIONS

1. **((openkit's protocol version))**  
Backward compatibility design. This value should be the version implemented in the client (initially "1.0")
If it is not included in the request, the server should use the last version of the protocol.


2. **((timestamp))**  
POSIX time, seconds since ```1/1/1970  00:00:00```


3. **((user's id))**  
Because of security reasons the user's id is not an integer. It should be a non-sequential string like ```fsd3d3459f9a```.


4. **((service's name))**  
For example: *"facebook"*, *"twitter"*…


5. **((user_id in service))**  
For example: ```10001302592140``` ( user-id in *facebook* )


6. **((app's key))**  
Consumer key provided by *[oauth](http://oauth.net/core/1.0/#anchor6)*.


7. **((app's secret))**  
Consumer secret provided by *[oauth](http://oauth.net/core/1.0/#anchor6)*.



##3. AUTHORIZATION
Valid credentials (see 3.4) are needed to get an openkit's access_token (see 3.5).

1. ***OAUTH 1.0a***  
*Openkit* uses the [standardized *oauth 1.0a* protocol](http://tools.ietf.org/html/rfc5849).


2. **Authorization in header**  
The authorization tokens are included in the HTTP header (not in the http body or URL). [http://oauth.net/core/1.0a/#auth_header](http://oauth.net/core/1.0a/#auth_header)


3. ***oauth* signature**  
The HTTP body is not included in the signature base string.


4. **Client's request, based in x-auth (idea from *twitter*'s *oauth* fork)**  
*Oauth* was designed to provide authorized access to "untrusted" third party consumers ( 3-legged authorization ). Obviously in this case ( *openkit* ), both, server(provider) and app(consumer) are managed by the same developer so we shouldn't redirect the user to an external login through the browser. The request_token step is omitted.
[https://dev.twitter.com/docs/oauth/xauth](https://dev.twitter.com/docs/oauth/xauth)

	4.1. **Login credentials**  
	Credentials are used to get an valid *openkit*'s access_token. Similarly, the openkit server use the  ```*((access_token provided by the service))``` provided by the service ( *facebook*, *twitter*, etc. ) to valide the credentials.  
	The path and method are defined in *oauth*. For example ```oauth/access_token``` (POST)
	
	```
{
	# dictionary of services: facebook, twitter, etc. # 
	"*((service's name))" :
	{
		"user_id" : ((user_id in service)),
		"access_token" : *((access_token provided by the service)),
	},
	...
}
```


5. **Server's respond:**  
( If login was successful, ie, the server validated that the credentials were valid. )

	```
	oauth_token=((user's access token))&oauth_token_secret=((user's token secret))
```
See:
	- [https://dev.twitter.com/docs/oauth/xauth](https://dev.twitter.com/docs/oauth/xauth)
	- [http://oauth.net/core/1.0/#anchor29](http://oauth.net/core/1.0/#anchor29)



##4. AUTHORIZED SERVICES
A valid access_token is needed to do this kind of tasks.

###1. OKUSER
Updating OKUser (currently "nick" is the only one attribute).
***

1. **Path & method:** ```/user``` (POST)


2. **Checking access_token**  
A void request can be used to check quickly if the access_token is still valid.  
	
	```
{ }
```


3. **Client's request:**

	```
{
	"version" : *((openkit's protocol version)), #optional
	"nick" : ((user's nick)) #optional
}
```


4. **Server's response:**

	```
# default user representation #
{
	"id" : ((user's id)),
	"nick" : ((user's nick)),
	"services" :
	{
		# dictionary of services: facebook, twitter, etc. # 
		"*((service's name))" : *((user_id in service)),
		...
	}	
}
```



###2. OKCLOUD
Synchronizing data entries between client and server. This protocol implements a simple toolkit to resolve conflicts if several devices modify the same values.
***

1. **Path & method:** ```/cloud``` (POST)


2. **((priority))**  
It is an arbitrary real number managed by the client and used by the server to resolve conflicts.
If the "priority" in the client-side is equal or greater than the "priority" in the server-side, the values are overwritten in the server, otherwise the values are overwritten in the client.


3. **((timestamp))**  
It's a timestamp managed by the server that indicates the date of the last sync with the client.


4. **A void request can be used to get the whole stored data.**  

	```
{ }
```


5. **Client's request:**  

	```
{
	"version" : *((openkit's protocol version)), #optional
	"priority" : *((priority)), #optional
	"last_update" : *((timestamp)), #optional
	"entries" : #optional
	{
		# dictionary of the entries that changed since the last update #
		"((key))" :  ((object)),
		...
	}
}
```


6. **Server's response:**  

	```
{
	"priority" : *((priority)),
	"last_update" : *((timestamp)),
	"entries" :
	{
		# dictionary of the entries that should change in the client #
		"((key))" : ((object)),
		...
	}
}
```



###3. OKSCORE
Posting scores to server.
***

1. **Path & method:** ```/post_score``` (POST)


2. **Client's request:**

	```
{
	"version" : *((openkit's protocol version)), #optional
	"leaderboard_id" : ((score's leaderboard ID)),
	"value" : ((score's value))
}
```

3. **Server's response:**

	```
{
	"id" : ((score's id)),
	"leaderboard_id" : ((score's leaderboard ID)),
	"value" : ((score's value)),
	"rank" : ((score's rank)),
	"user" : # default user representation #
	{
		"id" : ((user's id)),
		"nick" : ((user's nick)),
		"services" :
		{
			# dictionary of services: facebook, twitter, etc. # 
			"*((service's name))" : *((user_id in service)),
			...
		}	
	}
}
```



##5. UNAUTHORIZED SERVICES
Unauthorized services use the GET method.

###1. OKLEADERBOARD
Getting the list of leaderboards for the specified app.
***

1. **Path & method:** ```/leaderboards``` (GET)


2. **((timestamp))**  
Used internally by the SDK to optimize the internet usage. Inspired by ```HTTP 304 Not Modified``` error code.


3. **Client's request:**  

	```
{
	"app_key" : *((app's key)),
	"version" : *((openkit's protocol version)), #optional
	"last_update" : *((timestamp))   #optional
}
```
Example: getting leaderboards of the app "frf3352s2". ```/leaderboards?app_key=frf3352s2```


4. **Server's response:**  

	```
{
	"last_update" : *((timestamp)),
	"entries" :
	[
		# array of dictionaries updated after specified in the "last_update" request param #
		{
			"id" : ((leaderboard's id)),
			"name" : ((leaderboard's name)),
			"sort_type" : *((leaderboard's sort type)),
			"format" : *((leaderboard's format)),
			"icon_url" : ((leaderboard's icon url)),
			"icon_data" : *((leaderboard's icon data)),  #optional
			"player_count : ((leaderboard's player count)),
		},
		...
	]
}
```
	**((leaderboard's icon data))** is a PNG representation of the image encoded in base64.  
	
	**((leaderboards's format))** is used for proper representation.
	- 0: number (example: ```6,435,242``` )
	- 1: time (example: ```1'  23.2"```  #one minute and 23.2 seconds )
	
	
	**((leaderboard's sort type))**  
	- 0: descending (higher is better)
	- 1: ascending (lower is better)



###2. OKSCORE (top scores)
Getting a list of scores for the specified leaderboard.
***
 
1. **Path & method:** ```/best_scores/(*)``` (GET)  
To make it consistent and reusable, all these paths should use the same request/respond protocol explained later:
	- ```/best_scores```	best worldwide scores (no filter)
	- ```/best_scores/user-((user's id))```	best user scores
	- ```/best_scores/friends-((user's id))```	best scores from friends  
	
	Example: getting best scores from user "hg44gsew3". ```/best_scores/user-hg44gsew3```  
	Syntactically it can be understood as a request ( ```best_scores``` ) and a filter ( ```user-hg44gsew3``` ).

	
	
2. **Client's request:**

	```
{
	"app_key" : *((app's key)),
	"leaderboard_id" : ((leaderboard's id)),
	"range" : *((range)), #optional
	"size" : *((size)), #optional
	"offset" : *((offset)), #optional
	"version" : *((openkit's protocol version)), #optional
}
```
	**((range))**  
	Unsigned integer. The server will responds with the top scores submitted in the last ```((time range))``` seconds. This allows developers the highest flexibility.
For example, if ```((time range))``` is equal to:
	- ```24*60*60*1```, the server would respond with the scores of the last day.
	- ```24*60*60*7```, scores from the last week...
	- ```2^32-1```, ~all-time scores (default value)

	**((size))** from 5 to 50  
	Number of scores to respond.

	**((offset))** from 0 to 2^32-1  
	Example: getting the best scores from rank 30 to 45. ```/best_scores?offset=30&size=15...```


3. **Server's respond:**

	```
[
	# array of scores #
	{
		"id" : ((score's id)),
		"leaderboard_id" : ((leaderboard's id)),
		"value" : ((score's value)),
		"rank" : ((score's rank)),
		"user" :  # default user representation #
		{
			"id" : ((user's id)),
			"nick" : ((user's nick)),
			"services" :
			{
				# dictionary of services: facebook, twitter, etc. #
				"*((service's name))" : *((user_id in service)),
				...
			}
		}
	},
	...
]
```

##6. APPENDIXES

###Example 1: Login flow with *facebook*
1. Getting the user_id and access_token from *facebook*: (see 3)   
	The user logs in *facebook*, and the SDK returns the user's id and an *facebook*'s oauth_token.
	
2. Getting a access_token for *openkit*: (see 3)  
	We send the *facebook*'s userID and oauth_token as credentials to get a openkit's access_token.
	
3. Once we have a valid access_token, we can do any "Authorized Service" (see 4)	
