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
  real<lower=0> sigma2_att;
  real<lower=0> sigma2_def;
  real<lower=0> phi_home;
  real<lower=0> phi_away;
  real<lower=0> c_offset;

  array[teams_number] real home_att;
  array[teams_number] real away_att;
  array[teams_number] real home_def;
  array[teams_number] real away_def;
}

transformed parameters {
  vector[games_number] mu_home;
  vector[games_number] mu_away;

  // getting mu
  for (i in 1:games_number) {
    mu_home[i] = exp(home_att[home_team[i]] + away_def[away_team[i]] + c_offset);
    mu_away[i] = exp(away_att[away_team[i]] + home_def[home_team[i]] + c_offset);
  }
  // mu_home = home_att[home_team] + away_def[away_team] + c_offset;
  // mu_away = away_att[away_team] + home_def[home_team] + c_offset;
}

model {
  mu_home_att ~ normal(0.2, 1);
  mu_away_att ~ normal(0.0, 1);
  mu_home_def ~ normal(-0.2, 1);
  mu_away_def ~ normal(0, 1);
  sigma2_att ~ gamma(10, 1);
  sigma2_def ~ gamma(10, 1);
  // phi_home ~ uniform(0, 1);
  // phi_away ~ uniform(0, 1);
  phi_home ~ gamma(2.5, 0.05);
  phi_away ~ gamma(2.5, 0.05);
  c_offset ~ normal(0, 1);

  home_att ~ normal(mu_home_att, sigma2_att);
  away_att ~ normal(mu_away_att, sigma2_att);
  home_def ~ normal(mu_home_def, sigma2_def);
  away_def ~ normal(mu_away_def, sigma2_def);

  // mu_home = home_att[home_team] + away_def[away_team] + c_offset;
  // mu_away = away_att[away_team] + home_def[home_team] + c_offset;
  
  home_score ~ neg_binomial_2(mu_home, phi_home);
  away_score ~ neg_binomial_2(mu_away, phi_away);
  
  // home_score ~ neg_binomial_2(mu_home, phi_home);
  // away_score ~ neg_binomial_2(mu_away, phi_away);
}

generated quantities {
  array[games_number] int home_score_pred;
  array[games_number] int away_score_pred;

  for (i in 1:games_number) {
    home_score_pred[i] = neg_binomial_2_rng(mu_home[home_team[i]], phi_home);
    away_score_pred[i] = neg_binomial_2_rng(mu_away[away_team[i]], phi_away);
  }
}