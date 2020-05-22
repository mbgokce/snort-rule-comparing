#!/bin/bash

if [ $# -ne 3 ]; then
    echo "***************************************************************************************"
    echo "* Rule'lari ve scripti ayni dizine alin. Daha sonra 3 adet arguman girin.             *"
    echo "* Ilki kullanimda olan rule'larin tam yolu, ikincisi yeni rule'larin tam yolu,        *"
    echo "* ucuncusu ise dosyalarin olusturulacagi yol olmali.                                  *"
    echo "*                                                                                     *"
    echo "***************************************************************************************"
else

    cd $2
    for file in *; do mv $file ${file:7}; done                                      #yeni kurallarda kurallarin basinda yazan snort- kismini silmek icin kullanilir (yoksa kullanmayin)
    cd $3                                                                           #butun islemleri yapacagimiz dizine geri donduk

    ls $1/ >> r1names.txt                                                           #rules1 icindeki rule isimlerini bir dosyaya cektik
    ls $2/ >> r2names.txt                                                           #rules2 icindeki rule isimlerini bir dosyaya cektik

    grep -Fxvf r1names.txt r2names.txt > rule2diff1.txt                             #rules2 nin rules1 den farkli olan rule isimlerini cektik
    grep -Fxvf r2names.txt r1names.txt > rule1diff2.txt                             #rules1 in rules2 den farkli olan rule isimlerini cektik

    mkdir newrulediff
    mkdir oldrulediff

    while read e; do
        mv $2/$e $3/newrulediff/                                                    #rules2 de olup rules1 de olmayan rulelari newrulediff directory'sine tasidik
    done <rule2diff1.txt


    while read e; do
        mv $1/$e $3/oldrulediff/                                                    #rules1 de olup rules2 de olmayan rulelari oldrulediff directory'sine tasidik
    done <rule1diff2.txt

    rm r1names.txt                                                                  #farkli olan rulelari tasidigimiz icin rulelarin isimlerini yeniden cekip islem yapacagiz o yuzden eskileri siliyoruz
    rm r2names.txt

    ls $1/ >> r1names.txt

    mkdir newrules                                                                  #rule2 yi rule1 ile ayni siraya getirecegimiz dizin newrules olacak

    while read t; do
        cat $1/$t | grep -o 'sid:[^ ;]\+' > sid.txt                                 #rules1 altindaki butun rulelarin sid'lerini cekip var degiskenine atadim
        touch $3/newrules/$t
        while read x; do
            cat $2/$t | grep $x >> $3/newrules/$t                                   #rules2 deki kurallari rules1 dekilerle ayni siraya getiriyoruz
            sed -i "/$x/d" $2/$t                                                    #rules2 den cekilen satiri siliyoruz boylece eski kurallarda olmayan sid degerine sahip rule orada kalacak
        done <sid.txt
    done <r1names.txt

    while read t; do
        cat $2/$t | grep 'sid:[^ ;]\+' >> $3/newrules/$t                            #rules2 de kalan kurallari newrules altindaki ilgili kuralin sonuna ekliyoruz boylece yeni
    done <r1names.txt                                                               #kurallar eskileri ile ayni sirada ve tam olarak toplanmis olacak

    path=$3"/local.rules"                                                           #yeni eklenen rulelari local.rules un altina ekleyebilmek icin local.rules path ini degiskene atiyoruz

    cp $3/oldrulediff/local.rules $3                                                #eskirulefark altinda bulunan local.rules u scriptin bulundugu dizine kopyaliyoruz

    ls $3/newrulediff/ > newrulenames.txt                                           #yeni eklenen rule larin isimleri bir dosyaya aliniyor

    while read t; do
        echo "include /usr/local/etc/snort/rules/"$t  >> $path                      #eklenecek olan yeni rule'larin isimlerini dosyadan okuyup local.rules un sonuna ekliyoruz
    done <newrulenames.txt

    rm r1names.txt rule2fark1.txt rule1fark2.txt sid.txt
fi
