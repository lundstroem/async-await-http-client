# async-await-http-client

## Overview
The main idea is to supply a basic native network foundation example for Apple platforms using Swift Async/Await.
Authentication is not included and will need to be added later depending on which REST API you will be using. This is to reduce bloat.

## Example Features
- Handle requests using any available HTTP method
- Example of GET and POST request builder objects
- Handle raw responses
- Parse json responses objects
- Mock data
- Uses Strict Concurrency Checking: Complete 
- Unit tests

# Mock data
When the mock flag is switched on, the HTTP client will try to find a resource located on the file system instead of a remote server. The path on file system should map against the url on the remote. Mock responses for each type of HTTP status code can be added if needed, for example: 200-GET, 500-PUT etc.


## TODO
- Auth methods
- Create mock filepath from request data
- etc
