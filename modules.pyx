# Copyright (c) 2013, Kyle Brown
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

import os
import re
import socket
import struct


# Usage Information Stored Here
def usage():
    print('Usage: mass_scan.py [OPTION]... [DIRECTORY]...')
    print('Scans mass IP addresses and outputs them to a file.')
    print('')
    print('  -h, --help        Displays the help page')
    print('  -i, --input       Input file name')
    print('  -l, --lines       Lines per file limit')
    print('  -o, --output      Output file name')
    print('  -p, --port        Port to be scanned')
    print('  -v, --verbose     Increases verbosity. ' +
          'Will break piping, but not the --output option')
    print('  -w, --workers     limit amount of nmap processes')


def build_list(input_file):
    # Reads in the input file
    ip_ranges = ''
    with open(input_file, 'r') as f:
        ip_ranges = f.read()

    # Splits file into readable IP addresses
    ip_split = re.split('-|\n', ip_ranges)
    list_length = int(len(ip_split) / 2)
    ip_list = []

    # Loop through each list
    for i in range(0, (list_length)):
        start = ip_split[(i * 2)].strip()
        end = ip_split[(((i + 1) * 2) - 1)].strip()

        # Simple IP address incrementing tool
        ip2int = lambda ipstr: struct.unpack('!I', socket.inet_aton(ipstr))[0]
        int2ip = lambda n: socket.inet_ntoa(struct.pack('!I', n))

        tmp_ip = ip2int(start)
        # Increment IP address and add to list
        while end != int2ip(tmp_ip):
            ip_list.append(int2ip(tmp_ip))
            tmp_ip += 1
        ip_list.append(int2ip(tmp_ip))  # Finalize loop

    return ip_list


def write_files(ip_list, output_file, lines_per_file):
    workers = 0
    for file_count in range(0, (int(lines_per_file / lines_per_file))):
        #  Set path name for output file used by write
        path = 'nmap_feeder' + str(file_count) + '.txt'
        if os.path.exists(path):
            os.remove(path)
        f = open(path, 'w')
        counter = 0
        for item in ip_list:
            counter += 1
            if counter >= lines_per_file:
                f.close()
                path = 'nmap_feeder' + str(file_count) + '.txt'
                f = open(path, 'w')
            else:
                f.write("%s\n" % item)

        f.close()
        workers += 1
        del ip_list[:(lines_per_file - 2)]

    return workers


def nmap_start(workers, port, verbose):
    for i in range(0, (workers)):
        path = 'nmap_feeder' + str(i) + '.txt'
        # Run nmap with specified parameters for the set of IP's on one line
        command = 'nmap -p ' + port + ' -iL ./'
        command += path + ' -oG - | grep ' + port + '/open' + ' >> out'
        command += str(i) + '.txt '
        if i != ((workers - 1)) and i <= workers:
            command += "&"
        else:
            workers += workers

        if verbose:
            print(command)
        os.system(command)


def format_nmap(workers):
    output = []
    ip = re.compile('(([2][5][0-5]\.)|([2][0-4][0-9]\.)|([0-1]?[0-9]' +
                    '?[0-9]\.)){3}(([2][5][0-5])|([2][0-4][0-9])|([0' +
                    '-1]?[0-9]?[0-9]))')
    for i in range(workers):
        f = open('out' + str(i) + '.txt', 'r')
        for line in f:
            match = ip.search(line)
            output.append(match.group())
    return output


def write_out_files(formatted_output, output_file):
    # Writes completed file
    f = open(output_file, 'w')
    for ip in formatted_output:
        f.write("%s\n" % ip)
    f.close()


def print_output(formatted_output):
    # Print completed output
    for ip in formatted_output:
        print("%s\n" % ip)


def clean_up():
    #  Clean up files left behind
    if os.path.exists('nmap_feeder0.txt'):
        os.system('rm nmap_feeder*')
    if os.path.exists('out0.txt'):
        os.system('rm out*')
