
# Homework week_1_b

## Question 1: Enter the Output Displayed After Running Terraform Apply
Note [Terraform files can be found here](https://github.com/TylerJSimpson/data_engineering_zoomcamp/tree/main/week_1/terraform).  

SSH into VM.  
```bash
ssh -i /c/Users/simps/.ssh/gcp tjsimpson@{HIDDEN}
```  
Go to bin directory.  
Download Terraform.  
```bash
wget https://releases.hashicorp.com/terraform/1.3.7/terraform_1.3.7_linux_amd64.zip
```  
Unzip package.  

Change to week_1_basics_n_setup/1_terraform_gcp/terraform directory.  
Now the JSON GCP key needs to be xfered using SFTP.  
Go to directory that houses JSON file.  
```bash
sftp -i /c/Users/simps/.ssh/gcp tjsimpson@{HIDDEN}
```  
Create a new directory .gc and put file.  

In .../1_terraform_gcp/terraform path.  

7. Configure gcloud  
```bash
export GOOGLE_APPLICATION_CREDENTIALS=~/.gc/{HIDDEN}.json
```  
```bash
gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS
```  
Install Terraform.  
```bash
terraform init
```  
Set plan.  
```bash
terraform plan
```  
Enter GCP project ID.  
Apply plan.  
```bash
terraform apply
```  
