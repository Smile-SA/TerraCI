# TerraCI

## Description

The TerraCI provides an automatic generation of the gitlabci.yml file, to be able to run the pipeline using different tests and setting user-conditions to allow an automatic deployment at the end.

## Getting started

The TerraCI prompt script can be found in the bash file. The templates files are the tempalates of the available tests those can be integrated to your pipeline. You can add any test you want following the provided templates and putting the corresponding placeholder in the basefile. In order to start, you need to have a terraform configuration file that descripe your deployment infrastructure.

## Installation

- [ ] Download the entire project in Gitlab manually
or
- [ ] Clone the existing Git repository with the following command:

```
cd your_repo
git clone https://projectgitURL
```

## Test your TerraCI

Once you download the project, you need to put some credential information to the file named "change_CICD_Variables.sh":
```
#ADD your credentials and URLs
USERNAME="<Your_Username>"
PASSWORD="<Your_Password>"
LOGIN_URL= "<Your_login_Access_URL>"
GITLAB_API_URL= "<Your_Project_API>"
PROJECT_ID= "<Your_Project_ID>"
ACCESS_TOKEN= "<Your_Project_Access_Token>"
Gitlab_url="<Your_Project_URL>"
gitlab_pass="<Your_Gitlab_Password>"

```
And some in the "build_gitlabCI_file.sh" file:

```
#Add your gitlab username & email to push the generated gitlabCI
USERNAME="<Your_username>"
USER_Email="<Your_email>"
```





Then, run the bash file using your terminal:
```
./build_gitlabCI_file.sh
```
A series of questions will appear to you one by one.
- The first question is for choosing the tests, this solution support 3 tests: infracost for cost estimation, Tflint for verifying the configuration syntax (linting) and tfsec/trivy to check the security issues in the Terraform configuration file.
- The second question represents the conditions you want to make on these tests.
- The third question will affect the status of your pipeline and reflect the importance of the conditions you chose. If you choose the non blocking test, the error won't stop the running pipeline and the deployment will be completed at the end. If you choose the bocking test, the test will stop the pipeline and there will be no deployment in case of error.
- The final question is about the pushing the generated GitlabCI to your repository on gitlab plateform, this repository must have the terraform file you want to test, this will help you push your changed gitlebCI each time and to finally get your pipeline created and running automatically.
- Finally you can monitor the status of your pipeline and check if the deployment is done once the pipeline finishes your test.

## OPTIONAL: Run your pipeline manually

- [ ] Go to your gitlab repository
- [ ] Push your generated gitlabci, using the following commands: 
```
cd existing_repo
git remote add origin <your_repo_url>
git push -uf origin master
```
- [ ] Check your pipeline status

## OPTIONAL: Check your CI/CD variables 

- [ ] Go to your gitlab project
- [ ] Go to your settings/CI CD
- [ ] Find your variables and check their values

Your CI/CD variables will change each time you run your TerraCI automatically!
You can add more variables to be used in your GitlabCI file.

## Contributing

For people who want to make changes to the project, it's helpful to send some documentation on what you want to add. 
Don't push in the main branch. Any pull request must be validated before with the developers.


## License
This project is licensed under the MIT License. See the LICENSE file for more details.
