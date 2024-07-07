generated quantities {
  int home_score_pred;
  int away_score_pred;

  real mu_home_att;
  real mu_away_att;
  real mu_home_def;
  real mu_away_def;
  real sigma_att;
  real sigma_def;
  real theta_home;
  real theta_away;
  real home_advantage;
  real c_offset;

  real<lower=0> phi_home;
  real<lower=0> phi_away;

  real mu_home;
  real mu_away;
  real home_att;
  real away_att;
  real home_def;
  real away_def;
  
  mu_home_att = normal_rng(0, 0.001);
  mu_away_att = normal_rng(0, 0.001);
  mu_home_def = normal_rng(0, 0.001);
  mu_away_def = normal_rng(0, 0.001);

  sigma_att = gamma_rng(0.2, 0.1);
  sigma_def = gamma_rng(0.2, 0.1);

  c_offset = normal_rng(4.25, 0.25);
  home_advantage = normal_rng(0.1, 0.01);

  phi_home = gamma_rng(5, 0.25);
  phi_away = gamma_rng(5, 0.25);

  home_att = normal_rng(mu_home_att, sigma_att);
  away_att = normal_rng(mu_away_att, sigma_att);
  home_def = normal_rng(mu_home_def, sigma_def);
  away_def = normal_rng(mu_away_def, sigma_def);

  theta_home = exp(home_att + away_def + c_offset + home_advantage);
  theta_away = exp(away_att + home_def + c_offset);
  
  home_score_pred = neg_binomial_2_rng(theta_home, phi_home);
  away_score_pred = neg_binomial_2_rng(theta_away, phi_away);
}