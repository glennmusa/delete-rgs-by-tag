#!/bin/bash
#
# Delete all resource groups given a tag, and optionally auto-approve deletion and/or wait for completion

usage() {
  echo "${0}: Delete all resource groups given a tag"
  echo "usage: ${0} <tag> <auto approve (y/n)> <wait for completion (y/n)>" 1>&2;
  echo "example: ${0} deleteme" 1>&2;
}

if [[ "$#" -lt 1 ]]; then
   usage
   exit 1
fi

tag=$1
auto_approve=${2:-n}
wait_for_completion=${3:-y}

rgs_to_delete=$(az group list --tag "${tag}" --query "[].name" --output tsv)

if [[ -z "${rgs_to_delete}" ]]; then
  echo "No resource groups found with tag ${tag}."
fi

az_delete="az group delete"

if [[ "${auto_approve}" == "y" ]]; then
  az_delete+=" -y "
fi

if [[ "${wait_for_completion}" == "n" ]]; then
  az_delete+=" --no-wait "
fi

# start capture keyboard interrupt to exit long running loop
trap break INT

echo "${0}: It may take a few minutes for deletion to complete depending on what is in your resource groups."

for rg in ${rgs_to_delete}; do
  echo "Deleting Resouce Group ${rg}..."
  eval "${az_delete} -n ${rg}"
done

trap - INT
# end capture keyboard interrupt to exit long running loop
