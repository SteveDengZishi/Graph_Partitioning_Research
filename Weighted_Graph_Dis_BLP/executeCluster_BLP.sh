#!/bin/bash

#  Cluster_BLP.sh
#  Boost
#
#  Created by Steve DengZishi on 4/7/18.
#  Copyright © 2017 Steve DengZishi. All rights reserved.
echo -e "\nClustered Prob-Disruptive Balanced Label Propagation  Version 1.6"
echo -e "       Copyright © 2019 Steve DengZishi  New York University\n"
#prompt user for input
read -p "Please enter the fileName: " FileName
read -p "Please enter the number of clusters: " cluster
read -p "Please enter the number of partition: " shard

#compile all .cpp files to executables
g++ -o cluster clustering.cpp -std=c++11
echo -e "\ng++ compiled clustering.cpp successfully"
g++ -o RandomAssignment RandomAssignment.cpp -std=c++11
echo -e "g++ compiled RandomAssignment.cpp successfully"
g++ -o clean clean.cpp -std=c++11
echo -e "g++ compiled clean.cpp successfully"
g++ -o lp_ingredient_producer lp_ingredient_producer.cpp -std=c++11
echo -e "g++ compiled lp_ingredient_producer.cpp successfully"
g++ -o linear linear.cpp -std=c++11
echo -e "g++ compiled linear.cpp successfully"
g++ -o applyMove applyMove.cpp -std=c++11
echo -e "g++ compiled applyMove.cpp successfully"
g++ -o probDisruptiveMove probDisruptiveMove.cpp -std=c++11
echo -e "g++ compiled disruptiveMove.cpp successfully\n"
chmod +x checkConvergence.py

echo -e "Running Clustering Algorithm...\n"
./cluster $FileName $cluster

#Random initialization with clusters
echo -e "Starting random initialization...\n"
./RandomAssignment $FileName $shard

echo -e "Initialization completed\n"
#init
i=0
#start of iteration
while true

do
((++i))
echo -e "\nIn iteration" $i

if (($i>2))
then
result=($(./checkConvergence.py))
#echo ${result[0]}
#echo ${result[1]}

if [ "${result[0]}" == "TRUE" ]

then
echo -e "Increase in locality converges, ending Balanced Label Propagation"
break
fi

fi

./lp_ingredient_producer $FileName $shard > lp_ingred.txt

./linear < lp_ingred.txt | lp_solve | ./clean | sort > x_result_$i.txt

x_file=x_result_$i.txt

./applyMove $FileName $shard $x_file

done

#plotting graph after finish looping
chmod +x graph_plot.py
./graph_plot.py
