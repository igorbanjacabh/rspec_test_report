rspec_test_report: Web app used for rspec test reports
======================================================

This project is directly related to https://github.com/ATLANTBH/rspec and uses its database from which it pulls the results and shows them on web app dashboard.

Following steps needed fo installation:

1. Run gem install padrino to install latest version of padrino framework

2. Run bundle install to install dependencies needed for rspec_test_report application

3. Configure database config file params to point to correct database where results are stored (rspec_test_report/config/database.rb)

4. Run padrino rake ar:migrate to create accounts db table from existing model

5. Run padrino start from the rspec_test_report directory to start the application 
