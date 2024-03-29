"""
1. clustering leafcutter 
2. peer
3. covariate table
4. differential splicing
5. filtering by FDR
"""
#.junc file
echo filename.junc >> filename.txt ## the txt file contains the path of .junc file

''' find the 712 junc file and put the full path of each file in txt file '''
# for file in `ls /data01/private/projects/splicing_cll/data/cllmap/leafcutter/junctions_official_names/`
# do
# path='/home/ls/rachelcw/projects/LEAFCUTTER/ccle/junctions/'
# fullpath=$path$file
# echo $fullpath >> ccle_juncfiles_20230204.txt
# done
for file in `ls /data01/private/projects/splicing_cll/data/cllmap/leafcutter/junctions_official_names/`
do
echo $file >> /home/ls/rachelcw/projects/LEAFCUTTER/eden/juncion_files.txt
done

mv ./*.sorted.gz /home/ls/rachelcw/projects/LEAFCUTTER/sorted/


# clustering the junc file
lc_py="/home/ls/rachelcw/projects/LEAFCUTTER/leafcutter/clustering/leafcutter_cluster.py"
junc_file="/home/ls/rachelcw/projects/LEAFCUTTER/eden/juncfiles.txt"
output="leafcutter.20230730"

python $lc_py -j $junc_file -o $output -s 1

#differential splicing
/home/ls/rachelcw/projects/LEAFCUTTER/leafcutter/scripts/leafcutter_ds.R --num_threads 4 /home/ls/rachelcw/projects/LEAFCUTTER/712_lc_20221026/712_lc_20221026_perind_numers.counts.gz /home/ls/rachelcw/projects/LEAFCUTTER/groups_file.txt

## DOCKER ##
docker pull gcr.io/broad-cga-francois-gtex/leafcutter:latest
docker run -ti --rm gcr.io/broad-cga-francois-gtex/leafcutter:latest
#The “-ti” opens the docker image like you’re exploring a file system.
cd /opt
ls -l
And you find it at /opt/leafcutter/leafcutter/R/differential_splicing.R
Now you can run it using something like: 
garrettjenkinson/ubuntu18leafcutter:v0.2.9.1 /leafcutter/scripts/leafcutter_ds

#leafcutter_ds.R
docker run -v /home/ls/rachelcw/projects/LEAFCUTTER/:/data --rm garrettjenkinson/ubuntu18leafcutter:v0.2.9.1 Rscript /leafcutter/scripts/leafcutter_ds.R /data/lc_20230512/lc_20230512_perind_numers.counts.gz /data/DS/DS.five_percent/groups_file.analysis.20230108/groups_file_a4.txt -o /data/analysis.20230512/ds.a4.20230512 -p 4 -e /data/annontation_code.20221225_all_exons.txt.gz --seed 613
 #ds_plots.pdf 
docker run -v /home/ls/rachelcw/projects/LEAFCUTTER/:/data --rm garrettjenkinson/ubuntu18leafcutter:v0.2.9.1 Rscript /leafcutter/scripts/ds_plots.R /data/lc_20221211/lc_20221211_perind_numers.counts.gz /data/groups_file_peer.txt /data/DS/lc_ds_20221213_cluster_significance.txt -f 0.05 -o /data/DS/ds_plots.pdf
[connect your files with -v of course]
# gtf_to_exons
docker run -v /home/ls/rachelcw/projects/LEAFCUTTER/:/data --rm garrettjenkinson/ubuntu18leafcutter:v0.2.9.1 Rscript /leafcutter/scripts/gtf_to_exons.R  /data/gencode.v42

#gtf2leafcutter
./gtf2leafcutter.pl -o /home/ls/rachelcw/projects/BIO/gencode.v42 "/private1/private/resources/gencode.v42.annotation.gtf.gz"


#leafviz
docker run -v /home/ls/rachelcw/projects/LEAFCUTTER/leafviz/:/data --rm garrettjenkinson/ubuntu18leafcutter:v0.2.9.1 Rscript /leafcutter/leafviz/prepare_results.R -m /data/groups_file_a2.txt  /data/lc_20230512_perind_numers.counts.gz /data/ds.a2.20230512_cluster_significance.txt /data/ds.a2.20230512_effect_sizes.txt /data/annontation_code.20221225 -o /data/results.RData