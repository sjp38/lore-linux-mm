Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l7J9olKe056428
	for <linux-mm@kvack.org>; Sun, 19 Aug 2007 19:50:47 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7J9oe9B041414
	for <linux-mm@kvack.org>; Sun, 19 Aug 2007 19:50:40 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7J9l6BC011219
	for <linux-mm@kvack.org>; Sun, 19 Aug 2007 19:47:06 +1000
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Sun, 19 Aug 2007 15:16:58 +0530
Message-Id: <20070819094658.654.84837.sendpatchset@balbir-laptop>
Subject: Memory controller test results (v6)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>, Linux MM Mailing List <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Eric W Biederman <ebiederm@xmission.com>
List-ID: <linux-mm.kvack.org>

Hi, Andrew,

Here are more test results for v6 of the memory controller posted at
	http://lkml.org/lkml/2007/8/17/69

The tests were run under three different configurations

1. disabled - the memory controller was not compiled in
2. notmnted - the memory controller was compiled in, but the container
   filesystem was not mounted (one could view this configuration as
   a memory controller with no limits enforced)
3. limit400 - the memory controller was compiled in and the container
   running the tests was limited to 400 MB of memory usage.

Tests run
----------
1. lmbench
2. ltp
3. vmmstress
4. aim9
5. memtest (succeeded)

Results posted
--------------
1. lmbench
2. ltp
3. vmmstress
4. aim9


Lmbench
-------


                 L M B E N C H  2 . 0   S U M M A R Y
                 ------------------------------------


Basic system parameters
----------------------------------------------------
Host                 OS Description              Mhz
                                                    
--------- ------------- ----------------------- ----
disabled  Linux 2.6.23-        x86_64-linux-gnu 1993
limit400  Linux 2.6.23-        x86_64-linux-gnu 1993
notmnted  Linux 2.6.23-        x86_64-linux-gnu 1993

Processor, Processes - times in microseconds - smaller is better
----------------------------------------------------------------
Host                 OS  Mhz null null      open selct sig  sig  fork exec sh  
                             call  I/O stat clos TCP   inst hndl proc proc proc
--------- ------------- ---- ---- ---- ---- ---- ----- ---- ---- ---- ---- ----
disabled  Linux 2.6.23- 1993 0.08 0.27 2.74 3.96  16.0 0.23 1.55 128. 479. 5572
limit400  Linux 2.6.23- 1993 0.08 0.30 3.00 4.54  17.7 0.23 1.74 139. 537. 5825
notmnted  Linux 2.6.23- 1993 0.08 0.27 2.78 4.23  16.0 0.23 1.57 129. 527. 5809

Context switching - times in microseconds - smaller is better
-------------------------------------------------------------
Host                 OS 2p/0K 2p/16K 2p/64K 8p/16K 8p/64K 16p/16K 16p/64K
                        ctxsw  ctxsw  ctxsw ctxsw  ctxsw   ctxsw   ctxsw
--------- ------------- ----- ------ ------ ------ ------ ------- -------
disabled  Linux 2.6.23- 3.380 4.5900 5.5200 5.4100 8.7800 5.68000 8.89000
limit400  Linux 2.6.23- 4.180 4.3400 5.1100 4.7900 7.7200 5.36000 8.18000
notmnted  Linux 2.6.23- 4.100 3.3600 5.1100 5.0200 8.9200 5.08000 9.02000

*Local* Communication latencies in microseconds - smaller is better
-------------------------------------------------------------------
Host                 OS 2p/0K  Pipe AF     UDP  RPC/   TCP  RPC/ TCP
                        ctxsw       UNIX         UDP         TCP conn
--------- ------------- ----- ----- ---- ----- ----- ----- ----- ----
disabled  Linux 2.6.23- 3.380  11.8 18.6  20.0  23.2  23.3  26.8 34.5
limit400  Linux 2.6.23- 4.180  11.0 21.0  22.3  23.7  23.1  24.7 37.9
notmnted  Linux 2.6.23- 4.100  11.1 18.7  18.4  22.7  22.8  26.4 41.0

File & VM system latencies in microseconds - smaller is better
--------------------------------------------------------------
Host                 OS   0K File      10K File      Mmap    Prot    Page	
                        Create Delete Create Delete  Latency Fault   Fault 
--------- ------------- ------ ------ ------ ------  ------- -----   ----- 
disabled  Linux 2.6.23-   18.4   14.9  228.2   73.2   2998.0 0.375 1.00000
limit400  Linux 2.6.23-   17.9   17.6  240.0   77.6   1874.0 0.496 2.00000
notmnted  Linux 2.6.23-   18.9   18.0  188.6   74.9   3044.0 0.467 2.00000

*Local* Communication bandwidths in MB/s - bigger is better
-----------------------------------------------------------
Host                OS  Pipe AF    TCP  File   Mmap  Bcopy  Bcopy  Mem   Mem
                             UNIX      reread reread (libc) (hand) read write
--------- ------------- ---- ---- ---- ------ ------ ------ ------ ---- -----
disabled  Linux 2.6.23- 740. 1210 816. 1276.0 2534.0  907.8  877.4 2152 1247.
limit400  Linux 2.6.23- 591. 1186 826. 1280.4 2457.4 1117.8  861.7 2634 1536.
notmnted  Linux 2.6.23- 691. 1196 800. 1434.1 1761.6  854.2  827.9 1876 1258.

Memory latencies in nanoseconds - smaller is better
    (WARNING - may not be correct, check graphs)
---------------------------------------------------
Host                 OS   Mhz  L1 $   L2 $    Main mem    Guesses
--------- -------------  ---- ----- ------    --------    -------
disabled  Linux 2.6.23-  1993 1.506 6.0270   97.5
limit400  Linux 2.6.23-  1993 1.506 6.0280   97.5
notmnted  Linux 2.6.23-  1993 1.507 6.0280   97.5

LTP
---

Note, only ltp failures are posted (no new failures were seen due
to the memory controller)

disabled
--------


clone06     0  WARN  :  sprintf() failed
clone06     1  BROK  :  Unexpected signal 11 received.
fcntl27     1  BROK  :  Unexpected signal 11 received.
fcntl28     1  BROK  :  Unexpected signal 11 received.
kill05      0  INFO  :  WARNING: shared memory deletion failed.
mincore01    4  FAIL  :  call succeeded unexpectedly
setrlimit03    1  FAIL  :  call succeeded unexpectedly
swapon02    0  WARN  :  Failed swapon for file swapfile31 returned -96
swapon02    0  WARN  :  Failed to turn off swap files. system reboot after execution of LTP test suite is recommended
swapon02    0  WARN  :  Failed to turn off swap files. system reboot after execution of LTP test suite is recommended
swapon02    3  BROK  :  Cleanup failed, quitting the test
swapon02    4  BROK  :  Remaining cases broken
INFO: pan reported some tests FAIL

limit400
--------

clone06     0  WARN  :  sprintf() failed
clone06     1  BROK  :  Unexpected signal 11 received.
fcntl27     1  BROK  :  Unexpected signal 11 received.
fcntl28     1  BROK  :  Unexpected signal 11 received.
kill05      0  INFO  :  WARNING: shared memory deletion failed.
mincore01    4  FAIL  :  call succeeded unexpectedly
setrlimit03    1  FAIL  :  call succeeded unexpectedly
swapon02    0  WARN  :  Failed swapon for file swapfile31 returned -96
swapon02    0  WARN  :  Failed to turn off swap files. system reboot after execution of LTP test suite is recommended
swapon02    0  WARN  :  Failed to turn off swap files. system reboot after execution of LTP test suite is recommended
swapon02    3  BROK  :  Cleanup failed, quitting the test
swapon02    4  BROK  :  Remaining cases broken
INFO: pan reported some tests FAIL

notmnted
--------

clone06     0  WARN  :  sprintf() failed
clone06     1  BROK  :  Unexpected signal 11 received.
fcntl27     1  BROK  :  Unexpected signal 11 received.
fcntl28     1  BROK  :  Unexpected signal 11 received.
kill05      0  INFO  :  WARNING: shared memory deletion failed.
mincore01    4  FAIL  :  call succeeded unexpectedly
setrlimit03    1  FAIL  :  call succeeded unexpectedly
swapon02    0  WARN  :  Failed swapon for file swapfile31 returned -96
swapon02    0  WARN  :  Failed to turn off swap files. system reboot after execution of LTP test suite is recommended
swapon02    0  WARN  :  Failed to turn off swap files. system reboot after execution of LTP test suite is recommended
swapon02    3  BROK  :  Cleanup failed, quitting the test
swapon02    4  BROK  :  Remaining cases broken
INFO: pan reported some tests FAIL

VMMSTRESS
---------

The vmmstress function calls the following ltp tests: mmstress, mmap1.c,
mmap2.c and mmap3.c. 

disabled
--------

vmmstress1
----------

Test Start Time: Sat Aug 18 13:06:26 2007
-----------------------------------------
Testcase                       Result     Exit Value
--------                       ------     ----------
mmstress                       PASS       0    
mmap1                          PASS       0    
mmap2                          PASS       0    
mmap3                          PASS       0    

-----------------------------------------------
Total Tests: 4
Total Failures: 0
Kernel Version: 2.6.23-rc2-mm2-autokern1
Machine Architecture: x86_64

vmmstress2
----------

Test Start Time: Sat Aug 18 12:06:23 2007
-----------------------------------------
Testcase                       Result     Exit Value
--------                       ------     ----------
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        FAIL       14   

-----------------------------------------------
Total Tests: 1
Total Failures: 1
Kernel Version: 2.6.23-rc2-mm2-autokern1
Machine Architecture: x86_64


limit400
--------

vmmstress1
----------

Test Start Time: Sat Aug 18 08:37:36 2007
-----------------------------------------
Testcase                       Result     Exit Value
--------                       ------     ----------
mmstress                       PASS       0    
mmap1                          PASS       0    
mmap2                          PASS       0    
mmap3                          PASS       0    

-----------------------------------------------
Total Tests: 4
Total Failures: 0
Kernel Version: 2.6.23-rc2-mm2-autokern1
Machine Architecture: x86_64


vmmstress2
----------

Test Start Time: Sat Aug 18 07:37:29 2007
-----------------------------------------
Testcase                       Result     Exit Value
--------                       ------     ----------
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        FAIL       14   

-----------------------------------------------
Total Tests: 1
Total Failures: 1
Kernel Version: 2.6.23-rc2-mm2-autokern1
Machine Architecture: x86_64


notmnted
--------

vmmstress1
----------

Test Start Time: Sat Aug 18 03:05:16 2007
-----------------------------------------
Testcase                       Result     Exit Value
--------                       ------     ----------
mmstress                       PASS       0    
mmap1                          PASS       0    
mmap2                          PASS       0    
mmap3                          PASS       0    

-----------------------------------------------
Total Tests: 4
Total Failures: 0
Kernel Version: 2.6.23-rc2-mm2-autokern1
Machine Architecture: x86_64

vmmstress2
----------


Test Start Time: Sat Aug 18 02:05:14 2007
-----------------------------------------
Testcase                       Result     Exit Value
--------                       ------     ----------
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        FAIL       14   

-----------------------------------------------
Total Tests: 1
Total Failures: 1
Kernel Version: 2.6.23-rc2-mm2-autokern1
Machine Architecture: x86_64


AIM9
----

disabled
--------

Starting time:      Sat Aug 18 14:06:53 2007
Projected Run Time: 0:08:00
Projected finish:   Sat Aug 18 14:14:53 2007



------------------------------------------------------------------------------------------------------------
 Test        Test        Elapsed  Iteration    Iteration          Operation
Number       Name      Time (sec)   Count   Rate (loops/sec)    Rate (ops/sec)
------------------------------------------------------------------------------------------------------------
     1 creat-clo           60.01       9150  152.47459       152474.59 File Creations and Closes/second
     2 page_test           60.00       6803  113.38333       192751.67 System Allocations & Pages/second
     3 brk_test            60.01       8479  141.29312      2401983.00 System Memory Allocations/second
     4 jmp_test            60.01     983432 16387.80203     16387802.03 Non-local gotos/second
     5 signal_test         60.01      27402  456.62390       456623.90 Signal Traps/second
     6 exec_test           60.02       2789   46.46784          232.34 Program Loads/second
     7 fork_test           60.03       2736   45.57721         4557.72 Task Creations/second
     8 link_test           60.05      45537  758.31807        47774.04 Link/Unlink Pairs/second
------------------------------------------------------------------------------------------------------------
Projected Completion time:  Sat Aug 18 14:14:53 2007
Actual Completion time:     Sat Aug 18 14:14:53 2007
Difference:                 0:00:00


limit400
--------


Starting time:      Sat Aug 18 09:38:02 2007
Projected Run Time: 0:08:00
Projected finish:   Sat Aug 18 09:46:02 2007



------------------------------------------------------------------------------------------------------------
 Test        Test        Elapsed  Iteration    Iteration          Operation
Number       Name      Time (sec)   Count   Rate (loops/sec)    Rate (ops/sec)
------------------------------------------------------------------------------------------------------------
     1 creat-clo           60.01       7878  131.27812       131278.12 File Creations and Closes/second
     2 page_test           60.00       5411   90.18333       153311.67 System Allocations & Pages/second
     3 brk_test            60.02       5098   84.93835      1443952.02 System Memory Allocations/second
     4 jmp_test            60.00     983192 16386.53333     16386533.33 Non-local gotos/second
     5 signal_test         60.01      28628  477.05382       477053.82 Signal Traps/second
     6 exec_test           60.02       2628   43.78540          218.93 Program Loads/second
     7 fork_test           60.01       2510   41.82636         4182.64 Task Creations/second
     8 link_test           60.02      39902  664.81173        41883.14 Link/Unlink Pairs/second
------------------------------------------------------------------------------------------------------------
Projected Completion time:  Sat Aug 18 09:46:02 2007
Actual Completion time:     Sat Aug 18 09:46:02 2007
Difference:                 0:00:00


notmnted
--------

Starting time:      Sat Aug 18 04:06:05 2007
Projected Run Time: 0:08:00
Projected finish:   Sat Aug 18 04:14:05 2007



------------------------------------------------------------------------------------------------------------
 Test        Test        Elapsed  Iteration    Iteration          Operation
Number       Name      Time (sec)   Count   Rate (loops/sec)    Rate (ops/sec)
------------------------------------------------------------------------------------------------------------
     1 creat-clo           60.02       9164  152.68244       152682.44 File Creations and Closes/second
     2 page_test           60.01       5767   96.10065       163371.10 System Allocations & Pages/second
     3 brk_test            60.01       6147  102.43293      1741359.77 System Memory Allocations/second
     4 jmp_test            60.01     983397 16387.21880     16387218.80 Non-local gotos/second
     5 signal_test         60.01      26970  449.42510       449425.10 Signal Traps/second
     6 exec_test           60.02       2638   43.95202          219.76 Program Loads/second
     7 fork_test           60.01       2575   42.90952         4290.95 Task Creations/second
     8 link_test           60.01      49737  828.81186        52215.15 Link/Unlink Pairs/second
------------------------------------------------------------------------------------------------------------
Projected Completion time:  Sat Aug 18 04:14:05 2007
Actual Completion time:     Sat Aug 18 04:14:05 2007
Difference:                 0:00:00

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
