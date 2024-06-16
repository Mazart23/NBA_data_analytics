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
  real<lower=0> off_set;

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
  log_mu_home = home_att[home_team] + away_def[away_team] + off_set;
  log_mu_away = away_att[away_team] + home_def[home_team] + off_set;
}
model {
  mu_home_att ~ normal(3.5, 0.5);  // Adjusted for higher scores
  mu_away_att ~ normal(3.5, 0.5);  // Adjusted for higher scores
  mu_home_def ~ normal(3.5, 0.5);  // Adjusted for higher scores
  mu_away_def ~ normal(3.5, 0.5);  // Adjusted for higher scores
  sigma2_att ~ gamma(2, 0.1);
  sigma2_def ~ gamma(2, 0.1);
  off_set ~ normal(0.1, 0.1);

  home_att_raw ~ normal(mu_home_att, sigma2_att);
  away_att_raw ~ normal(mu_away_att, sigma2_att);
  home_def_raw ~ normal(mu_home_def, sigma2_def);
  away_def_raw ~ normal(mu_away_def, sigma2_def);

  home_score ~ poisson_log(log_mu_home);
  away_score ~ poisson_log(log_mu_away);
}