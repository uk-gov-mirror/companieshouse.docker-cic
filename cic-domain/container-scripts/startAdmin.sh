#!/bin/bash

if [ -z ${ADMIN_PASSWORD+x} ]; then
  echo "Env var ADMIN_PASSWORD must be set! Exiting.."
  exit 1
fi

DOMAIN_HOME="/apps/oracle/${DOMAIN_NAME}"
. ${DOMAIN_HOME}/bin/setDomainEnv.sh

# Remove the default LDAP realm info provided by the image
rm -rf ${DOMAIN_HOME}/servers/${ADMIN_NAME}/data

# Set the admin password to the one supplied via env var
java weblogic.security.utils.AdminAccount weblogic $ADMIN_PASSWORD $DOMAIN_HOME/security

# Set up the boot.properties file to allow automatic startup
mkdir -p ${DOMAIN_HOME}/servers/${ADMIN_NAME}/security
echo "username=weblogic" > ${DOMAIN_HOME}/servers/${ADMIN_NAME}/security/boot.properties
echo "password=${ADMIN_PASSWORD}" >> ${DOMAIN_HOME}/servers/${ADMIN_NAME}/security/boot.properties

# Update the domain credentials to those provided by env var
${ORACLE_HOME}/wlserver/common/bin/wlst.sh ${DOMAIN_HOME}/../container-scripts/set-credentials.py

# Set the cic-jdbc connection string and credentials
${ORACLE_HOME}/wlserver/common/bin/wlst.sh ${DOMAIN_HOME}/../container-scripts/set-jdbc-details.py

${DOMAIN_HOME}/bin/startWebLogic.sh $*
