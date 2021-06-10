process getSampleDirs {

  tag { runId }

  executor 'local'

  input:
      path(input_dir)

  output:
      tuple val(runId), path("${runId}/*")

  script:
      runId = input_dir.baseName
      """
      """  
}

process getConsensusFile {

  tag { sampleName }

  executor 'local'

  input:
      path(sampleDir)

  output:
      tuple val(sampleName), path("${sampleName}.consensus.fasta"), optional: true

  script:
      sampleName = sampleDir.baseName
      """
      if [[ -f ${sampleDir}/${sampleName}.consensus.fasta ]]; then
        sed -E 's/^>([[:alnum:]]+).*/>\\1/' ${sampleDir}/${sampleName}.consensus.fasta > ${sampleName}.consensus.fasta
      fi
      """  
}

process alignConsensusToReference {
    /**
    * Aligns consensus sequence against reference using mafft. Uses the --keeplength
    * flag to guarantee that all alignments remain the same length as the reference.
    */

    tag { sampleName }

    publishDir "${params.run_dir}/${sampleName}", pattern: "${sampleName}.consensus.aln.fa", mode: 'copy'

    input:
        tuple val(sampleName), path(consensus)

    output:
        tuple val(sampleName), path("${sampleName}.consensus.aln.fa")

    script:
        // Convert multi-line fasta to single line
        awk_string = '/^>/ {printf("\\n%s\\n", $0); next; } { printf("%s", $0); }  END { printf("\\n"); }'
        """
        mafft \
          --preservecase \
          --keeplength \
          --add \
          ${consensus} \
          ${params.ref} \
          > ${sampleName}.with_ref.multi_line.alignment.fa
        awk '${awk_string}' ${sampleName}.with_ref.multi_line.alignment.fa > ${sampleName}.with_ref.single_line.alignment.fa
        tail -n 2 ${sampleName}.with_ref.single_line.alignment.fa > ${sampleName}.consensus.aln.fa
        """
}

process trimUTRFromAlignment {
    /**
    * Trim the aligned consensus to remove 3' and 5' UTR sequences.
    */

    tag { sampleName }

    publishDir "${params.run_dir}/${sampleName}", pattern: "${sampleName}.consensus.aln.utr_trimmed.fa", mode: 'copy'

    input:
        tuple val(sampleName), path(alignment)

    output:
        tuple val(sampleName), path("${sampleName}.consensus.aln.utr_trimmed.fa")

    script:
    awk_string = '/^>/ { printf("%s\\n", $0); next; } { printf("%s", $0); } END { printf("\\n"); }'
        """
        echo -e "\$(head -n 1 ${alignment} | cut -c 2-):266-29674" > non_utr.txt
        samtools faidx ${alignment}
        samtools faidx -r non_utr.txt ${alignment} > ${sampleName}.consensus.aln.utr_trimmed.multi_line.fa
        awk '${awk_string}' ${sampleName}.consensus.aln.utr_trimmed.multi_line.fa > ${sampleName}.consensus.aln.utr_trimmed.fa
        """
}