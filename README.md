## How to install


### Step 1: Provision AWS with OpenShift Open Environment in RHDP

Access the *AWS with OpenShift Open Environment* catalog.

Provision it with these parameters as below.   
| Param | Value |
| ---  | ---     |
| Region | `us-east-2` |
| Control Plane Instance Type | `m6a.4xlarge` |
| OpenShift Version | `4.19` |


## Step 2: Login to the Bastion Server

After receiving an email titled like `RHDP service AWS with OpenShift Open Environment 559lc is ready`, login to the bastion server with the information in the email.  

```shell
ssh lab-user@bastion.559lc.sandbox185.opentlc.com
```

While processing, you will be asked if you wish to connect and lab-user's password.  
```
The authenticity of host 'bastion.559lc.sandbox185.opentlc.com (3.137.23.91)' can't be established.
ED25519 key fingerprint is SHA256:kMzsfU+LCP1on/YQO+yccng6fMjOT5tW5kaVGXpFx7c.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'bastion.559lc.sandbox185.opentlc.com' (ED25519) to the list of known hosts.
lab-user@bastion.559lc.sandbox185.opentlc.com's password:<lab-user's password given by RHDP> 
```

## Step 3: Clone the Repository  

```shell
git clone https://github.com/yKanaGit/inference-handson
```

You should see output similar to this:  

```
[lab-user@bastion ~]$ git clone https://github.com/yKanaGit/inference-handson
Cloning into 'inference-handson'...
remote: Enumerating objects: 201, done.
remote: Counting objects: 100% (201/201), done.
remote: Compressing objects: 100% (127/127), done.
remote: Total 201 (delta 114), reused 157 (delta 72), pack-reused 0 (from 0)
Receiving objects: 100% (201/201), 32.65 KiB | 4.66 MiB/s, done.
Resolving deltas: 100% (114/114), done.
```

## Step 4: Set your YOUR_GITLAB_ACCESS_TOKEN

```shell
cd inference-handson/
vi manifest/bootstrap/secret-repo-creds.yaml 
```

You need to replace `YOUR_GITHUB_ACCESS_TOKEN` in `manifest/bootstrap/secret-repo-creds.yaml` with your GitHub access token.

```
---
apiVersion: v1
kind: Secret
metadata:
  name: repo-creds
  namespace: openshift-gitops
  labels:
    argocd.argoproj.io/secret-type: repo-creds
stringData:
  type: git
  url: https://github.com/yKanaGit/inference-handson.git
  password: YOUR_GITHUB_ACCESS_TOKEN
  username: git
```

### Step 4a: Set GitHub token for the mobile-report-app BuildConfig
`mobile_report_App` リポジトリのクローンにも同じ GitHub トークンが必要です。`manifest/mobile-report-app/secret-github.yaml` の `YOUR_GITHUB_ACCESS_TOKEN` を手元のトークンに置き換えておきます。

```shell
vi manifest/mobile-report-app/secret-github.yaml
```

## Step 5: Run setup.sh
You can pass the number of hands-on user as an argument to the setup script. The default is for 5 users.

```shell
./setup.sh 5
```

It takes a little long, almost 30-40 minutes.  
After getting ready, you can see the applicaiton's URL and access it.  

```
[lab-user@bastion analysis-agent]$ ./setup.sh 
clusterrolebinding.rbac.authorization.k8s.io/cluster-admin-openshift-gitops-argocd-application-controller created
namespace/openshift-gitops-operator created
operatorgroup.operators.coreos.com/openshift-gitops-operator created
subscription.operators.coreos.com/openshift-gitops-operator created
Waiting for OpenShift GitOps operator being ready......clusterserviceversion.operators.coreos.com/openshift-gitops-operator.v1.17.1 condition met

secret/repo-creds created
applicationset.argoproj.io/bootstrap created

!!! If you can't get enough g6.xlarge instance, this setup script won't finish. !!!
!!! If it doesn't finish after more than an hour, run 'oc get machine -A'   !!!
!!! to check if the instance is being provisioned.                          !!!

Waiting for the environment being ready. it may take 30-40 minutes................................................................................................................
The environment is ready.


[OpenShift AI Console URL]
https://rhods-dashboard-redhat-ods-applications.apps.DOMAIN/
```


