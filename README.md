# GitHub Action for Laravel Pint  

GitHub Action composite implementation of the [Laravel Pint](https://github.com/laravel/pint) Package. Also, when Pint is run on test mode, pull request annotation based on a Checkstyle XML-report is available.

## Usage

Use with [GitHub Actions](https://github.com/features/actions)

### Sample contents of _.github/workflows/pint.yml_

```yaml
name: PHP Lint

on:
  push:
    branches:
      - master
  pull_request:
    branches-ignore:
      - 'dependabot/npm_and_yarn/*'
      - 'dependabot/composer/*'
  schedule:
    - cron: '0 0 * * *'

jobs:
  phplint:
    runs-on: ubuntu-latest
    container:
      image: php:${{ matrix.php-tags }}
    defaults:
      run:
        shell: bash
    timeout-minutes: 2

    strategy:
      fail-fast: false
      matrix:
        php-tags: [8.1-fpm-alpine3.18]

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Get changed files
        id: changed-files
        uses: tj-actions/changed-files@v39

      - name: Run Laravel Pint
        uses: sergotail/laravel-pint-action@v1
        with:
          onlyFiles: ${{ steps.changed-files.outputs.all_changed_files }}
          testMode: true
          verboseMode: true
          configPath: ./pint.json
          preset: laravel
          onlyDirty: false
          annotate: true
          pintVersion: 1.8.0
          annotateVersion: 1.8.5
          useComposer: true
```

ℹ️ Also you can specify the Pint version to be used by specifying a `pintVersion` in your configuration file.

Even when `useComposer` is endabled, `pintVersion` and `annotateVersion` are checked first, and only then the lock file is checked.

`annotate` option uses [annotate-pull-request-from-checkstyle](<https://github.com/staabm/annotate-pull-request-from-checkstyle>) package to annotate pull request based on a Checkstyle XML-report.

This action **DOESN'T** commit changes automatically. If you want to achieve such behaviour you have to use it in combination with another action like [git-auto-commit Action](https://github.com/stefanzweifel/git-auto-commit-action) or [Create Pull Request Action](https://github.com/marketplace/actions/create-pull-request). Note that in this case you have to disable `testMode`.
