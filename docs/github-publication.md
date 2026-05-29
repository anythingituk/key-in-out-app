# GitHub Publication Guide

Use this guide after reviewing the repository content locally.

## 1. Confirm Public Safety

Before publishing, check that the repo contains no:

- real tenant names
- real tenant email addresses
- staff names
- SharePoint site URLs that identify an organisation
- business-specific names
- screenshots with personal data
- exported Power Apps packages that have not been reviewed

The included files use placeholder URLs, fake names, and `example.com` email addresses.

## 2. Commit Locally

From the repository root:

```powershell
git status
git add .
git commit -m "Initial Power Apps SharePoint key management scaffold"
```

## 3. Create the GitHub Repository

In GitHub:

1. Select **New repository**.
2. Repository name: `key-in-out-app`.
3. Visibility: **Public**.
4. Do not add a README, license, or `.gitignore` in GitHub because they already exist locally.
5. Create repository.

## 4. Push to GitHub

Replace `YOUR-USERNAME` with your GitHub username:

```powershell
git remote add origin https://github.com/YOUR-USERNAME/key-in-out-app.git
git branch -M main
git push -u origin main
```

## 5. What MIT Means

The MIT License is a short permissive open-source license.

It allows other people to:

- use the project
- copy it
- change it
- share it
- use it commercially

They must keep the license notice. The license also says the project is provided without warranty.

For this type of starter app, MIT is usually a reasonable public-repo choice when reuse is welcome.
