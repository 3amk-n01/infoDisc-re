#!/bin/bash

#	Disclaimer: This script is provided for informational purposes only and without warranty. The author is not liable for any  damages #or losses resulting from its use. The user assumes all responsibility for the script's use and its impact on the system. This #script is not intended for malicious purposes.
#
# infoDisc - Simple Tool for discover sensitive data in js files and other leaked sensitive files.
#
# based on SecretFinder.py / Dora.py
#
## If you find any sensitive token or key then you can use this below repository to take your exploitation part further.
## https://github.com/streaak/keyhacks


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color


logo(){

  echo -e "${GREEN}
  
  

	 _)        _|       __ \ _)           
	 | __ \  |    _ \  |   | |  __|  __| 
	 | |   | __| (   | |   | |\__ \ (    
	_|_|  _|_|  \___/ ____/ _|____/\___|  


  
 This Tool Depend on [ katana / httpx ] and [ SecretFinder.py / Dora.py ] make sure you insall them befor use this script.
 	
 	[+]	https://github.com/projectdiscovery/katana
 	[+]	https://github.com/projectdiscovery/httpx
 	[+]	https://github.com/m4ll0k/SecretFinder.git
	[+]	https://github.com/sdushantha/dora.git
                                           
 ${NC}"
}



katana(){
	
	echo -e "${YELLOW}\n\n ===========================================================\n\n${NC}"
	echo -e "${GREEN}\n [i] ..... < * Start collect URLs * > ..... [i] \n\n${NC}"
	
	/root/go/bin/katana -u "$1" -jsl -jc -rl 5 -p 1 -rd 1 -c 2 -d 3 -ps -pss waybackarchive,commoncrawl,alienvault -kf  -fx -ef woff,css,png,svg,jpeg,gif,jpg,woff2 -silent -o  k-allurls.txt

	echo -e "${RED}\n [+] ..... < Done collect URLs > ..... [+] \n${NC}"
}


hostalive(){
  	  echo -e "${YELLOW}\n\n ===========================================================\n\n${NC}"
  	 echo -e "${GREEN}\n [i] ..... < * Find Valid URLs * > ..... [i] \n\n${NC}"
 	 cat k-allurls.txt | sort -u | /root/go/bin/httpx  -mc 200 | tee valid-Urls.txt
	
	echo -e "${RED}\n [+] ..... < Done Find Valid URLs > ..... [+] \n${NC}"
}


# Information Disclose
infodisc(){
	echo -e "${YELLOW}\n\n ===========================================================\n\n${NC}"
	echo -e "${GREEN}\n [i] ..... < * Find If leaked Sensitive Files * > ..... [i] \n\n${NC}"
	cat valid-Urls.txt | grep -E "\.txt|\.log|\.cache|\.secret|\.db|\.backup|\.yml|\.json|\.gz|\.rar|\.zip|\.config|\.conf"
	echo -e "${RED}\n [+] ..... < Done Find If leaked Sensitive Files > ..... [+] \n${NC}"
}


# JS Secrets
jsDisc(){
	echo -e "${YELLOW}\n\n ===========================================================\n\n${NC}"

	echo -e "${GREEN}\n [+] ..... < * Find If leaked Sensitive Secrets IN JS Files * > ..... [+] \n\n${NC}"
	cat valid-Urls.txt | grep -iE '\.js$' | grep -ivE '\.json$' | sort -u  >> validjsurls.txt
	
	echo -e "${YELLOW}\n\n  >>>> secretfinder ========== \n\n${NC}"
	for url in $(cat validjsurls.txt ) ;
	do python3 SecretFinder.py  -i $url  -o cli >> secret.txt;
	done
	
	echo -e "${YELLOW}\n\n  >>>> dora ==========  \n\n${NC}"
	
	if [ -d "./js" ]
  	then
    	echo " js directory exist "
   	 echo "remove old directory"
    		rm -r js
    	fi
    	mkdir js	
	cd js
	for f in $(cat ../validjsurls.txt);
	do wget  $f ;
	done
	cd ../
	python3  /dora/__main__.py  js/
	
	echo -e "${RED}\n [+] ..... < Done Find If leaked Sensitive Secrets IN JS  Files > ..... [+] \n${NC}"
}

main(){
  clear
  logo
  domain=$1

  dir_name=$(echo $domain | cut -d "/" -f 3)
  recon=$dir_name-$(date +"%Y-%m-%d")

  if [ -d "./$recon" ]
  then

    echo " directory exist "
    echo "remove old directory"
    rm -r "$recon"
    mkdir "$recon" && cd "$recon"
  else
    mkdir "$recon" && cd "$recon"
  fi
  
  katana $1
  hostalive
  infodisc
  jsDisc
}

 logo
if [[ -z $@ ]]; then
  echo -e  "\n ====================================\n"
  echo -e "${RED} [ + ] Error: no Site .\n${NC}"
  echo -e "${RED} [ i ] Usage: ./infoDisc.sh <site>\n${NC}"
  echo -e  "\n ====================================\n"
  exit 1
fi


main $1
