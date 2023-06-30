nextflow.enable.dsl=2

params.indir='/home/AhmedW/snpEff/3030243_twistwes2/nextfolwresult.vcf'
params.output='/home/AhmedW/snpEff/nextfolwresult'
params.snpEff="/home/AhmedW/snpEff"
params.memory="-Xmx8g"
params.clinvar_vcf="/home/AhmedW/ClinVar/clinvar_20230520/name.vcf"
params.python_script="/home/AhmedW/scripts/variant.py"


process annotat_vcf{

publishDir "${params.output}" , mode: "copy", overwrite: true

    input: 
    path vcf

    output:
    path  "${vcf.getSimpleName()}.ann.vcf"

    """
java -Xmx8g -jar ${params.snpEff}/snpEff.jar -c ${params.snpEff}/snpEff.config -v  GRCh37.75  ${vcf} > ${vcf.getSimpleName()}.ann.vcf
    """
}

process clinvar_annotation{
   publishDir "${params.output}" , mode: "copy", overwrite: true

   input:
   path vcf

   output:
   path "${vcf.getSimpleName()}.cc.clinvar.vcf"

   """
java -Xmx8g -jar ${params.snpEff}/SnpSift.jar annotate  -v ${params.clinvar_vcf} ${vcf} > ${vcf.getSimpleName()}.cc.clinvar.vcf
   """

}

process py_script{
publishDir "${params.output}", mode: "copy", overwrite: true
   input:
   path vcf

   output:
   path  "diseases.csv"
   

   """
   python3 ${params.python_script} ${vcf.getSimpleName()}.cc.clinvar.vcf 
   """


}



workflow{
   annotation_ch=annotat_vcf(params.indir)
   clinvar_ch=clinvar_annotation(annotation_ch)
   py_script(clinvar_ch)
}
