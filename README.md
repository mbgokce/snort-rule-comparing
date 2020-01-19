# snort-rule-comparing
Snort Community Rules Comparing

This script determines the different rules between the old rules and the new rules and moves them to the directories 
named oldrulediff and newrulediff. Then reads the new rules according to the SID values in the old rules and adds them 
to the relevant rule file in the newrules directory. If there are rules added in the new rules, it adds them to the 
end of the related rule file under newrules.  In this way, you can clearly see the changes made in the rules with the 
compare plugin in notepad ++.

Note: Some rule files may give erroneous results!
