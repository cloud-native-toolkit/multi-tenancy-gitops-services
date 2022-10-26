INGRESS_DOMAIN=$(oc get IngressController default -n openshift-ingress-operator -o jsonpath='{.status.domain}')
NAMESPACE=${NAMESPACE:-"odm"}
oc project $NAMESPACE

cat <<EOF |oc apply -f -
apiVersion: console.openshift.io/v1
kind: ConsoleLink
metadata:
  name: cloud-pak-dashboard
spec:
  href: https://cpd-$NAMESPACE.$INGRESS_DOMAIN
  location: ApplicationMenu
  applicationMenu:
    section: IBM Cloud Paks
  text: Cloud Pak Dashboard
EOF

cat <<EOF |oc apply -f -
apiVersion: console.openshift.io/v1
kind: ConsoleLink
metadata:
  name: decision-center
spec:
  href: https://cpd-$NAMESPACE.$INGRESS_DOMAIN/odm/decisioncenter
  location: ApplicationMenu
  applicationMenu:
    section: Operational Decision Manager
  text: Decision Center
EOF

cat <<EOF |oc apply -f -
apiVersion: console.openshift.io/v1
kind: ConsoleLink
metadata:
  name: decision-server-console
spec:
  href: https://cpd-$NAMESPACE.$INGRESS_DOMAIN/odm/res
  location: ApplicationMenu
  applicationMenu:
    section: Operational Decision Manager
  text: Decision Server Console
EOF

cat <<EOF |oc apply -f -
apiVersion: console.openshift.io/v1
kind: ConsoleLink
metadata:
  name: decision-runner
spec:
  href: https://cpd-$NAMESPACE.$INGRESS_DOMAIN/odm/DecisionRunner
  location: ApplicationMenu
  applicationMenu:
    section: Operational Decision Manager
  text: Decision Runner
EOF

cat <<EOF | oc apply -f -
apiVersion: console.openshift.io/v1
kind: ConsoleLink
metadata:
  name: decision-server-runtime
spec:
  href: https://cpd-$NAMESPACE.$INGRESS_DOMAIN/odm/DecisionService
  location: ApplicationMenu
  applicationMenu:
    section: Operational Decision Manager
  text: Decision Server Runtime
EOF

echo ----------------------------------------------
echo Cloud Pak Dashboard
echo 'https://cpd-'$NAMESPACE'.'$INGRESS_DOMAIN''
echo ==============================================
echo Decision Center
echo ==============================================
echo 'https://cpd-'$NAMESPACE'.'$INGRESS_DOMAIN'/odm/decisioncenter'
echo ----------------------------------------------
echo Decision Server Console
echo ==============================================
echo 'https://cpd-'$NAMESPACE'.'$INGRESS_DOMAIN'/odm/res'
echo ----------------------------------------------
echo Decision Runner
echo ==============================================
echo 'https://cpd-'$NAMESPACE'.'$INGRESS_DOMAIN'/odm/DecisionRunner'
echo ----------------------------------------------
echo Decision Server Runtime
echo ==============================================
echo 'https://cpd-'$NAMESPACE'.'$INGRESS_DOMAIN''