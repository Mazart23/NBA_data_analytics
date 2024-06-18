generated quantities {
  int home_score_pred;
  int away_score_pred;

  real mu_home_att;
  real mu_away_att;
  real mu_home_def;
  real mu_away_def;
  real sigma2_att;
  real sigma2_def;
  real phi_home;
  real phi_away;
  real c_offset;

  real log_mu_home;
  real log_mu_away;
  real home_att;
  real away_att;
  real home_def;
  real away_def;
  
  mu_home_att = normal_rng(0.2, 1);
  mu_away_att = normal_rng(0, 1);
  mu_home_def = normal_rng(-0.2, 1);
  mu_away_def = normal_rng(0, 1);
  sigma2_att = gamma_rng(10, 10);
  sigma2_def = gamma_rng(10, 10);
  // phi_home = normal_rng(10, 10);
  // phi_away = normal_rng(10, 10);
  phi_home = gamma_rng(2.5, 0.05);
  phi_away = gamma_rng(2.5, 0.05);
  c_offset = normal_rng(1, 1);

  home_att = normal_rng(mu_home_att, sigma2_att);
  away_att = normal_rng(mu_away_att, sigma2_att);
  home_def = normal_rng(mu_home_def, sigma2_def);
  away_def = normal_rng(mu_away_def, sigma2_def);

  log_mu_home = home_att + away_def + c_offset;
  log_mu_away = away_att + home_def + c_offset;

  home_score_pred = neg_binomial_2_log_rng(log_mu_home, phi_home);
  away_score_pred = neg_binomial_2_log_rng(log_mu_away, phi_away);
  
}