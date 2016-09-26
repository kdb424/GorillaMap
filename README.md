#GorillaMap

Mass nmap scanning utility. Scanning in mass has never been this easy.

Requirements:
~~~~~~~~~~~~~
        Python 2.7
        Optional:
            Cython

Usage:
~~~~~
    python gorillamap.py -i <input_file> -p <port> -v
    
Arguments:
~~~~~~~~~~
	-h or --help                    Outputs help
	-v or --verbose                 Increases verbosity
	-e or --input <input_file>      File containing ranges of IP addresses
	-o or --output <output_file>    File to output IP adresses that are up
	-p or --port <80>               Port to scan
	-l or --lines <10000>           Limit on lines per output file
	-w or --workers <10>            Limit of nmap processes launched concurrently
	

Example:
~~~~~~~~
     python gorillamap.py -i ip_list.txt -p 80 -v
     python gorillamap.py -i ip_list.txt -p 22 -o scanned_up.txt -w 2