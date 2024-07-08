generated quantities {
  real home_score_pred;
  real away_score_pred;

  real mu_home_att;
  real mu_away_att;
  real mu_home_def;
  real mu_away_def;
  real sigma2_att;
  real sigma2_def;
  real phi_home;
  real phi_away;
  real c_offset;

  real mu_home;
  real mu_away;
  real home_att;
  real away_att;
  real home_def;
  real away_def;
  
  mu_home_att = normal_rng(22, 5);   // Zwiększenie średniej ataku dla gospodarzy
  mu_away_att = normal_rng(20, 5);   // Zwiększenie średniej ataku dla gości
  mu_home_def = normal_rng(-5, 5);   // Zmniejszenie średniej obrony dla gospodarzy
  mu_away_def = normal_rng(0, 5);    // Zmniejszenie średniej obrony dla gości
  sigma2_att = gamma_rng(15, 1);     // Zmniejszenie odchylenia standardowego ataku
  sigma2_def = gamma_rng(15, 1);     // Zmniejszenie odchylenia standardowego obrony

  phi_home = gamma_rng(2.5, 0.5);    // Zwiększenie skali odchylenia standardowego dla gospodarzy
  phi_away = gamma_rng(2.5, 0.5);    // Zwiększenie skali odchylenia standardowego dla gości
  c_offset = normal_rng(100, 5);     // Zwiększenie średniej offsetu

  home_att = normal_rng(mu_home_att, sigma2_att);
  away_att = normal_rng(mu_away_att, sigma2_att);
  home_def = normal_rng(mu_home_def, sigma2_def);
  away_def = normal_rng(mu_away_def, sigma2_def);

  mu_home = home_att + away_def + c_offset;
  mu_away = away_att + home_def + c_offset;

  home_score_pred = normal_rng(mu_home, phi_home);
  away_score_pred = normal_rng(mu_away, phi_away);

}
