#!/bin/bash
set -e

pint_install_command=("composer global require laravel/pint:PINT_VERSION --no-progress --dev")
cs2pr_install_command=("composer global require staabm/annotate-pull-request-from-checkstyle:CS2PR_VERSION --no-progress --dev")

if [[ "${INPUT_USE_COMPOSER}" == true ]]; then
  COMPOSER_PINT_VERSION=$(composer show --locked | grep 'laravel/pint' | awk '{print $2}')
  COMPOSER_CS2PR_VERSION=$(composer show --locked | grep 'staabm/annotate-pull-request-from-checkstyle' | awk '{print $2}')
  
  INPUT_PINT_VERSION=${INPUT_PINT_VERSION:-${COMPOSER_PINT_VERSION}}
  INPUT_ANNOTATE_VERSION=${INPUT_ANNOTATE_VERSION:-${COMPOSER_CS2PR_VERSION}}
fi

if  [[ "${INPUT_PINT_VERSION}" ]]; then
  pint_install_command="${pint_install_command/PINT_VERSION/${INPUT_PINT_VERSION}}"
else
  pint_install_command="${pint_install_command/:PINT_VERSION/}"
fi

if [[ "${INPUT_ANNOTATE_VERSION}" ]]; then
  cs2pr_install_command="${cs2pr_install_command/CS2PR_VERSION/${INPUT_ANNOTATE_VERSION}}"
else
  cs2pr_install_command="${cs2pr_install_command/:CS2PR_VERSION/}"
fi

if [[ ! "${INPUT_TEST_MODE}" ]]; then
  INPUT_ANNOTATE=false
fi

BIN_PATH="$(composer -n config --global home)/vendor/bin"

pint_command=("${BIN_PATH}/pint")

if [[ "${INPUT_ONLY_FILES}" ]]; then
  for file in ${INPUT_ONLY_FILES}; do
    pint_command+=" ${file}"
  done
elif [[ "${INPUT_ONLY_DIRTY}" == true ]]; then
  pint_command+=" --dirty"
fi

if [[ "${INPUT_TEST_MODE}" == true ]]; then
  pint_command+=" --test"
fi

if [[ "${INPUT_VERBOSE_MODE}" == true ]]; then
  pint_command+=" -v"
fi

if [[ "${INPUT_CONFIG_PATH}" ]]; then
  pint_command+=" --config ${INPUT_CONFIG_PATH}"
elif [[ "${INPUT_PRESET}" ]]; then
  pint_command+=" --preset ${INPUT_PRESET}"
fi

if [[ "${INPUT_ANNOTATE}" == true ]]; then
  pint_command+=" --format=checkstyle | ${BIN_PATH}/cs2pr"
fi

echo "Running Command: " "${pint_install_command[@]}"

${pint_install_command[@]}

if [[ "${INPUT_ANNOTATE}" == true ]]; then
  echo "Running Command: " "${cs2pr_install_command[@]}"

  ${cs2pr_install_command[@]}
fi

echo "Running Command: " "${pint_command[@]}"

${pint_command[@]}
