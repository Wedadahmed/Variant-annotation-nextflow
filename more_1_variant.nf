nextflow.enable.dsl=2

params.indir='/home/AhmedW/snpEff/vcf_input/*.vcf'

params.output='/home/AhmedW/snpEff/nextfolwresult/'
params.snpEff="/home/AhmedW/snpEff"
params.memory="-Xmx8g"
params.clinvar_vcf="/home/AhmedW/ClinVar/clinvar_20230520.vcf"
params.python_script="/home/AhmedW/scripts/variant.py"

vcf_channel=Channel.fromPath("${params.indir}")

process annotat_vcf {

publishDir "${params.output}"

   memory '4 GB'

    input: 
    path vcf

    output:
    path "${vcf.getSimpleName()}*.ann.vcf"

    """
java -Xmx4g -jar ${params.snpEff}/snpEff.jar -c ${params.snpEff}/snpEff.config -v  GRCh37.75  ${vcf} > ${vcf.getSimpleName()}.ann.vcf
    """
}

process clinvar_annotation{
   memory '4 GB'

   publishDir "${params.output}"

   input:
   path vcf

   output:
   path "${vcf.getSimpleName()}.cc.clinvar.vcf"

   """
java -Xmx4g -jar ${params.snpEff}/SnpSift.jar annotate  -v ${params.clinvar_vcf} ${vcf} > ${vcf.getSimpleName()}.cc.clinvar.vcf
   """

}

process py_script{
   memory '1 GB'
publishDir "${params.output}"
   input:
   path vcf

   output:
   path  "*.csv"
   

   """
   python3 ${params.python_script} ${vcf}
   """


}



workflow {
   annotation_ch=annotat_vcf(vcf_channel)
   clinvar_ch=clinvar_annotation(annotation_ch)
   py_script(clinvar_ch)
}
