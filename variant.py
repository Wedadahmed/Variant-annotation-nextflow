import cyvcf2
import pandas as pd

from cyvcf2 import VCF
import sys


#print(sys.argv[1])
# to add it as argument and input and able to change it later on 

new_var2= sys.argv[1]

out_file = new_var2.replace(".cc.clinvar.vcf", "") + ".csv"

#filteration specific parts of the annotaed file 
def get_disease():
     clinvar_list=[]  
     for variant in VCF(new_var2, strict_gt=True):
            g = variant.INFO.get('CLNSIG')
            ANN=variant.INFO.get('ANN')
            variant_type = ANN.split('|')[1]
            effect=ANN.split('|')[2]
            
            info=variant.CHROM,variant.POS,variant.FILTER,variant_type,effect,g,variant.INFO.get('CLNDN','CLNDISDB'),variant.INFO.get('GENEINFO'), ANN
            if g!=None :
               if  "Pathogenic"  in g :
                  clinvar_list.append(info)
           
     return clinvar_list


diseases= get_disease()

# improving the shape of the table produced

df = pd.DataFrame(diseases,columns=['Chrom', 'position','filter','variant-type','Effect','Clin.sig','diseases','genename-Id','ANN'])
df["genename-Id"] = df["genename-Id"].str.split("|")
df_exploded = df.explode("genename-Id")
df_exploded[['genename','gene_id']]=df_exploded["genename-Id"].str.split(':',expand = True)

df_exploded["c_codes"] = ""
df_exploded["p_codes"] = ""

df_exploded['c_codes'] = df_exploded['c_codes'].astype('object')
df_exploded['p_codes'] = df_exploded['p_codes'].astype('object')

for idx, row in df_exploded.iterrows():
    li_c_codes = []
    li_p_codes = []
    li_transcripts = row["ANN"].split(",")
    
    for item in li_transcripts:
        items = item.split("|")
        li_c_codes.append(items[9])
        li_p_codes.append(items[10])
    
    df_exploded.at[idx, "c_codes"] = "; ".join(li_c_codes)
    df_exploded.at[idx, "p_codes"] = "; ".join(li_p_codes)


#df_exploded


df_exploded.to_csv(out_file,sep=';',header=True, index=False)


