# DocuSign Railway Deployment

A DocuSign-like document verification system optimized for Railway.app deployment.

## Quick Deploy

### Option 1: Deploy to Railway (Recommended)

1. Push this code to a GitHub repository
2. Visit [Railway.app](https://railway.app)
3. Click "New Project" → "Deploy from GitHub repo"
4. Select your repository
5. Railway will automatically detect the Dockerfile and deploy

### Option 2: Manual Deployment

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Initialize project
railway init

# Deploy
railway up