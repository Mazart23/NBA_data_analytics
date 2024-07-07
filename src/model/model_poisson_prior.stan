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
  real home_advantage;

  real mu_home;
  real mu_away;
  real home_att;
  real away_att;
  real home_def;
  real away_def;
  
  c_offset = normal_rng(0, 0.0001);
  home_advantage = normal_rng(0, 0.0001);

  mu_home_att = normal_rng(0, 0.0001);;
  mu_away_att = normal_rng(0, 0.0001);
  mu_home_def = normal_rng(0, 0.0001);
  mu_away_def = normal_rng(0, 0.0001);
  sigma2_att = gamma_rng(0.1, 0.1);
  sigma2_def = gamma_rng(0.1, 0.1);
  real theta_home;
  real theta_away;

  home_att = normal_rng(mu_home_att, sigma2_att);
  away_att = normal_rng(mu_away_att, sigma2_att);
  home_def = normal_rng(mu_home_def, sigma2_def);
  away_def = normal_rng(mu_away_def, sigma2_def);

  theta_home = exp(home_att + away_def + c_offset + home_advantage);
  theta_away = exp(away_att + home_def + c_offset);

  home_score_pred = poisson_rng(theta_home);
  away_score_pred = poisson_rng(theta_away);
  
}