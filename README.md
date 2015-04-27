# Kernel Commits to Stockprice Analysis

During a recent conversation about what influences a companys performance I
pondered a question: "does the level of kernel commits have any discernable relationship 
to a companies stockprice?"

An interesting question? Well I thought it was interesting enough to do some
further analysis as a fun exercise. We selected a number of publicly listed companies 
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

```
    Company Ticker PriceDiff PercentDiff LatestPrice FirstPrice Commit_Count
1    Google   GOOG    395.38      282.41      535.38     140.00         7071
2     Intel   INTC      5.61       20.69       32.73      27.12        43082
3    Oracle   ORCL     30.98      251.05       43.32      12.34         9625
4        HP    HPQ      9.50       39.73       33.41      23.91         2718
5     Cisco   CSCO     10.97       62.65       28.48      17.51         2569
6       AMD    AMD    -17.88      -87.78        2.49      20.37         4889
7  Broadcom   BRCM     19.76       82.82       43.62      23.86         5029
8   Red Hat    RHT     61.69      483.09       74.46      12.77        50171
9       IBM    IBM     84.12       66.17      211.24     127.12        22370
10 Symantec   SYMC     -5.08      -23.51       16.53      21.61          351
11      EMC    EMC     12.35       85.59       26.78      14.43          207
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
