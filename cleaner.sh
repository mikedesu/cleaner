#!/usr/bin/zsh

if [[ ! -e $1 ]]; then 
    echo "Usage: ./cleaner.sh <proxies.txt> <port_count> <loop_count>";
    exit 1;
fi

if [[ $2 -le 0 ]]; then 
    echo "Usage: ./cleaner.sh <proxies.txt> <port_count> <loop_count>";
    exit 1;
fi    

if [[ $3 -le 0 ]]; then 
    echo "Usage: ./cleaner.sh <proxies.txt> <port_count> <loop_count>";
    exit 1;
fi    



figlet -f slant cleaner.sh;
echo "- by darkmage";
echo "- https://www.evildojo.com";
echo "- @evildojo666";
echo "- https://www.github.com/mikedesu/cleaner";
echo "";



echo "$(date) Grabbing ports...";
sed 's|.*:||' $1 | sort > tmp/ports.txt;
uniq -c tmp/ports.txt | sort -nr | awk '{print $2}' > tmp/just-ports.txt;
for port in $(head -n $2 tmp/just-ports.txt); do
    echo "$(date) \033[33mScanning\033[0m port $port";
    ip_list="tmp/ip-list-$port.txt"; 
    grep ":$port$" proxies.txt | sed "s/:$port//g" > $ip_list;
    nmap -vv -iL $ip_list --script socks-open-proxy -p$port -Pn -oG tmp/nmap-$port.gnmap;
    grep open tmp/nmap-$port.gnmap | awk '{print $2}' | sed "s/$/:$port/g" > tmp/socks-$port.txt;
    echo "Completed NMAP of port $port" | notify -silent;
done
cat tmp/socks-*.txt > tmp/socks.txt;

# for better results, run this command multiple times
for i in $(seq 1 $3); do
    parallel --bar -j16 -a tmp/socks.txt --round-robin --shuf 'curl -s -x socks4://{} http://www.google.com -o /dev/null -m 10; [[ $? -eq 0 ]] && (echo socks4://{} >> success.txt)';
    parallel --bar -j16 -a tmp/socks.txt --round-robin --shuf 'curl -s -x socks5://{} http://www.google.com -o /dev/null -m 10; [[ $? -eq 0 ]] && (echo socks5://{} >> success.txt)';
    sort -u success.txt -o success.txt;
    echo "Total SOCKS proxies found: $(wc -l success.txt | awk '{print $1}')" | notify -silent;
done

