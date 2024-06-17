data {
  int<lower=0> teams_number;
  int<lower=0> games_number;
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
    log_mu_home[g] = home_advantage + attack[home_team[g]] - defense[away_team[g]] + log(100); // Adding offset
    log_mu_away[g] = attack[away_team[g]] - defense[home_team[g]] + log(100); // Adding offset
  }
}
model {
  // Priors
  mu_att ~ normal(3, 1);  // Higher mean for attack
  mu_def ~ normal(3, 1);  // Higher mean for defense
  home_advantage ~ normal(0.5, 0.2);  // Adjusted home advantage
  sigma_att ~ gamma(2, 0.5);  // Adjusted variance for attack
  sigma_def ~ gamma(2, 0.5);  // Adjusted variance for defense
  
  attack ~ normal(mu_att, sigma_att);
  defense ~ normal(mu_def, sigma_def);
  
  home_score ~ poisson_log(log_mu_home);
  away_score ~ poisson_log(log_mu_away);
}