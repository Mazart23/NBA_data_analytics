import numpy as np
import pandas as pd
from scipy.stats import nbinom, poisson

def scores_probability_table(predicted_scores, home_team, away_team, rounding):
    # Obtains a scoreline probability table by assuming independence and multiplying posterior probability of goals scored
    # Returns dict containing: data frame with number of goals scored by the home team along the columns and 
    #                          number of goals scored along the rows
    
    A = np.zeros(7)
    B = np.zeros(7)
    for i in range(6):
        A[i] = predicted_scores[0][i] / np.sum(predicted_scores[0])
        B[i] = predicted_scores[1][i] / np.sum(predicted_scores[1])
    
    A[6] = 1 - np.sum(A[:6])
    B[6] = 1 - np.sum(B[:6])
    
    name = ["0", "1", "2", "3", "4", "5", "6+"]
    C = pd.DataFrame(index=name, columns=name)
    
    for i in range(7):
        for j in range(7):
            C.iloc[i, j] = A[j] * B[i]
    
    C = C.round(rounding)
    
    # Return predicted scores along with the home and away team for reference
    predictions = {'HomeTeam': home_team, 'AwayTeam': away_team, 'score_probabilities': C}
    return predictions

def predict_game(model_fit, data, home_team, away_team, model, score_lines=False, rounding=3):
    # Predicts a game between specified teams (either match outcome probabilities or predicts scorelines)
    
    teams = sorted(list(set(data['HomeTeam']).union(set(data['AwayTeam']))))
    
    # Checking that the teams are spelt correctly
    if home_team not in teams or away_team not in teams:
        print('Team specified is not in the dataset.')
        print(f'Game: {home_team} vs. {away_team} not predicted')
        return None
    
    # Getting index locations for teams
    home_index = teams.index(home_team)
    away_index = teams.index(away_team)
    
    list_of_draws = model_fit.extract()
    number_of_samples = len(list_of_draws['lp__'])
    
    if model == 'NB':
        # Extracting the samples that we need
        home_att = list_of_draws['home_att'][:, home_index]
        home_def = list_of_draws['home_def'][:, home_index]
        away_att = list_of_draws['away_att'][:, away_index]
        away_def = list_of_draws['away_def'][:, away_index]
        size_home = list_of_draws['phi_home']
        size_away = list_of_draws['phi_away']
        
        # Creating the log_mu parameters
        log_mu1 = home_att + away_def
        log_mu2 = home_def + away_att
        
        # Simulating from a negative binomial distribution to obtain predictive distribution
        y1 = np.array([nbinom.rvs(size=size_home[i], p=np.exp(log_mu1[i]) / (np.exp(log_mu1[i]) + size_home[i])) for i in range(number_of_samples)])
        y2 = np.array([nbinom.rvs(size=size_away[i], p=np.exp(log_mu2[i]) / (np.exp(log_mu2[i]) + size_away[i])) for i in range(number_of_samples)])
        
    elif model == 'PO':
        # Extracting the samples that we need
        home_att = list_of_draws['home_att'][:, home_index]
        home_def = list_of_draws['home_def'][:, home_index]
        away_att = list_of_draws['away_att'][:, away_index]
        away_def = list_of_draws['away_def'][:, away_index]
        
        # Creating the log_mu parameters
        log_mu1 = home_att + away_def
        log_mu2 = home_def + away_att
        
        # Simulating from a Poisson distribution to obtain predictive distribution
        y1 = np.array([poisson.rvs(mu=np.exp(log_mu1[i])) for i in range(number_of_samples)])
        y2 = np.array([poisson.rvs(mu=np.exp(log_mu2[i])) for i in range(number_of_samples)])
        
    elif model == 'BB':
        # Extracting the samples that we need
        home = list_of_draws['home']
        att_home = list_of_draws['att'][:, home_index]
        att_away = list_of_draws['att'][:, away_index]
        def_home = list_of_draws['def'][:, home_index]
        def_away = list_of_draws['def'][:, away_index]
        
        # Creating the log_theta parameters
        log_theta1 = home + att_home + def_away
        log_theta2 = att_away + def_home
        
        # Simulating from a Poisson distribution to obtain predictive distribution
        y1 = np.array([poisson.rvs(mu=np.exp(log_theta1[i])) for i in range(number_of_samples)])
        y2 = np.array([poisson.rvs(mu=np.exp(log_theta2[i])) for i in range(number_of_samples)])
    
    if score_lines:
        # Creating a list that has the table for the simulated goals scored
        predicted_scores = [np.bincount(y1, minlength=7), np.bincount(y2, minlength=7)]
        scores = scores_probability_table(predicted_scores, home_team, away_team, rounding)
        
        # Return the predicted score probabilities
        return scores
    else:
        # Calculating the estimated probabilities of events in data frame format
        outcome_probabilities = pd.DataFrame({
            home_team: [np.mean(y1 > y2)],
            'Draw': [np.mean(y1 == y2)],
            away_team: [np.mean(y1 < y2)]
        })
        
        # Return data frame of probabilities for the match outcomes
        return outcome_probabilities

def simulate_game(model_fit, data, home_team, away_team, model, number_of_simulations=1):
    # Predicts a game between specified teams (either match outcome probabilities or predicts scorelines)
    
    teams = sorted(list(set(data['HomeTeam']).union(set(data['AwayTeam']))))
    
    # Checking that the teams are spelt correctly
    if home_team not in teams or away_team not in teams:
        print('Team specified is not in the dataset.')
        print(f'Game: {home_team} vs. {away_team} not simulated')
        return None
    
    # Getting index locations for teams
    home_index = teams.index(home_team)
    away_index = teams.index(away_team)
    
    list_of_draws = model_fit.extract()
    number_of_samples = len(list_of_draws['lp__'])
    
    if model == 'NB':
        # Extracting a random sample from the model fit
        random = np.random.choice(number_of_samples, number_of_simulations, replace=False)
        home_att = list_of_draws['home_att'][:, home_index][random]
        home_def = list_of_draws['home_def'][:, home_index][random]
        away_att = list_of_draws['away_att'][:, away_index][random]
        away_def = list_of_draws['away_def'][:, away_index][random]
        size_home = list_of_draws['phi_home'][random]
        size_away = list_of_draws['phi_away'][random]
        
        # Creating the log_mu parameters
        log_mu1 = home_att + away_def
        log_mu2 = home_def + away_att
        
        # Simulating from a negative binomial distribution to obtain predictive distribution
        y1 = np.array([nbinom.rvs(size=size_home[i], p=np.exp(log_mu1[i]) / (np.exp(log_mu1[i]) + size_home[i])) for i in range(number_of_simulations)])
        y2 = np.array([nbinom.rvs(size=size_away[i], p=np.exp(log_mu2[i]) / (np.exp(log_mu2[i]) + size_away[i])) for i in range(number_of_simulations)])
        
    elif model == 'PO':
        # Extracting a random sample from the model fit
        random = np.random.choice(number_of_samples, number_of_simulations, replace=False)
        home_att = list_of_draws['home_att'][:, home_index][random]
        home_def = list_of_draws['home_def'][:, home_index][random]
        away_att = list_of_draws['away_att'][:, away_index][random]
        away_def = list_of_draws['away_def'][:, away_index][random]
        
        # Creating the log_mu parameters
        log_mu1 = home_att + away_def
        log_mu2 = home_def + away_att
        
        # Simulating from a Poisson distribution to obtain predictive distribution
        y1 = np.array([poisson.rvs(mu=np.exp(log_mu1[i])) for i in range(number_of_simulations)])
        y2 = np.array([poisson.rvs(mu=np.exp(log_mu2[i])) for i in range(number_of_simulations)])
        
    elif model == 'BB':
        # Extracting a random sample from the model fit
        random = np.random.choice(number_of_samples, number_of_simulations, replace=False)
        home = list_of_draws['home'][random]
        att_home = list_of_draws['att'][:, home_index][random]
        att_away = list_of_draws['att'][:, away_index][random]
        def_home = list_of_draws['def'][:, home_index][random]
        def_away = list_of_draws['def'][:, away_index][random]
        
        # Creating the log_theta parameters
        log_theta1 = home + att_home + def_away
        log_theta2 = att_away + def_home
        
        # Simulating from a Poisson distribution to obtain predictive distribution
        y1 = np.array([poisson.rvs(mu=np.exp(log_theta1[i])) for i in range(number_of_simulations)])
        y2 = np.array([poisson.rvs(mu=np.exp(log_theta2[i])) for i in range(number_of_simulations)])
    
    simulated_games = pd.DataFrame({home_team: y1, away_team: y2})
    
    # Return data frame of simulated games
    return simulated_games
