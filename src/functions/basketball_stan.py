import pandas as pd
import numpy as np
from cmdstanpy import CmdStanModel
import matplotlib.pyplot as plt
import seaborn as sns

def read_data(csv_file):
    # Read data from football-data csv file
    data = pd.read_csv(csv_file)
    data = data.iloc[:, [1, 2, 3, 4, 5, 23, 24, 25]]
    data['Date'] = pd.to_datetime(data['Date'], format='%d/%m/%y')
    data['HomeIndex'] = pd.factorize(data['HomeTeam'])[0] + 1
    data['AwayIndex'] = pd.factorize(data['AwayTeam'])[0] + 1
    
    # Return new data frame
    return data

def fit_model(stan_file, data, iterations, chains):
    # Fit a Stan model to the data and return the output
    
    # Building Stan data object
    teams = sorted(set(data['HomeTeam']).union(set(data['AwayTeam'])))
    training_data = {
        'nteams': len(teams),
        'ngames': len(data),
        'home_team': data['HomeIndex'].values,
        'away_team': data['AwayIndex'].values,
        'home_goals': data['FTHG'].values,
        'away_goals': data['FTAG'].values
    }
    
    # Fitting a Stan model to our training data set
    model = CmdStanModel(stan_file=stan_file)
    fit = model.sample(data=training_data, iter_sampling=iterations, chains=chains, 
                       max_treedepth=15, adapt_delta=0.99)
    
    # Returning the fitted model
    return fit

def plot_parameters(model_fit, data, model):
    # Plots one dimensional plot for parameters (attack and defence parameters for each team)
    
    teams = sorted(set(data['HomeTeam']).union(set(data['AwayTeam'])))
    
    if model in ['NB', 'PO']:
        parameters = ['home_att', 'home_def', 'away_att', 'away_def']
    elif model == 'BB':
        parameters = ['att', 'def', 'home']
    
    for param in parameters:
        fig, ax = plt.subplots(figsize=(10, 8))
        sns.pointplot(data=model_fit.stan_variable(param), ax=ax, join=False)
        ax.set_yticks(range(len(teams)))
        ax.set_yticklabels(teams)
        ax.set_title(f'{param} Estimates')
        plt.show()

def plot_parameters_2d(model_fit, data, model, point_est='median', cols='black', overall=False):
    # Plots two dimensional plots (mean attack vs. mean defence parameters)
    
    teams = sorted(set(data['HomeTeam']).union(set(data['AwayTeam'])))
    
    if model in ['NB', 'PO']:
        home_att = model_fit.stan_variable('home_att')
        home_def = model_fit.stan_variable('home_def')
        away_att = model_fit.stan_variable('away_att')
        away_def = model_fit.stan_variable('away_def')
        
        if point_est == 'mean':
            home_att_pe = np.mean(home_att, axis=0)
            home_def_pe = np.mean(home_def, axis=0)
            away_att_pe = np.mean(away_att, axis=0)
            away_def_pe = np.mean(away_def, axis=0)
        else:
            home_att_pe = np.median(home_att, axis=0)
            home_def_pe = np.median(home_def, axis=0)
            away_att_pe = np.median(away_att, axis=0)
            away_def_pe = np.median(away_def, axis=0)
        
        if overall:
            attack_average = (home_att_pe + away_att_pe) / 2
            defence_average = (home_def_pe + away_def_pe) / 2
            fig, ax = plt.subplots(figsize=(10, 8))
            ax.scatter(attack_average, defence_average, color=cols)
            for i, team in enumerate(teams):
                ax.text(attack_average[i], defence_average[i], team, fontsize=9)
            ax.axhline(0, color='gray', linewidth=0.5)
            ax.axvline(0, color='gray', linewidth=0.5)
            ax.set_xlabel('Attack')
            ax.set_ylabel('Defence')
            ax.set_title('Overall Effects')
            plt.show()
        else:
            fig, ax = plt.subplots(1, 2, figsize=(20, 8))
            ax[0].scatter(home_att_pe, home_def_pe, color=cols)
            for i, team in enumerate(teams):
                ax[0].text(home_att_pe[i], home_def_pe[i], team, fontsize=9)
            ax[0].axhline(0, color='gray', linewidth=0.5)
            ax[0].axvline(0, color='gray', linewidth=0.5)
            ax[0].set_xlabel('Attack')
            ax[0].set_ylabel('Defence')
            ax[0].set_title('Home Effects')
            
            ax[1].scatter(away_att_pe, away_def_pe, color=cols)
            for i, team in enumerate(teams):
                ax[1].text(away_att_pe[i], away_def_pe[i], team, fontsize=9)
            ax[1].axhline(0, color='gray', linewidth=0.5)
            ax[1].axvline(0, color='gray', linewidth=0.5)
            ax[1].set_xlabel('Attack')
            ax[1].set_ylabel('Defence')
            ax[1].set_title('Away Effects')
            plt.show()
    elif model == 'BB':
        att = model_fit.stan_variable('att')
        def_ = model_fit.stan_variable('def')
        
        if point_est == 'mean':
            att_pe = np.mean(att, axis=0)
            def_pe = np.mean(def_, axis=0)
        else:
            att_pe = np.median(att, axis=0)
            def_pe = np.median(def_, axis=0)
        
        fig, ax = plt.subplots(figsize=(10, 8))
        ax.scatter(att_pe, def_pe, color=cols)
        for i, team in enumerate(teams):
            ax.text(att_pe[i], def_pe[i], team, fontsize=9)
        ax.axhline(0, color='gray', linewidth=0.5)
        ax.axvline(0, color='gray', linewidth=0.5)
        ax.set_xlabel('Attack')
        ax.set_ylabel('Defence')
        ax.set_title('Team Effects')
        plt.show()

# Example usage:
# data = read_data('path_to_data.csv')
# fit = fit_model('path_to_stan_file.stan', data, iterations=2000, chains=4)
# plot_parameters(fit, data, model='NB')
# plot_parameters_2d(fit, data, model='NB', point_est='median', cols='black', overall=False)
