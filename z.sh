#!/bin/bash

user_org1=("Diann" "Silvio" "Keri" "Issiah" "Estell" "Ondrea" "Colleen" "Elena" "Eolanda" "Sonny")
bal_org1=(1227 2120 3863 3063 3343 1964 1873 1103 3880 2170 )
user_org2=("Ilena" "Ly" "Dulsea" "Shepperd" "Caren" "Nikita" "Fannie" "Addison" "Sherlyn" "Ilsa")
bal_org2=(2887 1899 2672 2872 3892 2521 2379 3683 3080 1869)

transactions=300
random(){
  x=$(($1 + RANDOM%(1+$2-$1)))
  echo $x
}

mock_transactions(){

    for ((i = 0; i< transactions; i++))
        do
            amount=$(random 5 10)
            sID=$(random 0 ${#user_org1[@]}-1)
            rID=$(random 0 ${#user_org2[@]}-1)
            #echo "sID = $sID and rID = $rID"
            echo "Performing transaction=$i, moving $amount from ${user_org1[$sID]} to ${user_org2[$rID]}"
        done
}

mock_transactions