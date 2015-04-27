# Kernel Commits to Stockprice Analysis

During a recent conversation about what influences a companys performance I
pondered if the level of kernel commits has any discernable relationship to stockprice.

An interesting question? Well I thought it was interesting enough to do some
further analysis as a fun exercise.  We selected a number of publicly listed companies 
who contribute code relatively frequently to the Linux kernel for our analysis.

## Findings

No obvious correlation was found. Of the three largest committers to the kernel, Red Hat, Intel
and IBM respectively, only Red Hat has seen significant stock price growth.   

![Stockprice Percentage Difference](https://github.com/fintanr/kernel-stockprice/blob/master/stockprice-percent-diff.png)	

![Total Kernel Commits](https://github.com/fintanr/kernel-stockprice/blob/master/total-kernel-commits.png)

A simple test for [Spearmans Rho](https://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient) confirmed 
this lack of correlation.

```
	Spearman's rank correlation rho

data:  theVals$Commit_Count and theVals$PercentDiff
S = 194, p-value = 0.3083
alternative hypothesis: true rho is not equal to 0
sample estimates:
      rho 
0.3216783 
``` 

## Data Gathering & Processing

Firstly we generated a data set which correlated company commits to kernel release
from the data provided at [http://www.remword.com/kps_result/](http://www.remword.com/kps_result/).

We then processed this data, and cross referenced with stock prices from approximate 
dates of the kernel releases. We extracted the stock price at approximately the first
kernel release a company committed code too and again for the most recent kernel which
code was committed too.

## Rerunning this analysis

All of the code required for this analysis is included in this repo. You may need 
to install a number of perl modules to run the `kernelCommitsCompany.pl` script.

Firstly generate our tidy data set with `kernelCommitsCompany.pl` and then execute
`kcommits-analysis.R`. For this work I was in RStudio. 
