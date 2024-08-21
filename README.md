# async-await-http-client

## Overview
A basic native HTTP client example for Apple platforms using Swift Async/Await including mock.
Authentication is not included and will need to be added later depending on which REST API you will be using to reduce bloat.

## Example Features
- Handle requests using any available HTTP method
- Example of GET and POST request builder objects
- Handle raw responses
- Parse json responses objects
- Mock data
- Uses Strict Concurrency Checking: Complete 
- Unit tests

## Using mock data
When the mock flag is switched on (or run from tests), the HTTP client will try to find a resource located on the file system instead of a remote server. The path on file system should map against the hierarchy of the url on the remote. Mock responses for each type of HTTP status code can be added if needed, for example: 200-GET, 500-PUT etc.

