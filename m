Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [9.190.250.241])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9R0v6mV012560
	for <linux-mm@kvack.org>; Wed, 26 Oct 2005 21:07:28 -0400
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9QCSpLo037460
	for <linux-mm@kvack.org>; Wed, 26 Oct 2005 22:28:52 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11/8.13.3) with ESMTP id j9QCPoBR016677
	for <linux-mm@kvack.org>; Wed, 26 Oct 2005 22:25:50 +1000
In-Reply-To: <1130264833.6831.77.camel@localhost.localdomain>
MIME-Version: 1.0
Subject: Re: [Bug 5494] New: OOM killer kills process on kernel boot up and	system
 performance is very low
Message-ID: <OF2C511C60.85295EFB-ON652570A6.0041C556-652570A6.0044D92F@in.ibm.com>
From: Nagesh Sharyathi <sharyathi@in.ibm.com>
Date: Wed, 26 Oct 2005 17:57:33 +0530
Content-Type: text/plain; charset="US-ASCII"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>, Andrew Morton <akpm@osdl.org>
Cc: linux-mm <linux-mm@kvack.org>, Stephanie Glass <sglass@us.ibm.com>, B N Poornima <bnpoorni@in.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi
              I tried to call free in the boot scripts to check where 
exactly the memory is getting blocked 
Major portion of memory is getting consumed during the "Configure Kernel 
Parameters" block of rc.sysint script.
I tried to print the memory status in each step with free command.
I am attaching the console out put during execution of these steps, 
The complete console will be uploaded to the bug report 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        # Echo Statemetn rc.sysint Raid Autorun
                     total       used       free     shared    buffers 
cached
        Mem:       1486408      34848    1451560          0        800  
7260
        -/+ buffers/cache:      26788    1459620
        Swap:            0          0          0
raidautorun: failed to open /dev/md0: 6

        # Echo Statemetn rc.sysint Configure Kernel parameters
                     total       used       free     shared    buffers 
cached
        Mem:       1486408      34724    1451684          0        812  
7248
        -/+ buffers/cache:      26664    1459744
        Swap:            0          0          0
Configuring kernel parameters:  [  OK  ]

        # Echo Statemetn  rc.sysint System Clock
                     total       used       free     shared    buffers 
cached
        Mem:       1486408    1447604      38804          0        756  
7564
        -/+ buffers/cache:    1439284      47124
        Swap:            0          0          0
Setting clock  (localtime): Wed Oct 26 17:26:30 IST 2005 [  OK  ]
Setting hostname x225b.in.ibm.com:  [  OK  ]

        # Echo Statemetn  rc.sysint Initialize ACPI bits
                     total       used       free     shared    buffers 
cached
        Mem:       1486408    1444504      41904          0        524  
4416
        -/+ buffers/cache:    1439564      46844
        Swap:            0          0          0
Checking root filesystem
[/sbin/fsck.ext3 (1) -- /] fsck.ext3 -a /dev/sda2
/: clean, 345937/2052000 files, 2857168/4096000 blocks
[  OK  ]

        # Echo Statemetn  rc.sysint Unmount initrd
                     total       used       free     shared    buffers 
cached
        Mem:       1486408    1445876      40532          0       1464  
4516
        -/+ buffers/cache:    1439896      46512
        Swap:            0          0          0
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Regards
Sharyathi Nagesh





Badari Pulavarty <pbadari@gmail.com> 
25/10/2005 23:57

To
Andrew Morton <akpm@osdl.org>
cc
Nagesh Sharyathi/India/IBM@IBMIN, linux-mm <linux-mm@kvack.org>
Subject
Re: [Bug 5494] New: OOM killer kills process on kernel boot up and system 
performance is very low






On Tue, 2005-10-25 at 10:45 -0700, Andrew Morton wrote:
> bugme-daemon@kernel-bugs.osdl.org wrote:
> >
> >  http://bugzilla.kernel.org/show_bug.cgi?id=5494
> >
> >             Summary: OOM killer kills process on kernel boot up and 
system
> >                      performance is very low
> >      Kernel Version: 2.6.14-rc4
>
> You have an enormous memory leak.
>
>
> Active:1452 inactive:929 dirty:3 writeback:717 unstable:0 free:7065 
slab:2779 mapped:1356 pagetables:464
> DMA free:6160kB min:68kB low:84kB high:100kB active:0kB inactive:2348kB 
present:16384kB pages_scanned:1o
> lowmem_reserve[]: 0 880 1519
> Normal free:21604kB min:3756kB low:4692kB high:5632kB active:276kB 
inactive:188kB present:901120kB pages
> lowmem_reserve[]: 0 0 5119
> HighMem free:496kB min:512kB low:640kB high:768kB active:5532kB 
inactive:1052kB present:655296kB pages_s
> lowmem_reserve[]: 0 0 0
> DMA: 2*4kB 3*8kB 1*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 
0*2048kB 1*4096kB = 6160kB
> Normal: 1*4kB 20*8kB 36*16kB 10*32kB 3*64kB 1*128kB 1*256kB 1*512kB 
1*1024kB 1*2048kB 4*4096kB = 21604kB
> HighMem: 0*4kB 0*8kB 1*16kB 1*32kB 1*64kB 1*128kB 1*256kB 0*512kB 
0*1024kB 0*2048kB 0*4096kB = 496kB
> Swap cache: add 51244, delete 50404, find 25442/32337, race 0+13
>
> And it's leaking highmem too, so it has to be user memory: pagecache or
> anoymous RAM.
>
> I'm not too sure what to do really - something odd is happening because 
if
> this was happening generally then everyone in the world would be 
reporting
> it.
>
> I'd suggest you try switching compiler versions, try disabling unneeded
> features in .config, see if you can identify any one which causes the 
leak.
> Ideally, use `git bisect' to identify when the problem started 
occurring.
>
> All very strange.
>
> btw, what is this:
>
> Starting readahead:  [  OK  ]

"readahead" is a init script in RedHat distro which does

/usr/sbin/readahead `cat /etc/readahead.files` &

I guess it reads the files into pagecache.

(readahead(2)  -  Read  in advance one or more pages of a file
within a page cache)


Thanks,
Badari


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
