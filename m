Subject: Results of running lots_of_forks.sh for recent kernels.
From: Steven Cole <elenstev@mesatop.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 13 Aug 2002 09:57:41 -0600
Message-Id: <1029254261.2051.107.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Steven Cole <scole@lanl.gov>
List-ID: <linux-mm.kvack.org>

I ran Daniel's lots_of_forks.sh test for several kernels.

http://people.nl.linux.org/~phillips/patches/lots_of_forks.sh

I realize that this may be like dbench in that it is not 
a realistic real world test, but the numbers may still be
interesting.  Note the much larger variance in the 2.5.x
system times.

19p713b = 2.4.19-pre7-rmap13b
speedup = same as above with speedup patch
-pre2 	= 2.4.20-pre2

Numbers are System time as reported by time -v.
The machine is 2-way p3, SMP kernels, configured
the same, no tweaks to /proc/sys/vm.  The test was
performed 8 times with no delay between runs. 

	19p713b	speedup 2.4.19	-pre2  	2.5.28	2.5.31

1	34.46	31.47	24.71	24.96	39.91	37.04
2	33.93	31.78	24.64	24.92	44.91	45.88
3	33.87	35.76	24.95	24.69	48.63	44.89
4	34.48	31.11	24.97	24.39	58.12	55.8
5	34.46	31.78	24.67	24.72	49.81	43.18
6	34.49	31.1	25.1	24.34	57.62	40.93
7	34.03	31.47	24.43	24.64	50.42	47.27
8	33.84	31.71	25.04	24.53	45	36.49


I have the output of time -v sh lots_of_forks.sh for these 
tests if anyone is interested.

Steven




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
