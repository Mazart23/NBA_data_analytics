data {
  int teams_number;
  int games_number;
  array[games_number] int home_team;
  array[games_number] int away_team;
  array[games_number] int<lower=0> home_score;
  array[games_number] int<lower=0> away_score;
}

parameters {
  real mu_home_att;
  real mu_away_att;
  real mu_home_def;
  real mu_away_def;
  real<lower=0> sigma_att;
  real<lower=0> sigma_def;
  real c_offset;
  real home_advantage;

  vector[teams_number] raw_home_att;
  vector[teams_number] raw_away_att;
  vector[teams_number] raw_home_def;
  vector[teams_number] raw_away_def;

}

transformed parameters {
  vector[teams_number] home_att;
  vector[teams_number] away_att;
  vector[teams_number] home_def;
  vector[teams_number] away_def;
  vector[games_number] theta_home;
  vector[games_number] theta_away;

  home_att = raw_home_att - mean(raw_home_att);
  away_att = raw_away_att - mean(raw_away_att);
  home_def = raw_home_def - mean(raw_home_def);
  away_def = raw_away_def - mean(raw_away_def);

  for (i in 1:games_number) {
    theta_home[i] = exp(home_att[home_team[i]] + away_def[away_team[i]] + c_offset + home_advantage);
    theta_away[i] = exp(away_att[away_team[i]] + home_def[home_team[i]] + c_offset);
  }
}

model {
  c_offset ~ normal(4, 0.1);
  home_advantage ~ normal(0.5, 0.1);

  mu_home_att ~ normal(0.1, 0.01);
  mu_away_att ~ normal(0.1, 0.01);
  mu_home_def ~ normal(0, 0.01);
  mu_away_def ~ normal(0, 0.01);
  sigma_att ~ gamma(0.1, 0.1);
  sigma_def ~ gamma(0.1, 0.1);

  raw_home_att ~ normal(mu_home_att, sigma_att);
  raw_away_att ~ normal(mu_away_att, sigma_att);
  raw_home_def ~ normal(mu_home_def, sigma_def);
  raw_away_def ~ normal(mu_away_def, sigma_def);

  home_score ~ poisson(theta_home);
  away_score ~ poisson(theta_away);
}

generated quantities {
  array[games_number] int home_score_pred;
  array[games_number] int away_score_pred;

  for (i in 1:games_number) {
    home_score_pred[i] = poisson_rng(theta_home[i]);
    away_score_pred[i] = poisson_rng(theta_away[i]);
  }
}