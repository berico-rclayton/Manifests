# Manifests

I wanted a quick and easy way to generate "dynamic configurations" that I could access via an Web Service RPC call.  By "dynamic configurations", what I really mean is that I want to POST a JSON object to the server, tell the server the directory of configuration (with templates) I care about, and have it return a specific instance of that configuration.  That's it.

### Use Cases

-  **Docker**:  create dynamic `Dockerfile`s with the appropriate per-host configuration.  Don't worry about engineering a more complex configuration process in BASH.
-  **Spring Framework**:  create custom `ApplicationContext`s for different applications.

### Roadmap

-  **Context Database**:  instead of sending the full context with the request, specify an existing context to be extended.  This implies that their is a context database somewhere with the base context you want extended.  This can be a great way to store passwords without having to leave them at each node.