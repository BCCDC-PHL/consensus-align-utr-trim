process updatePangolin {
  executor 'local'

  input:
  val(should_update)

  output:
  val(true)

  script:
  """
  pangolin --update
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