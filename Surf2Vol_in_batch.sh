subjects="P01 P02 ..."

for sub in $subjects
do
    sh Surf2Vol_Sub.sh SBM $sub
done

for sub in $subjects
do
    sh Surf2Vol_Sub.sh SBM_nMRF $sub
done
