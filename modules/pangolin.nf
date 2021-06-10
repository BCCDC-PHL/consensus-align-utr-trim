process updatePangolin {
  executor 'local'

  input:
  val(should_update)

  output:
  val(did_update)

  script:
  did_update = should_update
  should_update_string = should_update ? "true" : "false"
  """
  should_update=${should_update_string}
  if [ "\$should_update" = true ]; then
    pangolin --update
  fi
  """
}

process pangolin {

  tag { sampleName }

  publishDir "${params.run_dir}/${sampleName}", pattern: "${sampleName}_lineage_report.csv", mode: 'copy'

  input:
  tuple val(sampleName), path(consensus_fasta), val(pangolin_updated)

  output:
  tuple val(sampleName), path("${sampleName}_lineage_report.csv")

  script:
  """
  pangolin ${consensus_fasta} 
  mv lineage_report.csv ${sampleName}_lineage_report.csv
  """
}
