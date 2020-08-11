task rnaseqc2_aggregate {

    Array[File] tpm_gcts
    Array[File] count_gcts
    Array[File] exon_count_gcts
    Array[File] metrics_tsvs
    Array[File]? insertsize_hists
    String prefix

    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt

    command {
        set -euo pipefail
        echo $(date +"[%b %d %H:%M:%S] Aggregating RNA-SeQC outputs")
        mkdir individual_outputs
        mv ${sep=' ' tpm_gcts} individual_outputs/
        mv ${sep=' ' count_gcts} individual_outputs/
        mv ${sep=' ' exon_count_gcts} individual_outputs/
        mv ${sep=' ' metrics_tsvs} individual_outputs/
        if [ -n '${sep=',' insertsize_hists}' ]; then
            mv ${sep=' ' insertsize_hists} individual_outputs/
        fi
        touch ${prefix}.insert_size_hists.txt.gz
        python3 -m rnaseqc aggregate \
            --parquet \
            -o . \
            individual_outputs \
            ${prefix}
        echo $(date +"[%b %d %H:%M:%S] done")
    }

    output {
        File metrics="${prefix}.metrics.txt.gz"
        File insert_size_hists="${prefix}.insert_size_hists.txt.gz"
        File tpm_gct="${prefix}.gene_tpm.parquet"
        File count_gct="${prefix}.gene_reads.parquet"
        File exon_count_gct="${prefix}.exon_reads.parquet"
    }

    runtime {
        docker: "gcr.io/broad-cga-francois-gtex/gtex_rnaseq:V10"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${num_threads}"
        preemptible: "${num_preempt}"
    }

    meta {
        author: "Francois Aguet"
    }
}


workflow rnaseqc2_aggregate_workflow {
    call rnaseqc2_aggregate
}
