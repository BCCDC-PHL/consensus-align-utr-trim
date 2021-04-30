#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { getSampleDirs } from './modules/align-trim.nf'
include { getConsensusFile } from './modules/align-trim.nf'
include { alignConsensusToReference } from './modules/align-trim.nf'
include { trimUTRFromAlignment } from './modules/align-trim.nf'


workflow {

  ch_sample_dirs = Channel.fromPath("${params.run_dir}/*", type: 'dir')

  main:
    getConsensusFile(ch_sample_dirs.flatMap{ it -> it })
    alignConsensusToReference(getConsensusFile.out)
    trimUTRFromAlignment(alignConsensusToReference.out)
}
