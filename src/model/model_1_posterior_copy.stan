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

  vector[teams_number-1] home_att_raw;
  vector[teams_number-1] away_att_raw;
  vector[teams_number-1] home_def_raw;
  vector[teams_number-1] away_def_raw;
}

transformed parameters {
  vector[games_number] log_mu_home;
  vector[games_number] log_mu_away;
  vector[teams_number] home_att;
  vector[teams_number] away_att;
  vector[teams_number] home_def;
  vector[teams_number] away_def;

  // need to make sum(att)=sum(def)=0
  for (k in 1:(teams_number-1)) {
    home_att[k] = home_att_raw[k];
    away_att[k] = away_att_raw[k];
    home_def[k] = home_def_raw[k];
    away_def[k] = away_att_raw[k];
  }
  home_att[teams_number] = -sum(home_att_raw);
  away_att[teams_number] = -sum(away_att_raw);
  home_def[teams_number] = -sum(home_def_raw);
  away_def[teams_number] = -sum(away_def_raw);

  // getting mu in log form
  log_mu_home = home_att[home_team] + away_def[away_team] + c_offset;
  log_mu_away = away_att[away_team] + home_def[home_team] + c_offset;
}

model {
  mu_home_att ~ normal(0, 0.0001);
  mu_away_att ~ normal(0, 0.0001);
  mu_home_def ~ normal(0, 0.0001);
  mu_away_def ~ normal(0, 0.0001);
  sigma2_att ~ gamma(0.1, 0.1);
  sigma2_def ~ gamma(0.1, 0.1);
  phi_home ~ uniform(0, 1);
  phi_away ~ uniform(0, 1);
  // phi_home ~ gamma(2.5, 0.05);
  // phi_away ~ gamma(2.5, 0.05);
  c_offset ~ normal(0, 0.0001);

  home_att ~ normal(mu_home_att, sigma2_att);
  away_att ~ normal(mu_away_att, sigma2_att);
  home_def ~ normal(mu_home_def, sigma2_def);
  away_def ~ normal(mu_away_def, sigma2_def);

  home_score ~ neg_binomial_2_log(log_mu_home, phi_home);
  away_score ~ neg_binomial_2_log(log_mu_away, phi_away);
}

generated quantities {
  array[games_number] int home_score_pred;
  array[games_number] int away_score_pred;

  for (i in 1:games_number) {
    home_score_pred[i] = neg_binomial_2_log_rng(log_mu_home[i], phi_home);
    away_score_pred[i] = neg_binomial_2_log_rng(log_mu_away[i], phi_away);
  }
}