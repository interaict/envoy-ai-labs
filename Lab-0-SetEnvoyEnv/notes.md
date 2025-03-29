# Set up Envoy

This lab is mainly to set up the environment for Envoy experiments. All the needed files are included in this folder. 

## Experiments
The experiment steps for me is listed as following:
- Run envoy locally with a simple configuration file, which is similar to `./envoy_header_routing.config.yml`.
  - You will have to install envoy locally. Skip this section in notes as it can be found easily on the envoy website.
- Run envoy in a docker container. To achieve this, following questions must be resolved:
  - Run envoy container and make sure we can hit it. 
    - Command: `curl http://localhost:9901/server_info`
    - Command to start the needed containers: 
      - Command: `./env_setup.sh envoy_routing_localip.yml`
  - Enable communication between envoy container and backend containers
    - Set up the config file to use local ip. 
      As envoy runs in a docker container, it is impossible to use `localhost` to hit the other backend containers run in the same host. The solution of this is to use local ip (ip of the host). Thus, envoy container will talk to host ip, which has the other backend container mapping ports. 
    - Alternative of host ip is docker compose
      With docker compose, we can put all the containers in the same sub-network created by docker compose. Check the docker compose file `docker-compose.yml`.

## Bugs
There are hidden bugs in the config file. However, those bugs will not prevent us from use Envoy but could cause issues when envoy usage case get complicated. 

- Prefix Match
  Prefix match could be buggy. For example, we have echo as one of the backend containers and we are trying to hit with the following settings:
  ```yaml
  - match: { prefix: "/echo" }
    route: 
      cluster: echo_service
      prefix_rewrite: "/"
  ```
  If we try to send a request with `curl -v http://localhost:10000/echo-1`, we can see the command got passed into the echo and returns 200 as response code. 
  However command `curl -v http://localhost:10000/python-1` will fail with response code 404. 

  - Why 404 when trying to hit Python service?
    - **Echo service is not as strict as Python service.** When we run the curl command, the request will be passed into the container as prefix match. And `-1` will be taken as a parameter to the container. Thus the command is same as `curl -v http://localhost:10000/echo/-1`.
    - Python service doesn't recognize this parameter and returns 404. If this is the case, then envoy should directly return 404 instead of pass the request to backend containers. 
    - **Reminder:** Either we don't use the prefix match or we should have more match rules to handle this. 

- Header match
  - **Looks like this bug got resolved.**
  - Settings
  ```yaml
  routes:
  - match:
      prefix: "/"
      headers:
        - name: "service-name"
          exact_match: "httpbin"
        - name: "content-type"
          exact_match: "application/json"
    route: 
      cluster: httpbin_service
  ```
  The expect behavior is to match the header `content-type: application/json`. However, header `content-type: application/json; charset=utf-8` will be matched successfully as well.
