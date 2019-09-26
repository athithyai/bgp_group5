# bgp_group5
Group project repository for the Big Geodata Processing course, project of Citizen Science meet Big Geodata Processing: Modeling observer intensity.

The 'Waarneming' project (‘Observation’ in English) is a citizen science project where volunteers record their observations of different natural species in the Netherlands, and upload them through an online platform. The project seeks to collect and preserve the natural heritage of the Netherlands, furthermore, spreading environmental awareness for its protection and knowledge. For this research, we will be using the data from this citizen project but only considering the bird observations report, whose data structure contains the following attributes: Species, Observer, Location, Timestamp. This research seeks to link the topics of citizen science and big geodata processing by working on a case of modeling observer intensity. Our interest is to understand the dynamics of the observers with respect to different environmental factors.

The following repository aims to keep track of the coding required in the project.
Initially we use SQL queries to perform a data cleaning and exploration. Later, the use of python and several machine learning libraries for Machine Learning implementation.

Data: The data used for the SQL query can be obtained by setting a conection to the following database:

      host: gip.itc.utwente.nl
      port: 5434
      database: c211
      schema: public
      user: your-s-number-with-the-s-in-front
      password: your regular UT password

Two different students used their schemas to extract and manipulate the data:
      user: s6037054 / password: _s6037054_
      user: s6040217 / password: _s6040217_

In the procedure of the Machine Learning part it is explained which user and password should be used for each case.

----------------------------------------------------------------------------------

SQL REPRODUCIBILITY:

The SQL files are:

  1. Blockwise_Creation.sql [https://github.com/alchav06/bgp_group5/blob/master/Blockwise_Creation.sql]

DESCRIPTION: SQL querys to create the required tables for the Machine Learning input datasets.
USAGE: The user should perform the querys separated by the blank spaces in order to achieve the correct tables and results.

  2. EDA.sql [https://github.com/alchav06/bgp_group5/blob/master/EDA.sql]

DESCRIPTION: SQL querys to create the required tables and analysis for the Exploratory Data Analysis (EDA) of the tables used in the project.
USAGE: The user should perform the querys separated by the blank spaces in order to achieve the correct tables and results.

  3. monthwise_Creation.sql [https://github.com/alchav06/bgp_group5/blob/master/monthwise_Creation.sql]

DESCRIPTION: SQL querys to create the required tables for the Machine Learning input datasets.
USAGE: The user should perform the querys separated by the blank spaces in order to achieve the correct tables and results.

----------------------------------------------------------------------------------

MACHINE LEARNING REPRODUCIBILITY:

This document should provide the sufficient information to run the model and achieve the target performance that is indicated in the delivered report.

Machine Learning file is:

  1. Observer Intensity_Final.ipynb [https://github.com/alchav06/bgp_group5/blob/master/Observer%20Intensity_Final.ipynb]

DESCRIPTION: Implementation of the Machine Learning method in a Jupyter Notebook format. For each case of the Machine Learning results, the conection of the database was changed based on the name of the table and the the user/password login.
USAGE: The user should run each of the Jupyter Notebook sections in sequence and change the name of the tables and user/password login with the following to obtain the results:

user: s6037054 / password: _s6037054_
Tables names: obs_int_try, obs_int_try_jan, obs_int_try_feb, obs_int_try_mar, obs_int_try_apr, obs_int_try_may, obs_int_try_jun

user: s6040217 / password: _s6040217_
Tables names: blockwise, monthwise



