#!/bin/bash

#Add your gitlab username & email to push the generated gitlabCI
USERNAME="<Your_username>"
USER_Email="<Your_email>"

# Function to prepare the output file
prepare_output_file() {
    output_file="generated_gitlabci.yml"

    # Check if the output file already exists and remove it
    if [[ -f "${output_file}" ]]; then
        rm "${output_file}"
    fi

    # Create a copy of basefile.yml from templates_files directory
    cp templates_files/basefile.yml "${output_file}"
}

# Function to install yq without sudo
install_yq() {
    if ! command -v yq &> /dev/null; then
        echo "yq is required but not installed. Installing yq..."
        wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
        chmod +x /usr/local/bin/yq
    fi
}
# Function to read inputs from YAML file
read_inputs_from_yaml() {
    Deployment_instructions="DeploymentInstructions.yaml"
    if ! command -v yq &> /dev/null; then
        echo "yq is required but not installed. Installing yq..."
        apt-get update
        apt install snapd
        snap install yq
        apt-get install -y yq
    fi
    install_yq

    mapfile -t test_names < <(yq e '.tests[].name' "$Deployment_instructions")
    mapfile -t test_status < <(yq e '.tests[].deployment_status' "$Deployment_instructions")
    mapfile -t max_lint_issues < <(yq e '.tests[] | select(.rules.MAX_LINT_ISSUES) | .rules.MAX_LINT_ISSUES' "$Deployment_instructions")
    mapfile -t budget < <(yq e '.tests[] | select(.rules.BUDGET) | .rules.BUDGET' "$Deployment_instructions")
    mapfile -t critical_problems < <(yq e '.tests[] | select(.rules.CRITICAL_PROBLEMS) | .rules.CRITICAL_PROBLEMS' "$Deployment_instructions")
    mapfile -t high_problems < <(yq e '.tests[] | select(.rules.HIGH_PROBLEMS) | .rules.HIGH_PROBLEMS' "$Deployment_instructions")
    mapfile -t medium_problems < <(yq e '.tests[] | select(.rules.MEDIUM_PROBLEMS) | .rules.MEDIUM_PROBLEMS' "$Deployment_instructions")
    mapfile -t low_problems < <(yq e '.tests[] | select(.rules.LOW_PROBLEMS) | .rules.LOW_PROBLEMS' "$Deployment_instructions")
}

# Function to update selected tests array
update_selected_tests() {
    selected_tests+=("$letter")
}

# Function to generate the Tfsec needs
generate_tfsec_needs() {
    if [[ " ${selected_tests[@]} " =~ "s" ]]; then
        if [[ "${selected_tests[@]}" =~ "l" ]] || ( [[ "${selected_tests[@]}" =~ "i" ]] && [[ "${selected_tests[@]}" =~ "l" ]] ); then
            echo "TfLint"
        else
            echo "Build"
        fi
    else
        echo "Build"
    fi
}

# Function to generate the Infracost needs
generate_infracost_needs() {
    if [[ " ${selected_tests[@]} " =~ "i" ]]; then
        if [[ " ${selected_tests[@]} " =~ "l" ]]; then
            echo "TfLint"
        elif [[ " ${selected_tests[@]} " =~ "s" ]]; then
            echo "Tfsec"
        else
            echo "Build"
        fi
    fi
}

# Function to check if the selected_tests array contains a specific set of letters
contains_letters() {
    local target="$1"
    local sorted_selected_tests=$(printf "%s\n" "${selected_tests[@]}" | tr -d ' ' | grep -o . | sort | tr -d '\n')
    local sorted_target=$(echo "$target" | grep -o . | sort | tr -d '\n')

    [[ "$sorted_selected_tests" == "$sorted_target" ]]
}

# Function to get the full name of the test based on the letter
get_test_name() {
    case "$1" in
        l) echo "ConfigurationSyntax" ;;
        s) echo "Security" ;;
        i) echo "Cost" ;;
    esac
}

# Function to process each test based on the YAML input
process_tests() {
    for index in "${!test_names[@]}"; do
        test="${test_names[index]}"
        case "$test" in
            ConfigurationSyntax)
                letter="l"
                ;;
            Security)
                letter="s"
                ;;
            Cost)
                letter="i"
                ;;
        esac
        
        status="${test_status[index]}"
        
        # Set blocking status
        case "$status" in
            Blocking) blocking_status["$letter"]=false ;;
            Optional) blocking_status["$letter"]=true ;;
        esac

        # Set additional info
        case "$letter" in
            l)
                user_max_lint="${max_lint_issues[0]}"
                # Create a copy of the template file associated with the letter from templates_files
                template_file="templates_files/${letter}file.yml"
                if [ -e "$template_file" ]; then
                    cp "$template_file" "${letter}-part.yml"
                    update_selected_tests
                else
                    echo "Template file not found for letter '$letter'. Skipping..."
                fi
                ;;
            s)
                user_critical="${critical_problems[0]}"
                user_high="${high_problems[0]}"
                user_medium="${medium_problems[0]}"
                user_low="${low_problems[0]}"
                # Create a copy of the template file associated with the letter from templates_files
                template_file="templates_files/${letter}file.yml"
                if [ -e "$template_file" ]; then
                    cp "$template_file" "${letter}-part.yml"
                    update_selected_tests
                else
                    echo "Template file not found for letter '$letter'. Skipping..."
                fi
                ;;
            i)
                user_budget="${budget[0]}"
                # Create a copy of the template file associated with the letter from templates_files
                template_file="templates_files/${letter}file.yml"
                if [ -e "$template_file" ]; then
                    cp "$template_file" "${letter}-part.yml"
                    update_selected_tests
                else
                    echo "Template file not found for letter '$letter'. Skipping..."
                fi
                ;;
        esac
    done
}

file_cleaning() {
    # Perform replacements and update allow_failure, max issues, budget, and error allowance values for each test
    for letter in "${!blocking_status[@]}"; do
        replacement_file="${letter}-part.yml"

        # Check if a replacement file exists
        if [ -e "$replacement_file" ]; then
            # Update allow_failure value in the replacement file
            sed -i "s/allow_failure: .*/allow_failure: ${blocking_status["$letter"]}/" "$replacement_file"

            # Replacement in needs
            if [ -e "${replacement_file}" ]; then
                if [ "$letter" == "i" ]; then
                    if contains_letters "isl"; then
                        prev="Tfsec"
                    elif contains_letters "is"; then
                        prev="Tfsec"
                    elif contains_letters "il"; then
                        prev="TfLint"
                    else
                        prev="Build"
                    fi
                elif [ "$letter" == "s" ]; then
                    if contains_letters "isl"; then
                        prev="TfLint"
                    elif contains_letters "ls"; then
                        prev="TfLint"
                    else
                        prev="Build"
                    fi
                else
                    prev="Build"
                fi

                sed -i "s/\$prev_test/$prev/g" "${replacement_file}"
            fi

            # Replace placeholder in the output file, ignoring the specific line
            awk -v placeholder="#$letter" -v content="$(<"$replacement_file")" '{gsub(placeholder, content)}1' "$output_file" > temp_file && mv temp_file "$output_file"

            # Check if the specific line needs to be restored to the original
            if [ "$letter" == "l" ]; then
                sed -i 's/2>#l1 || true/2>\&1 || true/' "$output_file"
                echo "# Restored the specific line for TfLint" >> "$output_file"
            fi
            echo "# Replaced placeholders in $replacement_file and appended to $output_file" >> "$output_file"
        else
            echo "# No replacement file found for letter '$letter'" >> "$output_file"
        fi
    done

    # Remove template copies
    for letter in "${!blocking_status[@]}"; do
        template_copy="${letter}-part.yml"
        [ -e "${template_copy}" ] && rm "${template_copy}"
    done

    echo "Template copies removed."
    echo "Replacement completed. Generated file: ${output_file}"
}

prepare_output_array() {
    # Changing CI/CD variables
    # Initialize an empty array for variable updates
    output_array=()

    # After obtaining user inputs, add key-value pairs for selected tests
    if [[ " ${selected_tests[@]} " =~ " i " ]]; then
        output_array+=("BUDGET=${user_budget}")
    fi

    if [[ " ${selected_tests[@]} " =~ " l " ]]; then
        output_array+=("MAX_LINT_ISSUES=${user_max_lint}")
    fi

    if [[ " ${selected_tests[@]} " =~ " s " ]]; then
        output_array+=("CRITICAL_PROBLEMS=${user_critical}" "LOW_PROBLEMS=${user_low}" "MEDIUM_PROBLEMS=${user_medium}" "HIGH_PROBLEMS=${user_high}")
    fi

    # Call the second script if there are selected tests
    if [ ${#output_array[@]} -gt 0 ]; then
        ./change_CICD_Variables.sh "${output_array[@]}"
    else
        echo "No tests selected. Skipping the second script."
    fi
}

push_commit() {
    # Log in to GitLab (assuming this is already handled)
    
    # Check if the repository is initialized
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Git repository not initialized. Initializing..."
        git init
    fi
    
    # Check if the GitLab remote is set
    if git remote -v | grep -q 'origin'; then
        git remote set-url origin "https://${USER_NAME}:${gitlab_pass}@${Gitlab_url}"
        echo "GitLab remote URL updated."
    else
        git remote add origin "https://${USER_NAME}:${gitlab_pass}@${Gitlab_url}"
        echo "GitLab remote URL added."
    fi
    
    # Change the name of the file before committing
    terraform_folder="./terraform"
   # Deployment_instructions="DeploymentInstructions.yaml"
    new_output_file=".gitlab-ci.yml"
    cp "${output_file}" "${new_output_file}"
    git config user.email "${USER_EMAIL}"
    git config user.name "${USERNAME}"
    # Remove folders and files you want to delete
    # git rm -r ./Folder
    # git rm -r "${terraform_folder}/.gitlab-ci.yml"
    git branch
   # git checkout master
    git add "${terraform_folder}"
    git add "${new_output_file}"
   # git add "${Deployment_instructions}"

    git commit -m "Update GitLab CI configuration and add the terraform file"
    
    # Push changes to GitLab using embedded credentials in URL
    git push -f origin main
}

main() {
    # Initialize arrays and variables
    selected_tests=()
    declare -A blocking_status
    user_budget=0
    user_max_lint=0
    user_critical=0
    user_high=0
    user_medium=0
    user_low=0

    # Prepare the output file
    prepare_output_file

    # Read inputs from the YAML file
    read_inputs_from_yaml

    # Process the tests based on the YAML input
    process_tests

    # Perform file cleaning
    file_cleaning

    # Prepare the output array for CI/CD variables
    prepare_output_array

    ############################################
    # Extract credentials and URL from the change_CICD_Variables.sh script
    USER_NAME=$(grep USERNAME change_CICD_Variables.sh | cut -d '"' -f 2)
    PASSWORD=$(grep PASSWORD change_CICD_Variables.sh | cut -d '"' -f 2)
    LOGIN_URL=$(grep LOGIN_URL change_CICD_Variables.sh | cut -d '"' -f 2)
    GITLAB_API_URL=$(grep GITLAB_API_URL change_CICD_Variables.sh | cut -d '"' -f 2)
    PROJECT_ID=$(grep PROJECT_ID change_CICD_Variables.sh | cut -d '"' -f 2)
    ACCESS_TOKEN=$(grep ACCESS_TOKEN change_CICD_Variables.sh | cut -d '"' -f 2)
    Gitlab_url=$(grep Gitlab_url change_CICD_Variables.sh | cut -d '"' -f 2)
    gitlab_pass=$(grep gitlab_pass change_CICD_Variables.sh | cut -d '"' -f 2)

    push_commit
}

# Call the main function
main
