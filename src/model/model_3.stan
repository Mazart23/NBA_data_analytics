data {
  int<lower=0> teams_number;
  int<lower=0> games_number;
  array[games_number] int home_team;
  array[games_number] int away_team;
  array[games_number] int<lower=0> home_score;
  array[games_number] int<lower=0> away_score;
}
parameters {
  real mu_att;  // mean attack strength across all teams
  real mu_def;  // mean defense strength across all teams
  real<lower=0> sigma_att;
  real<lower=0> sigma_def;
  real home_advantage;  // home advantage parameter
  
  vector[teams_number] attack;
  vector[teams_number] defense;
}
transformed parameters {
  vector[games_number] log_mu_home;
  vector[games_number] log_mu_away;
  
  for (g in 1:games_number) {
    log_mu_home[g] = home_advantage + attack[home_team[g]] - defense[away_team[g]];
    log_mu_away[g] = attack[away_team[g]] - defense[home_team[g]];
  }
}
model {
  // Priors
  mu_att ~ normal(100, 20);
  mu_def ~ normal(100, 20);
  home_advantage ~ normal(0, 5);
  sigma_att ~ gamma(2, 0.1);
  sigma_def ~ gamma(2, 0.1);
  
  attack ~ normal(mu_att, sigma_att);
  defense ~ normal(mu_def, sigma_def);
  
  home_score ~ poisson_log(log_mu_home);
  away_score ~ poisson_log(log_mu_away);
}
