# Helper to resolve active AWS context safely without throwing if env vars are unset
def get-aws-context [] {
  let profile = ($env.AWS_PROFILE? | default "eu-dev")
  let parts = ($profile | split row "-")
  let prefix = ($parts | get -o 0 | default "eu")
  let env_name = ($parts | get -o 1 | default "dev")
  let region = match $prefix {
    "eu" => ($env.EU_REGION? | default "eu-central-1")
    "us" => ($env.US_REGION? | default "us-east-1")
    $other => ($env.AWS_REGION? | default $other)
  }
  {
    profile: $profile,
    prefix: $prefix,
    env: $env_name,
    region: $region
  }
}

def nu-aws-jobs-runs [job_name: string, max_results?: int] {
  aws glue get-job-runs --job-name $job_name --max-results ($max_results | default 55)
  | from json
  | get JobRuns
  | each {|row|
        {
            Id: $row.Id,
            StartedOn: ($row.StartedOn | into datetime),
            ExecutionTime: ($row.ExecutionTime | into duration --unit sec),
            JobRunState: $row.JobRunState,
            Arguments: $row.Arguments
        }
    }
}

def nu-aws-ls [folder?: string] {
  let ctx = (get-aws-context)
  let project_env = ($env.PROJECT_ENV? | default "dev")
  let data_owner = ($env.DATA_OWNER? | default "")
  let project_name = ($env.PROJECT_NAME? | default "")
  let base_path: string = $"s3://($project_env)-($ctx.env)-($ctx.region)-($data_owner)-($project_name)"
  let s3_path: string = if $folder != null { $"($base_path)/($folder)/" } else { $base_path }

  aws s3 ls $s3_path --recursive --human-readable
  | detect columns --no-headers
  | update column0 {|row| $"($row.column0) ($row.column1)" }
  | update column2 {|row| $"($row.column2) ($row.column3)" }
  | select column0 column2 column4
  | rename modified-date file-size aws-s3-path
  | update aws-s3-path {|row| $"($base_path)/($row.aws-s3-path)" }
}

def nu-aws-get-secrets [secret_id: string] {
  aws secretsmanager get-secret-value --secret-id $secret_id 
  | from json 
  | get SecretString
  | from json
}
