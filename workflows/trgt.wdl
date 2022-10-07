version 1.0

workflow trgt {
	input {
		File ref 
		File repeats 
		File aligned_bam
		String repeat_id
	}

	String aligned_bam_basename = basename(aligned_bam) 

	call genotype_repeats {
		input:
			ref = ref,
			repeats = repeats,
			aligned_bam = aligned_bam,
			aligned_bam_basename = aligned_bam_basename
	}

	call sort_index_vcf {
		input:
			trgt_vcf = genotype_repeats.trgt_vcf,
			aligned_bam_basename = aligned_bam_basename
	}

	call sort_index_spanning_bam {
		input:
			trgt_bam = genotype_repeats.trgt_bam,
			aligned_bam_basename = aligned_bam_basename
	}

	call visualize_repeats {
		input:
			ref = ref,
			repeats = repeats,
			sorted_trgt_vcf = sort_index_vcf.sorted_trgt_vcf,
			sorted_trgt_bam = sort_index_spanning_bam.sorted_trgt_bam,
			repeat_id = repeat_id
	}

	output {
		File sorted_trgt_vcf = sort_index_vcf.sorted_trgt_vcf
		File sorted_trgt_vcf_index = sort_index_vcf.sorted_trgt_vcf_index

		File sorted_trgt_bam = sort_index_spanning_bam.sorted_trgt_bam
		File sorted_trgt_bam_index = sort_index_spanning_bam.sorted_trgt_bam_index

		File pileup_image = visualize_repeats.pileup_image
	}

	meta {
		author: "Karen Fang"
		email: "karen@dnastack.com"
	}
}

task genotype_repeats {
	input {
		File ref
		File repeats 
		File aligned_bam

		String aligned_bam_basename
	}

	Int disk_size = ceil((size(ref, "GB") + size(repeats, "GB") + size(aligned_bam, "GB")) * 2 + 20)

	command <<<
		trgt --genome ~{ref} \
			--repeats ~{repeats} \
			--reads ~{aligned_bam} \
			--output-prefix ~{aligned_bam_basename}
	>>>

	output {
		File trgt_vcf = "~{aligned_bam_basename}.vcf.gz"
		File trgt_bam = "~{aligned_bam_basename}.spanning.bam"
	}

	runtime {
		docker: "us-central1-docker.pkg.dev/cool-benefit-817/workflow-images/pacbio_trgt_tools:0.0.1"
		cpu: 1
		memory: "7.5 GB"
		disks: "local-disk " + disk_size + " HDD"
		preemptible: 2
	}
}

task sort_index_vcf {
	input {
		File trgt_vcf 

		String aligned_bam_basename
	}

	Int disk_size = ceil(size(trgt_vcf, "GB") * 2 + 20)


	command <<<
		bcftools sort \
			-Ob -o "~{aligned_bam_basename}.sorted.vcf.gz" \
			~{trgt_vcf} 

		bcftools index \
			"~{aligned_bam_basename}.sorted.vcf.gz"
	>>>

	output {
		File sorted_trgt_vcf = "~{aligned_bam_basename}.sorted.vcf.gz"
		File sorted_trgt_vcf_index = "~{aligned_bam_basename}.sorted.vcf.gz.tbi"
	}

	runtime {
		docker: "us-central1-docker.pkg.dev/cool-benefit-817/workflow-images/pacbio_trgt_tools:0.0.1"
		cpu: 1
		memory: "7.5 GB"
		disks: "local-disk " + disk_size + " HDD"
		preemptible: 2
	}
}


task sort_index_spanning_bam {
	input {
		File trgt_bam

		String aligned_bam_basename
	}

	Int disk_size = ceil(size(trgt_bam, "GB") * 2 + 20)

	command <<<
		samtools sort \
			-o "~{aligned_bam_basename}.spanning.sorted.bam" \
			~{trgt_bam} 

		samtools index \
			"~{aligned_bam_basename}.spanning.sorted.bam"
	>>>

	output {
		File sorted_trgt_bam = "~{aligned_bam_basename}.spanning.sorted.bam"
		File sorted_trgt_bam_index = "~{aligned_bam_basename}.spanning.sorted.bam.bai"
	}

	runtime {
		docker: "us-central1-docker.pkg.dev/cool-benefit-817/workflow-images/pacbio_trgt_tools:0.0.1"
		cpu: 1
		memory: "7.5 GB"
		disks: "local-disk " + disk_size + " HDD"
		preemptible: 2
	}
}

task visualize_repeats {
	input {
		File ref
		File repeats 
		File sorted_trgt_vcf
		File sorted_trgt_bam

		String repeat_id
	}

	Int disk_size = ceil((size(ref, "GB") + size(repeats, "GB") + size(sorted_trgt_vcf, "GB") + size(sorted_trgt_bam, "GB")) * 2 + 20)

	command <<<
		trvz --genome ~{ref} \
			--repeats ~{repeats} \
			--vcf ~{sorted_trgt_vcf}
			--spanning-reads ~{sorted_trgt_bam} \
			--repeat-id ~{repeat_id} \
			--image "~{repeat_id}.svg"
	>>>

	output {
		File pileup_image = "~{repeat_id}.svg"
	}

	runtime {
		docker: "us-central1-docker.pkg.dev/cool-benefit-817/workflow-images/pacbio_trgt_tools:0.0.1"
		cpu: 1
		memory: "7.5 GB"
		disks: "local-disk " + disk_size + " HDD"
		preemptible: 2
	}
}