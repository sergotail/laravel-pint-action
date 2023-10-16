#!/bin/bash
set -e

# process params according to another params

if [[ "${INPUT_ONLYFILES}" ]]; then
  INPUT_ONLYDIRTY=false
fi

if [[ "${INPUT_CONFIGPATH}" ]]; then
  INPUT_PRESET=
fi

if [[ "${INPUT_ANNOTATE}" == true ]]; then
  INPUT_TESTMODE=true
fi

# get versions of required packages from composer, if needed

if [[ "${INPUT_USECOMPOSER}" == true ]]; then
  COMPOSER_PINT_VERSION=$(composer show --locked | grep 'laravel/pint' | awk '{print $2}')
  COMPOSER_CS2PR_VERSION=$(composer show --locked | grep 'staabm/annotate-pull-request-from-checkstyle' | awk '{print $2}')

  INPUT_PINTVERSION=${INPUT_PINTVERSION:-${COMPOSER_PINT_VERSION}}
  INPUT_ANNOTATEVERSION=${INPUT_ANNOTATEVERSION:-${COMPOSER_CS2PR_VERSION}}
fi

# build composer install commands

pint_install_command=("composer global require laravel/pint:PINT_VERSION --no-progress --dev")
cs2pr_install_command=("composer global require staabm/annotate-pull-request-from-checkstyle:CS2PR_VERSION --no-progress --dev")

if  [[ "${INPUT_PINTVERSION}" ]]; then
  pint_install_command="${pint_install_command/PINT_VERSION/${INPUT_PINTVERSION}}"
else
  pint_install_command="${pint_install_command/:PINT_VERSION/}"
fi

if [[ "${INPUT_ANNOTATEVERSION}" ]]; then
  cs2pr_install_command="${cs2pr_install_command/CS2PR_VERSION/${INPUT_ANNOTATEVERSION}}"
else
  cs2pr_install_command="${cs2pr_install_command/:CS2PR_VERSION/}"
fi

# build pint command

BIN_PATH="$(composer -n config --global home)/vendor/bin"

pint_command=("${BIN_PATH}/pint")

if [[ "${INPUT_ONLYFILES}" ]]; then
  for file in ${INPUT_ONLYFILES}; do
    pint_command+=" ${file}"
  done
fi

if [[ "${INPUT_TESTMODE}" == true ]]; then
  pint_command+=" --test"
fi

if [[ "${INPUT_VERBOSEMODE}" == true ]]; then
  pint_command+=" -v"
fi

if [[ "${INPUT_CONFIGPATH}" ]]; then
  pint_command+=" --config ${INPUT_CONFIGPATH}"
fi

if [[ "${INPUT_PRESET}" ]]; then
  pint_command+=" --preset ${INPUT_PRESET}"
fi

if [[ "${INPUT_ONLYDIRTY}" == true ]]; then
  pint_command+=" --dirty"
fi

if [[ "${INPUT_ANNOTATE}" == true ]]; then
  pint_command+=" --format=checkstyle"
fi

# run prepared commands

echo "Running Command: " "${pint_install_command[@]}"
${pint_install_command[@]}

if [[ "${INPUT_ANNOTATE}" == true ]]; then
    echo "Running Command: " "${cs2pr_install_command[@]}"
    ${cs2pr_install_command[@]}

    cs2pr_command=("${BIN_PATH}/cs2pr")

    echo "Running Command: " "${pint_command[@]} | ${cs2pr_command[@]}"
    ${pint_command[@]} | ${cs2pr_command[@]}
else
    echo "Running Command: " "${pint_command[@]}"
    ${pint_command[@]}
fi
