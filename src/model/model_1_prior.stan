generated quantities{
    int home_score_pred;
    int away_score_pred;

    real mu_home_att;
    real mu_away_att;
    real mu_home_def;
    real mu_away_def;
    real sigma2_att;
    real sigma2_def;

    real log_mu_home;
    real log_mu_away;
    real home_att;
    real away_att;
    real home_def;
    real away_def;

    mu_home_att = normal_rng(5.0, 0.2);  // Further adjusted mean and reduced variance
    mu_away_att = normal_rng(5.0, 0.2);  // Further adjusted mean and reduced variance
    mu_home_def = normal_rng(3.5, 0.5);  // As before
    mu_away_def = normal_rng(3.5, 0.5);  // As before
    sigma2_att = gamma_rng(2, 0.1);  // As before
    sigma2_def = gamma_rng(2, 0.1);  // As before

    home_att = normal_rng(mu_home_att, sigma2_att);
    away_att = normal_rng(mu_away_att, sigma2_att);
    home_def = normal_rng(mu_home_def, sigma2_def);
    away_def = normal_rng(mu_away_def, sigma2_def);

    log_mu_home = home_att + away_def + log(mu_home_att);
    log_mu_away = away_att + home_def + log(mu_away_att);

    home_score_pred = poisson_log_rng(log_mu_home);
    away_score_pred = poisson_log_rng(log_mu_away);
}