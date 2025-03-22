# envoy-ai-experiments

The is a project on learning Envoy proxy with AI. Using AI as a tutor for Envoy proxy experiments. 

## Tasks to complete
- [X] Run envoy in docker
  - [X] Started envoy in a docker container. However, request to upstream failed with 503.  
    - [X] Try out docker compose --> Works
    - [X] Try to hit the local ip address
    - [ ] Make docker containers using host network
      - Notes: 
      `Linux-only feature: network_mode: "host" works only on Linux. On macOS and Windows, Docker Desktop uses a VM, and the host network mode does not behave the same way.`
- [ ] Try out docker compose
- [ ] Make env_setup.sh better
  - [ ] When container start failed, the script should throw error and stop. 
- [ ] Read the RouteMatch doc 