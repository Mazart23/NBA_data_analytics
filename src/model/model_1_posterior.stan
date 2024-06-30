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
  array[teams_number] real mu_home;
  array[teams_number] real mu_away;

  for (k in 1:(teams_number)) {
    mu_home[k] = home_att[k] + away_def[k] + c_offset;
    mu_away[k] = away_att[k] + home_def[k] + c_offset;
  }
}

model {
  mu_home_att ~ normal(0.2, 1);
  mu_away_att ~ normal(0.0, 1);
  mu_home_def ~ normal(-0.2, 1);
  mu_away_def ~ normal(0, 1);
  sigma2_att ~ gamma(10, 1);
  sigma2_def ~ gamma(10, 1);
  phi_home ~ gamma(2.5, 0.05);
  phi_away ~ gamma(2.5, 0.05);
  c_offset ~ normal(115, 1);

  home_att ~ normal(mu_home_att, sigma2_att);
  away_att ~ normal(mu_away_att, sigma2_att);
  home_def ~ normal(mu_home_def, sigma2_def);
  away_def ~ normal(mu_away_def, sigma2_def);

  for (k in 1:(games_number)) {
    home_score[k] ~ neg_binomial_2(mu_home[home_team[k]], phi_home);
    away_score[k] ~ neg_binomial_2(mu_away[away_team[k]], phi_away);
  }
}

generated quantities {
  array[games_number] int home_score_pred;
  array[games_number] int away_score_pred;
  array[games_number] real log_lik_home;
  array[games_number] real log_lik_away;

  for (i in 1:games_number) {
    home_score_pred[i] = neg_binomial_2_rng(mu_home[home_team[i]], phi_home);
    away_score_pred[i] = neg_binomial_2_rng(mu_away[away_team[i]], phi_away);
    
    log_lik_home[i] = neg_binomial_2_lpmf(home_score[i] | mu_home[home_team[i]], phi_home);
    log_lik_away[i] = neg_binomial_2_lpmf(away_score[i] | mu_away[away_team[i]], phi_away);
  }
}
