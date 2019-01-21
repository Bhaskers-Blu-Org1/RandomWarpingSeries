% This script generates the feature representation of each time series by 
% computing random features between random series and raw time-series. We
% use dynamic time warping to compute the distance between a pair of
% time-series. 
%
% Author: Lingfei Wu
% Date: 01/20/2019

function [Train,Test,Runtime] = rws_GenFea(file_dir,filename,sigma,R,DMin,DMax)
    
    % load data and generate corresponding train and test data
    timer_start = tic;
    trainData = load(strcat(file_dir,filename,'/',filename,'_TRAIN'));
    testData = load(strcat(file_dir,filename,'/',filename,'_TEST'));
    trainX = trainData(:,2:end);
    trainy = trainData(:,1);
    testX = testData(:,2:end);
    testy = testData(:,1);
    telapsed_data_load = toc(timer_start)
    [n, d] = size([trainData;testData])

    % generate random time series with variable length, where each value in
    % random series is sampled from Gaussian distribution parameterized by sigma. 
    timer_start = tic;
    rng('default')
    sampleX = cell(R,1);
    for i=1:R
        D = randi([DMin, DMax],1);
        sampleX{i} = randn(1, D)./sigma; % gaussian
    end
    [trainFeaX_random, train_dtw_time] = dtw_similarity_cell(trainX, sampleX);
    trainFeaX_random = trainFeaX_random/sqrt(R); 
    [testFeaX_random, test_dtw_time] = dtw_similarity_cell(testX, sampleX);
    testFeaX_random = testFeaX_random/sqrt(R); 
    Train = [trainy, trainFeaX_random];
    Test = [testy, testFeaX_random];
    telapsed_random_fea_gen = toc(timer_start);
    
    % Note: real_total_end_time is the real total time, including both dtw
    % and ground distance, of generating both train and test features using 
    % multithreads. user_dtw_time is the real time that accounts for 
    % computation of dtw with one thread. 
    Runtime.real_total_dtw_time = telapsed_random_fea_gen;
    Runtime.user_dtw_time = train_dtw_time + test_dtw_time;
    Runtime.user_train_dtw_time = train_dtw_time;
    Runtime.user_test_dtw_time = test_dtw_time;
end
