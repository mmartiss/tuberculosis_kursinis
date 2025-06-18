#!/bin/bash
#SBATCH --job-name=panaroo_new
#SBATCH --output=logs/panaroo_%j.log
#SBATCH -p main
#SBATCH --cpus-per-task=14
#SBATCH --mem=16G
#SBATCH --time=24:00:00

set -euo pipefail

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/scratch/lustre/home/maab9325/miniforge3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/scratch/lustre/home/maab9325/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/scratch/lustre/home/maab9325/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/scratch/lustre/home/maab9325/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
conda activate panaroo_env
cd ~/pangenome_construction/learning/extra_genome/panaroo/new
panaroo -i input/*.gff -o ./results/ --clean-mode strict -a pan --core_threshold 0.98 -t 10

