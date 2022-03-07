#!/bin/bash

# Input the power of two to derive the input.jason file and circom contract
# and build circom file and input.json based on number of leaves

# Parameters:
# 1. Name of circom template, which is used for the root file name
# example "merkle" creates a file named merkle.circom with a template named "merkle"
# 2. Power of two to use to get number of leaves. Example 3, for 8 leaves


# Calculate the number of levels in the merkle tree
nl=$(($2+1))
# Initialize begin and end of input.json file contents
leaves='{"levels": '$nl', "leaves": [1'
end="]}"

# Calculate the number of leaf nodes base on input exponent of 2
ln=$((2**$2))

# Create the circom main conmponent statement to append to the template body
echo "component main{public [levels, leaves]} = $1($2)" > template.end
cat template.body template.end > $1.circom

# Build input.json file
i=2
while [ $i -le $ln ]
do
   leaves=$leaves",${i}"
   i=`expr "$i" + 1`
done

leaves=$leaves$end
echo $leaves > input.json