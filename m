Message-ID: <40363778.20900@movaris.com>
Date: Fri, 20 Feb 2004 08:36:08 -0800
From: Kirk True <ktrue@movaris.com>
MIME-Version: 1.0
Subject: LTP VM test slower under 2.6.3 than 2.4.20
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies <kernelnewbies@nl.linux.org>, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

Executing the LTP "mem01" VM test shows a huge time discrepancy between 
2.4.20 and 2.6.3. Under 2.4.20 the total time is around 5 seconds, while 
under 2.6.3 the system seems to hang for nearly a minute.

Where in particular should I start to look to see if it's a 
configuration/environment issue or a real problem? What other 
information would be helpful to know?

Thanks greatly!!!
Kirk

--------------

2.6.3:

# time /tmp/ltp-full-20040206/testcases/kernel/mem/mem/mem01
Free Mem:       749 Mb
Free Swap:      1992 Mb
Total Free:     2741 Mb
Total Tested:   1024 Mb
mem01       0  INFO  :  touching 1024MB of malloc'ed memory (linear)
mem01       1  PASS  :  malloc - alloc of 1024MB succeeded

real    0m53.134s
user    0m0.066s
sys     0m3.292s



2.4.20:

# time /tmp/ltp-full-20040206/testcases/kernel/mem/mem/mem01
Free Mem:       859 Mb
Free Swap:      1992 Mb
Total Free:     2852 Mb
Total Tested:   1024 Mb
mem01       0  INFO  :  touching 1024MB of malloc'ed memory (linear)
mem01       1  PASS  :  malloc - alloc of 1024MB succeeded

real    0m5.493s
user    0m0.090s
sys     0m1.260s


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
