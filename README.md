ccc
===

ccc is Console Currency Converter. Sample usage:

```
$ ccc 45 czk usd
2.24

$ ccc 45 czk USD 2012-02-02
2.34
```

It uses free API http://currencies.apps.grandtrunk.net/ and maintains local cache in ~/.ccc/ in CSV format

Finance tools
===

**prerequesites** put ccc in your $PATH. Make sure ambar.txt is in same folder as the scripts described below.

**ambar.txt** contains lines to analyze. Each line has the following format:
```
2013-12-22      home            9.94$     lamps
#YYYY-MM-DD      type            sum     option notes
```
empty lines or lines starting from # are ignored.  Sum must be like 34czk or 2.8$ . If currency not specified then it is assumed BYR. Notes are really optional. Type can't contain spaces.

**stats_daily** will show daily report for each day of the *current* month. Sample usage:
```
$ ./stats_daily
2013-12-21 3.99$         food;
2013-12-22 16.00$        home; gadgets;
------------------------------
2013-12 19.99$
```

**stats_by_type** will show spendings per type, for specified month. If month omitted, then current month is assumed:
```
$ ./stats_by_type  2013-12

== month 2013-12 stats by type

3.99$ ( 19.96% ) food
6.00$ ( 30.02% ) gadgets
10.00$ ( 50.03% ) home
```

**convert_to_USD.pl** will convert non-USD currencies to USD.

