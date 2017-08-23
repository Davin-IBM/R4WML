# R4WML
R library for Watson Machine Learning (WML)

## Installation and use

```
devtools::install_github(repo = 'Davin-IBM/R4WML')
library(R4WML)
```

#### WatsonML (WML) account information (these are found in your Watson ML service in BlueMix)

```
watson_ml_creds_url <- 'https://ibm-watson-ml.mybluemix.net'
watson_ml_creds_username <- '9999e4bc-3c8c-4b56-bade-25a0deadbeef'
watson_ml_creds_password <- '8888ecf8-18f9-4ae4-bead-e5d53deadbabe'
```

#### Define your deployed endpoints

```
# Deployed WML endpoints
ml_endpoint.naive_bayes <-           'https://ibm-watson-ml.mybluemix.net/v3/wml_instances/5a239919-4deb-4aa2-b02e-4374beefdead/published_models/b7415c48-d4ea-4053-a457-4374beefdead/deployments/c2e94d8f-8004-4cb9-879c-4374beefdead/online'
ml_endpoint.logistic_regression <-   'https://ibm-watson-ml.mybluemix.net/v3/wml_instances/5a239919-4deb-4aa2-b02e-4374beefdead/published_models/ad78deec-3e7f-4f78-96d3-4374beefdead/deployments/d4dd1c64-c763-411f-9c91-4374beefdead/online'
```

#### Get authentication headers

```
watson_ml_creds_auth_headers <- get_wml_auth_headers(watson_ml_creds_url, watson_ml_creds_username, watson_ml_creds_password)
```

#### Score the data

```
data <- read.csv(file='myrecords.csv')

top_100 <- head(data, n=100)
payload <- to_wml_payload(top_100)
results <- wml_score(ml_endpoint.naive_bayes, watson_ml_creds_auth_headers, payload)
payload_scored <- from_wml_payload(results)

View(payload_scored)
```
