data {
    // Number of games
    int<lower=1> N_games;

    // Number of teams in the league
    int<lower=1> N_teams;

    // Home and away points scored in each game
    array[N_games] int<lower=0> home_points;
    array[N_games] int<lower=0> away_points;

    // Team index for each game
    array[N_games] int<lower=1, upper=N_teams> home_team;
    array[N_games] int<lower=1, upper=N_teams> away_team;

    // Threshold for home field advantage
    // 99% of the density should be between 0 and this value
    real home_field_advantage_threshold;
}

transformed data {
    // Section 3.3.1 https://betanalpha.github.io/assets/case_studies/prior_modeling.html
    real home_field_advantage_prior_sigma = home_field_advantage_threshold / 2.57;
}

parameters {
    // Latent offensive and defensive strength of each team
    // Hierarchical prior
    vector[N_teams] theta_offense;
    vector[N_teams] theta_defense;
    real theta_offense_bar;
    real theta_defense_bar;
    real<lower=0> sigma_offense_bar;
    real<lower=0> sigma_defense_bar;

    // Noise in the points (same for home and away teams)
    real<lower=0> sigma_points;

    // Home field advantage is extremely unlikely to be negative
    real <lower=0> home_field_advantage;
}

model {

    // Prior Modeling

    // Average strength of the teams
    theta_offense_bar ~ normal(116, 10);

    // Home field advantage
    // Put 99% of dennsity between 0 and input {home_field_advantage_threshold}
    home_field_advantage ~ normal(0, home_field_advantage_prior_sigma);

    // Variations of the teams strength
    sigma_offense_bar ~ cauchy(0, 5);
    sigma_defense_bar ~ cauchy(0, 5);

    // Individual team strength
    theta_offense ~ normal(theta_offense_bar, sigma_offense_bar);
    theta_defense ~ normal(0, sigma_defense_bar);

    // Gaussian noise in the points
    sigma_points ~ cauchy(0, 5);

    // Likelihood
    for(game in 1:N_games) {
        // Team points modeled as gaussian
        real home_points_regression = home_field_advantage + theta_offense[home_team[game]] + theta_defense[away_team[game]];
        real away_points_regression = theta_offense[away_team[game]] + theta_defense[home_team[game]];
        home_points[game] ~ normal(home_points_regression, sigma_points);
        away_points[game] ~ normal(away_points_regression, sigma_points);    
    }
}

generated quantities {

    // Remove the mean from the latent variables
    vector[N_teams] theta_defense_centered;

    for (i in 1:N_teams) {
        theta_defense_centered[i] = theta_defense[i] - mean(theta_defense);
    }

    vector[N_teams] theta_offense_centered;

    for (i in 1:N_teams) {
        theta_offense_centered[i] = theta_offense[i] - mean(theta_offense);
    }
}