#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { getSampleDirs } from './modules/align-trim.nf'
include { getConsensusFile } from './modules/align-trim.nf'
include { alignConsensusToReference } from './modules/align-trim.nf'
include { trimUTRFromAlignment } from './modules/align-trim.nf'
include { updatePangolin } from './modules/pangolin.nf'
include { pangolin } from './modules/pangolin.nf'


workflow {

  ch_sample_dirs = Channel.fromPath("${params.run_dir}/*", type: 'dir')

  main:
    updatePangolin(Channel.of(params.update_pangolin))
    getConsensusFile(ch_sample_dirs.flatMap{ it -> it })
    pangolin(getConsensusFile.out.combine(updatePangolin.out))
    alignConsensusToReference(getConsensusFile.out)
    trimUTRFromAlignment(alignConsensusToReference.out)
}
