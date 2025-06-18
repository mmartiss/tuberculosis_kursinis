#!/bin/bash
#SBATCH --job-name=prokka_batch
#SBATCH --output=prokka_batch_%j.log
#SBATCH -p main
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=72:00:00

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

for genome in ~/pangenome_construction/learning/data/not_clean/*.fna; do
  # Extract just the filename without path
  filename=$(basename "$genome")
  # Remove the .fna extension to use as prefix
  prefix="${filename%.fna}"
  
  prokka --outdir "results_${prefix}" --prefix "${prefix}" --genus Mycobacterium --species tuberculosis --compliant --usegenus --rfam --kingdom Bacteria --gcode 11 --cpus 8 "$genome"
done
