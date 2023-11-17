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
echo "- www.evildojo.com";
echo "- @evildojo666";
echo "- https://www.github.com/mikedesu/cleaner";

echo "$(date) Grabbing ports...";
sed 's|.*:||' $1 | sort > ports.txt;
uniq -c ports.txt | sort -nr | awk '{print $2}' > just-ports.txt;
for port in $(head -n $2 just-ports.txt); do
    echo "$(date) \033[33mScanning\033[0m port $port";
    ip_list="ip-list-$port.txt"; 
    grep $port proxies.txt | sed "s/:$port//g" > $ip_list;
    nmap -vv -iL $ip_list --script socks-open-proxy -p$port -Pn -oG nmap-$port.gnmap;
    grep open nmap-$port.gnmap | awk '{print $2}' | sed "s/$/:$port/g" > socks-$port.txt;
done
cat socks-*.txt > socks.txt;

# for better results, run this command multiple times
for i in $(seq 1 $3); do
    parallel --bar -j8 -a socks.txt --round-robin --shuf 'curl -s -x socks5://{} http://www.google.com -o /dev/null -m 10; [[ $? -eq 0 ]] && (echo socks5://{} >> socks-success.txt)';
    sort -u socks-success.txt -o socks-success.txt;
done

