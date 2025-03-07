[![JetBrains team project](https://jb.gg/badges/team.svg)](https://confluence.jetbrains.com/display/ALL/JetBrains+on+GitHub)

# Writerside documentation test result reporter


This Docker application parses JSON report and fails the pipeline when documentation contains errors.

## Usage

To test documentation within your pipeline, add the following job to your workflow:

```yml
    test:
      # Requires build job results
      needs: build
      runs-on: ubuntu-latest
    
      steps:
        - name: Download artifacts
          uses: actions/download-artifact@v4
          with:
            name: docs
            path: artifacts
    
        - name: Test documentation
          uses: JetBrains/writerside-checker-action@v1
          with:
            instance: ${{ env.INSTANCE }}
            is-group: ${{ env.IS_GROUP }}
```

* When is-group is true, or any non-empty value except `false`, the checker will process the instance as a group.
* When is-group is `false` or empty, the checker will process a single instance.

## Complete Workflow Example

Here's a complete workflow example for building documentation, testing it, and publishing it on GitHub Pages:

```yml
name: Build documentation

on:
  # If specified, the workflow will be triggered automatically once you push to the `main` branch.
  push:
    branches: ["main"]
  # Specify to run a workflow manually from the Actions tab on GitHub
  workflow_dispatch:

# Gives the workflow permissions to clone the repo and create a page deployment
permissions:
  id-token: write
  pages: write
  contents: read

env:
  # Name of module and id separated by a slash
  INSTANCE: 'Writerside/hi'
  # Set to true if the instance is a group, false otherwise
  IS_GROUP: false
  # Replace HI with the ID of the instance or build-group in capital letters
  ARTIFACT: 'webHelpHI2-all.zip'
  # Writerside docker image version
  DOCKER_VERSION: '243.22562'
  # Add the variable below to upload Algolia indexes
  # Replace HI with the ID of the instance in capital letters
  ALGOLIA_ARTIFACT: algolia-indexes-HI.zip

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Build Writerside docs using Docker
        uses: JetBrains/writerside-github-action@v4
        with:
          instance: ${{ env.INSTANCE }}
          artifact: ${{ env.ARTIFACT }}
          docker-version: ${{ env.DOCKER_VERSION }}

      - name: Upload documentation
        uses: actions/upload-artifact@v4
        with:
          name: docs
          path: |
            artifacts/${{ env.ARTIFACT }}
            artifacts/report.json
          retention-days: 7

      # Add the step below to upload Algolia indexes
      - name: Upload algolia-indexes
        uses: actions/upload-artifact@v4
        with:
          name: algolia-indexes
          path: artifacts/${{ env.ALGOLIA_ARTIFACT }}
          retention-days: 7

  test:
    # Requires the build job results
    needs: build
    runs-on: ubuntu-latest

    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v4
        with:
          name: docs
          path: artifacts

      - name: Test documentation
        uses: JetBrains/writerside-checker-action@v1
        with:
          instance: ${{ env.INSTANCE }}
          is-group: ${{ env.IS_GROUP }}

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    # Requires the test job results
    needs: test
    runs-on: ubuntu-latest

    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: docs

      - name: Unzip artifact
        uses: montudor/action-zip@v1
        with:
          args: unzip -qq ${{ env.ARTIFACT }} -d dir

      - name: Setup Pages
        uses: actions/configure-pages@v3

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v2
        with:
          path: dir

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v2
```
