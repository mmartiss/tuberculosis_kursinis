# tuberculosis_kursinis

Virulentiškumo genetinių determinančių paieška Mycobacterium tuberculosis pangenome

main.R - R code, grafiko generavimui ir data analizavimui

Toje pacioje direktorijoje egzistuojantys csv, tsv, treefile files reikalingi R kodo paleidimui.

Git repozitorijoje truksta siu files:
slurm_scripts/amrFinder/protein/faa/GCF_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic.faa
slurm_scripts/panaroo/new/input/GCF_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic.gff
slurm_scripts/prokka/results/GCF_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic
slurm_scripts/prokka/results/results_GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic/GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic.err
slurm_scripts/prokka/results/results_GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic/GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic.faa
slurm_scripts/prokka/results/results_GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic/GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic.ffn
slurm_scripts/prokka/results/results_GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic/GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic.fna
slurm_scripts/prokka/results/results_GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic/GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic.fsa
slurm_scripts/prokka/results/results_GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic/GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic.gbk
slurm_scripts/prokka/results/results_GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic/GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic.gff
slurm_scripts/prokka/results/results_GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic/GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic.log
slurm_scripts/prokka/results/results_GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic/GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic.sqn
slurm_scripts/prokka/results/results_GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic/GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic.tbl
slurm_scripts/prokka/results/results_GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic/GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic.tsv
slurm_scripts/prokka/results/results_GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic/GCA_038955375.1_MTBCR170913_-_1.1.1.7_hybrid_assembly_genomic.txt

Jie buvo prideti i .gitignore
Taciau veliau buvo paleista komanda:
git config --system core.longpaths true