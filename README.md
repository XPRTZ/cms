# 🚀 Getting started

## Prerequisites
- WSL
- Docker or equivalent container runtime
- Docker Compose
- Git
- Node 22
```bash
curl -fsSL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install -y nodejs
```

- pnpm
```bash
curl -fsSL https://get.pnpm.io/install.sh | sh -
```

## Getting started
1. Clone the repository in WSL
   ```bash
   git clone https://github.com/xprtz/cms.git
   ````
2. Build the Docker images
   ```bash
   docker compose build
   ```
3. Create the .env file from the sample file
   ```bash
   cp .env.sample .env
   ```
4. Modify some values in the .env file
   - `ADMINPASSWORD`: The password of the admin user, should not contain hashes. The default value in the sample contains a hash, so it will not work.
   - `STRAPIPASSWORD`: The password of the strapi user, should not contain hashes.
   - `AZURE_ENDPOINT`: The endpoint of the Azure Communication Services. Go to the Azure portal and get the key there or ask Maarten.

5. Start the containers
   ```bash
   docker compose up
   ```
6. In another terminal, install dependencies and start the application
    ```bash
    pnpm install
    pnpm develop
    ```
7. Open the Strapi admin panel in your browser
   ```bash
   http://localhost:1337/admin
   ```
