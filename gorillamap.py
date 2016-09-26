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

import argparse
import sys
import modules


def main():
    input_file = 'ip.txt'
    output_file = ''
    lines_per_file = 1000
    port = '80'
    verbose = False
    workers = 10

    parser = argparse.ArgumentParser(description='Mass nmap scanner')
    parser.add_argument('-i', '--input',
                        required=True)
    parser.add_argument('-o', '--output',
                        required=False)
    parser.add_argument('-p', '--port',
                        required=False)
    parser.add_argument('-l', '--lines',
                        required=False, type=int)
    parser.add_argument('-w', '--workers',
                        required=False, type=int)
    parser.add_argument("-v", "--verbose",
                        action="store_true")
    try:
        args = vars(parser.parse_args())
    except:
        modules.usage()
        sys.exit(0)
    input_file = args['input']
    output_file = args['output']
    port = args['port']
    verbose = args['verbose']

    # Main program runs below. Above is input handling

    # Clean before running
    if verbose is True:
        print('Ensuring directory is clean')
    modules.clean_up()

    # Build IP List
    if verbose is True:
        print('Building IP address list')
    ip_list = modules.build_list(input_file)

    # Write Files
    if verbose is True:
        print('Writing files for nmap to run')
    workers = modules.write_files(ip_list, output_file, lines_per_file)

    # Start nmap processes
    if verbose is True:
        print('Starting nmap workers')
    modules.nmap_start(workers, port, verbose)

    # Merge output
    if verbose is True:
        print('Formatting Output')
    formatted_output = modules.format_nmap(workers)

    # Output to file or screen
    if output_file != '':
        # Write completed file of alive IP's if specified
        if verbose is True:
            print('Writing list of alive IP\'s')
        modules.write_out_files(formatted_output, output_file)
    else:
        # Output alive IP's to the terminal
        modules.print_output(formatted_output)

    # Clean up
    if verbose is True:
        print('Cleaning up old files')
    modules.clean_up()


if __name__ == "__main__":
    main()
