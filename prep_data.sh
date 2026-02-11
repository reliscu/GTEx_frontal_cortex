# Subsetting SJ data using bash (didn't end up using this)

HEADER_LINE=3

awk -F'\t' -v OFS='\t' -v HL="$HEADER_LINE" '
  NR==FNR { keep[$0]=1; next }

  # pass through pre-header lines unchanged
  FNR < HL { print $0; next }

  # header line (row HL)
  FNR==HL {
    for (i=1; i<=NF; i++) if ($i in keep) idx[++k]=i
    for (j=1; j<=k; j++) printf "%s%s", $(idx[j]), (j<k?OFS:ORS)
    next
  }

  # data lines
  {
    for (j=1; j<=k; j++) printf "%s%s", $(idx[j]), (j<k?OFS:ORS)
  }
' <(python3 - <<'PY'
import csv
with open("GTEx_frontal_cortex_sampleinfo.csv", newline="") as f:
    r = csv.reader(f)
    # If keep.csv has a header row you want to skip, uncomment:
    next(r, None)
    for row in r:
        if row and row[0].strip():
            print(row[0].strip().rstrip("\r"))
PY
) ../GTEx_Analysis_v10_STARv2.7.10a_junctions.gct > subset.tsv
