Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 390476B0055
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 10:56:43 -0400 (EDT)
Received: from coyote.coyote.den ([72.65.71.44]) by vms173019.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008; 32bit))
 with ESMTPA id <0KMF007782VV1050@vms173019.mailsrvcs.net> for
 linux-mm@kvack.org; Tue, 07 Jul 2009 09:57:32 -0500 (CDT)
From: Gene Heskett <gene.heskett@verizon.net>
Subject: Re: OOM killer in 2.6.31-rc2
Date: Tue, 07 Jul 2009 10:57:30 -0400
References: <200907061056.00229.gene.heskett@verizon.net>
 <20090707061213.GA21004@localhost>
In-reply-to: <20090707061213.GA21004@localhost>
MIME-version: 1.0
Content-type: Text/Plain; charset=iso-8859-1
Content-transfer-encoding: 7bit
Content-disposition: inline
Message-id: <200907071057.31152.gene.heskett@verizon.net>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, David Howells <dhowells@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 07 July 2009, Wu Fengguang wrote:
>On Mon, Jul 06, 2009 at 10:56:00AM -0400, Gene Heskett wrote:
>> Greetings all;
>>
>> I had to hard reset this box just now as there was no response to a
>> ctl-alt- bksp when X was un-responsive this morning.
>>
>> I had built a 2nd version of the 2.6.31-rc2 kernel last night when I found
>> the video stuff appeared to have been moved in the .config and my
>> pcHDTV-3000 cards modules were not being built, but are now.  That kernel
>> was installed, and if at some time in the night a module was needed, it
>> would have been available, but I can't make a solid connection.
>>
>> This machine will always be marked as 'tainted' because any bios update
>> that fixes the very early boot time oops, also leaves me with a machine
>> that will crash hard in 30 seconds to 3 or 4 hours.  The fixes done by the
>> oops make it generally dead stable for weeks.  That oops:
>>
>> Jul  6 10:03:58 coyote kernel: [    0.000000] BIOS-provided physical RAM
>> map: Jul  6 10:03:58 coyote kernel: [    0.000000]  BIOS-e820:
>> 0000000000000000 - 000000000009f000 (usable) Jul  6 10:03:58 coyote
>> kernel: [    0.000000]  BIOS-e820: 000000000009f000 - 00000000000a0000
>> (reserved) Jul  6 10:03:58 coyote kernel: [    0.000000]  BIOS-e820:
>> 00000000000f0000 - 0000000000100000 (reserved) Jul  6 10:03:58 coyote
>> kernel: [    0.000000]  BIOS-e820: 0000000000100000 - 00000000dfee0000
>> (usable) Jul  6 10:03:58 coyote kernel: [    0.000000]  BIOS-e820:
>> 00000000dfee0000 - 00000000dfee3000 (ACPI NVS) Jul  6 10:03:58 coyote
>> kernel: [    0.000000]  BIOS-e820: 00000000dfee3000 - 00000000dfef0000
>> (ACPI data) Jul  6 10:03:58 coyote kernel: [    0.000000]  BIOS-e820:
>> 00000000dfef0000 - 00000000dff00000 (reserved) Jul  6 10:03:58 coyote
>> kernel: [    0.000000]  BIOS-e820: 00000000f0000000 - 00000000f4000000
>> (reserved) Jul  6 10:03:58 coyote kernel: [    0.000000]  BIOS-e820:
>> 00000000fec00000 - 0000000100000000 (reserved) Jul  6 10:03:58 coyote
>> kernel: [    0.000000]  BIOS-e820: 0000000100000000 - 0000000120000000
>> (usable) Jul  6 10:03:58 coyote kernel: [    0.000000] DMI 2.4 present.
>> Jul  6 10:03:58 coyote kernel: [    0.000000] Phoenix BIOS detected: BIOS
>> may corrupt low RAM, working around it. Jul  6 10:03:58 coyote kernel: [  
>>  0.000000] last_pfn = 0x120000 max_arch_pfn = 0x1000000 Jul  6 10:03:58
>> coyote kernel: [    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406,
>> new 0x7010600070106 Jul  6 10:03:58 coyote kernel: [    0.000000]
>> ------------[ cut here ]------------ Jul  6 10:03:58 coyote kernel: [   
>> 0.000000] WARNING: at arch/x86/kernel/cpu/mtrr/generic.c:456
>> generic_get_mtrr+0x12c/0x150()
>> Jul  6 10:03:58 coyote kernel: [    0.000000] Hardware name: System
>> Product Name Jul  6 10:03:58 coyote kernel: [    0.000000] mtrr: your BIOS
>> has set up an incorrect mask, fixing it up. Jul  6 10:03:58 coyote kernel:
>> [    0.000000] Modules linked in:
>> Jul  6 10:03:58 coyote kernel: [    0.000000] Pid: 0, comm: swapper Not
>> tainted 2.6.31-rc2 #2 Jul  6 10:03:58 coyote kernel: [    0.000000] Call
>> Trace:
>> Jul  6 10:03:58 coyote kernel: [    0.000000]  [<c101449c>] ?
>> generic_get_mtrr+0x12c/0x150 Jul  6 10:03:58 coyote kernel: [    0.000000]
>>  [<c103693d>] warn_slowpath_common+0x7d/0xe0 Jul  6 10:03:58 coyote
>> kernel: [    0.000000]  [<c101449c>] ? generic_get_mtrr+0x12c/0x150 Jul  6
>> 10:03:58 coyote kernel: [    0.000000]  [<c1036a13>]
>> warn_slowpath_fmt+0x33/0x50 Jul  6 10:03:58 coyote kernel: [    0.000000] 
>> [<c101449c>] generic_get_mtrr+0x12c/0x150 Jul  6 10:03:58 coyote kernel: [
>>    0.000000]  [<c1422e1a>] mtrr_trim_uncached_memory+0x85/0x368 Jul  6
>> 10:03:58 coyote kernel: [    0.000000]  [<c142191e>] ?
>> mtrr_bp_init+0x1d9/0x2bb Jul  6 10:03:58 coyote kernel: [    0.000000] 
>> [<c141c369>] setup_arch+0x52c/0xa33 Jul  6 10:03:58 coyote kernel: [   
>> 0.000000]  [<c11c0020>] ? thermal_get_trip_type+0x0/0x9c Jul  6 10:03:58
>> coyote kernel: [    0.000000]  [<c1418bb4>] start_kernel+0xb2/0x38b Jul  6
>> 10:03:58 coyote kernel: [    0.000000]  [<c1418394>]
>> i386_start_kernel+0x84/0xb0 Jul  6 10:03:58 coyote kernel: [    0.000000]
>> ---[ end trace a7919e7f17c0a725 ]--- Jul  6 10:03:58 coyote kernel: [   
>> 0.000000] Scanning 0 areas for low memory corruption Jul  6 10:03:58
>> coyote kernel: [    0.000000] modified physical RAM map: Jul  6 10:03:58
>> coyote kernel: [    0.000000]  modified: 0000000000000000 -
>> 0000000000010000 (reserved) Jul  6 10:03:58 coyote kernel: [    0.000000] 
>> modified: 0000000000010000 - 000000000009f000 (usable) Jul  6 10:03:58
>> coyote kernel: [    0.000000]  modified: 000000000009f000 -
>> 00000000000a0000 (reserved) Jul  6 10:03:58 coyote kernel: [    0.000000] 
>> modified: 00000000000f0000 - 0000000000100000 (reserved) Jul  6 10:03:58
>> coyote kernel: [    0.000000]  modified: 0000000000100000 -
>> 00000000dfee0000 (usable) Jul  6 10:03:58 coyote kernel: [    0.000000] 
>> modified: 00000000dfee0000 - 00000000dfee3000 (ACPI NVS) Jul  6 10:03:58
>> coyote kernel: [    0.000000]  modified: 00000000dfee3000 -
>> 00000000dfef0000 (ACPI data) Jul  6 10:03:58 coyote kernel: [    0.000000]
>>  modified: 00000000dfef0000 - 00000000dff00000 (reserved) Jul  6 10:03:58
>> coyote kernel: [    0.000000]  modified: 00000000f0000000 -
>> 00000000f4000000 (reserved) Jul  6 10:03:58 coyote kernel: [    0.000000] 
>> modified: 00000000fec00000 - 0000000100000000 (reserved) Jul  6 10:03:58
>> coyote kernel: [    0.000000]  modified: 0000000100000000 -
>> 0000000120000000 (usable) Jul  6 10:03:58 coyote kernel: [    0.000000]
>> init_memory_mapping: 0000000000000000-00000000379fe000 Jul  6 10:03:58
>> coyote kernel: [    0.000000] NX (Execute Disable) protection: active
>>
>> You all have seen this one before, several times.  I have asked that
>> since its a good fix, that the kernel not be marked tainted in that
>> instance.  I would run the asus bios that didn't do that _IF_ it was
>> stable.  2 newer versions are _not_ stable, this is stable after the fix.
>>
>> The machine has 4G of ram & is I believe 'pae'
>>
>> The oom's first stanza:
>>
>> Jul  6 06:45:01 coyote kernel: [78748.106803] X invoked oom-killer:
>> gfp_mask=0xd0, order=0, oom_adj=0 Jul  6 06:45:01 coyote kernel:
>> [78748.106808] Pid: 3068, comm: X Tainted: G        W  2.6.31-rc2 #1 Jul 
>> 6 06:45:01 coyote kernel: [78748.106811] Call Trace:
>> Jul  6 06:45:01 coyote kernel: [78748.106818]  [<c1308513>] ?
>> printk+0x23/0x40 Jul  6 06:45:01 coyote kernel: [78748.106823] 
>> [<c107e268>] oom_kill_process+0x178/0x270 Jul  6 06:45:01 coyote kernel:
>> [78748.106827]  [<c107e6ad>] ? badness+0x14d/0x220 Jul  6 06:45:01 coyote
>> kernel: [78748.106830]  [<c107e8c2>] __out_of_memory+0x142/0x170 Jul  6
>> 06:45:01 coyote kernel: [78748.106834]  [<c107e949>]
>> out_of_memory+0x59/0xc0 Jul  6 06:45:01 coyote kernel: [78748.106837] 
>> [<c1081d17>] __alloc_pages_nodemask+0x4f7/0x510 Jul  6 06:45:01 coyote
>> kernel: [78748.106841]  [<c1081db3>] __get_free_pages+0x23/0x50 Jul  6
>> 06:45:01 coyote kernel: [78748.106845]  [<c10bf8b2>] __pollwait+0xb2/0xf0
>> Jul  6 06:45:01 coyote kernel: [78748.106848]  [<c12f6528>]
>> unix_poll+0x28/0xc0 Jul  6 06:45:01 coyote kernel: [78748.106851] 
>> [<c1281b7e>] sock_poll+0x1e/0x40 Jul  6 06:45:01 coyote kernel:
>> [78748.106853]  [<c10bee8e>] do_select+0x34e/0x6b0 Jul  6 06:45:01 coyote
>> kernel: [78748.106871]  [<c10bf800>] ? __pollwait+0x0/0xf0 Jul  6 06:45:01
>> coyote kernel: [78748.106874]  [<c10bf8f0>] ? pollwake+0x0/0x90 Jul  6
>> 06:45:01 coyote kernel: [78748.106877]  [<c10bf8f0>] ? pollwake+0x0/0x90
>> Jul  6 06:45:01 coyote kernel: [78748.106879]  [<c10bf8f0>] ?
>> pollwake+0x0/0x90 Jul  6 06:45:01 coyote kernel: [78748.106882] 
>> [<c10bf8f0>] ? pollwake+0x0/0x90 Jul  6 06:45:01 coyote kernel:
>> [78748.106884]  [<c10bf8f0>] ? pollwake+0x0/0x90 Jul  6 06:45:01 coyote
>> kernel: [78748.106887]  [<c10bf8f0>] ? pollwake+0x0/0x90 Jul  6 06:45:01
>> coyote kernel: [78748.106890]  [<c10bf8f0>] ? pollwake+0x0/0x90 Jul  6
>> 06:45:01 coyote kernel: [78748.106892]  [<c10bf8f0>] ? pollwake+0x0/0x90
>> Jul  6 06:45:01 coyote kernel: [78748.106895]  [<c10bf8f0>] ?
>> pollwake+0x0/0x90 Jul  6 06:45:01 coyote kernel: [78748.106897] 
>> [<c10bf8f0>] ? pollwake+0x0/0x90 Jul  6 06:45:01 coyote kernel:
>> [78748.106900]  [<c10bf8f0>] ? pollwake+0x0/0x90 Jul  6 06:45:01 coyote
>> kernel: [78748.106902]  [<c10bf8f0>] ? pollwake+0x0/0x90 Jul  6 06:45:01
>> coyote kernel: [78748.106905]  [<c10bf8f0>] ? pollwake+0x0/0x90 Jul  6
>> 06:45:01 coyote kernel: [78748.106907]  [<c10bf8f0>] ? pollwake+0x0/0x90
>> Jul  6 06:45:01 coyote kernel: [78748.106910]  [<c10bf8f0>] ?
>> pollwake+0x0/0x90 Jul  6 06:45:01 coyote kernel: [78748.106913] 
>> [<c10bf8f0>] ? pollwake+0x0/0x90 Jul  6 06:45:01 coyote kernel:
>> [78748.106915]  [<c10bf8f0>] ? pollwake+0x0/0x90 Jul  6 06:45:01 coyote
>> kernel: [78748.106918]  [<c10bf8f0>] ? pollwake+0x0/0x90 Jul  6 06:45:01
>> coyote kernel: [78748.106920]  [<c10bf402>] core_sys_select+0x212/0x350
>> Jul  6 06:45:01 coyote kernel: [78748.106925]  [<c10be292>] ?
>> poll_select_set_timeout+0x82/0x90 Jul  6 06:45:01 coyote kernel:
>> [78748.106928]  [<c10bf761>] sys_select+0x51/0xf0 Jul  6 06:45:01 coyote
>> kernel: [78748.106931]  [<c10031b7>] sysenter_do_call+0x12/0x22 Jul  6
>> 06:45:01 coyote kernel: [78748.106933] Mem-Info:
>> Jul  6 06:45:01 coyote kernel: [78748.106935] DMA per-cpu:
>> Jul  6 06:45:01 coyote kernel: [78748.106937] CPU    0: hi:    0, btch:  
>> 1 usd:   0 Jul  6 06:45:01 coyote kernel: [78748.106939] CPU    1: hi:   
>> 0, btch:   1 usd:   0 Jul  6 06:45:01 coyote kernel: [78748.106941] CPU   
>> 2: hi:    0, btch:   1 usd:   0 Jul  6 06:45:01 coyote kernel:
>> [78748.106943] CPU    3: hi:    0, btch:   1 usd:   0 Jul  6 06:45:01
>> coyote kernel: [78748.106944] Normal per-cpu:
>> Jul  6 06:45:01 coyote kernel: [78748.106946] CPU    0: hi:  186, btch: 
>> 31 usd: 118 Jul  6 06:45:01 coyote kernel: [78748.106948] CPU    1: hi: 
>> 186, btch:  31 usd: 171 Jul  6 06:45:01 coyote kernel: [78748.106950] CPU 
>>   2: hi:  186, btch:  31 usd: 159 Jul  6 06:45:01 coyote kernel:
>> [78748.106952] CPU    3: hi:  186, btch:  31 usd: 172 Jul  6 06:45:01
>> coyote kernel: [78748.106954] HighMem per-cpu:
>> Jul  6 06:45:01 coyote kernel: [78748.106955] CPU    0: hi:  186, btch: 
>> 31 usd:  56 Jul  6 06:45:01 coyote kernel: [78748.106957] CPU    1: hi: 
>> 186, btch:  31 usd:  20 Jul  6 06:45:01 coyote kernel: [78748.106959] CPU 
>>   2: hi:  186, btch:  31 usd:  53 Jul  6 06:45:01 coyote kernel:
>> [78748.106961] CPU    3: hi:  186, btch:  31 usd: 180 Jul  6 06:45:01
>> coyote kernel: [78748.106965] Active_anon:90702 active_file:136927
>> inactive_anon:26328 Jul  6 06:45:01 coyote kernel: [78748.106966] 
>> inactive_file:1956 unevictable:25 dirty:4 writeback:0 unstable:0 Jul  6
>> 06:45:01 coyote kernel: [78748.106967]  free:560899 slab:206505
>> mapped:19048 pagetables:3220 bounce:0 Jul  6 06:45:01 coyote kernel:
>> [78748.106971] DMA free:3496kB min:64kB low:80kB high:96kB active_anon:0kB
>> inactive_anon:0kB acti
>> ve_file:12kB inactive_file:8kB unevictable:0kB present:15804kB
>> pages_scanned:0 all_unreclaimable? yes Jul  6 06:45:01 coyote kernel:
>> [78748.106983] lowmem_reserve[]: 0 0 25406 25406 Jul  6 06:45:01 coyote
>> kernel: [78748.106988] HighMem free:2236464kB min:512kB low:3928kB
>> high:7348kB active_anon:362808kB inact
>> ive_anon:105308kB active_file:547220kB inactive_file:7704kB
>> unevictable:100kB present:3252052kB pages_scanned:0 all_unreclaimabl
>> e? no
>
>Normal zone is absent in the above lines.

Is this a .config issue?
>
>> Jul  6 06:45:01 coyote kernel: [78748.106991] lowmem_reserve[]: 0 0 0 0
>> Jul  6 06:45:01 coyote kernel: [78748.106994] DMA: 310*4kB 204*8kB 27*16kB
>> 6*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048
>> kB 0*4096kB = 3496kB
>> Jul  6 06:45:01 coyote kernel: [78748.107002] Normal: 1*4kB 0*8kB 1*16kB
>> 1*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB
>>  0*4096kB = 3636kB
>> Jul  6 06:45:01 coyote kernel: [78748.107009] HighMem: 45888*4kB 44682*8kB
>> 32844*16kB 18479*32kB 6641*64kB 1114*128kB 37*256kB 1
>> *512kB 1*1024kB 0*2048kB 0*4096kB = 2236464kB
>> Jul  6 06:45:01 coyote kernel: [78748.107017] 139771 total pagecache pages
>> Jul  6 06:45:01 coyote kernel: [78748.107019] 616 pages in swap cache
>> Jul  6 06:45:01 coyote kernel: [78748.107021] Swap cache stats: add 7937,
>> delete 7321, find 2362/2515 Jul  6 06:45:01 coyote kernel: [78748.107023]
>> Free swap  = 8360652kB Jul  6 06:45:01 coyote kernel: [78748.107024] Total
>> swap = 8385912kB Jul  6 06:45:01 coyote kernel: [78748.121323] 1179632
>> pages RAM
>> Jul  6 06:45:01 coyote kernel: [78748.121325] 951810 pages HighMem
>
>HighMem zone is 3.7G, which is _too much_ given the total memory is 4G.

And that mistake is where?  I have a feeling that is the $64K question.
>
>> Jul  6 06:45:01 coyote kernel: [78748.121327] 146165 pages reserved
>> Jul  6 06:45:01 coyote kernel: [78748.121328] 149491 pages shared
>> Jul  6 06:45:01 coyote kernel: [78748.121329] 441615 pages non-shared
>> Jul  6 06:45:01 coyote kernel: [78748.121332] Out of memory: kill process
>> 2385 (mysqld) score 15451 or a child Jul  6 06:45:01 coyote kernel:
>> [78748.121334] Killed process 2385 (mysqld)
>>
>> and continued to:
>>
>> Jul  6 06:45:01 coyote kernel: [78748.137525] Killed process 30192 (spamd)
>> Jul  6 06:45:01 coyote kernel: [78748.154292] Killed process 2506 (httpd)
>> Jul  6 06:45:01 coyote kernel: [78748.170851] Killed process 2507 (httpd)
>> Jul  6 06:45:01 coyote kernel: [78748.187519] Killed process 2508 (httpd)
>> Jul  6 06:45:01 coyote kernel: [78748.320880] Killed process 2510 (httpd)
>> Jul  6 06:45:01 coyote kernel: [78748.337529] Killed process 2511 (httpd)
>> Jul  6 06:45:05 coyote kernel: [78751.467158] Killed process 948 (spamd)
>> Jul  6 06:45:05 coyote kernel: [78751.483535] Killed process 963 (httpd)
>> Jul  6 06:45:05 coyote kernel: [78751.500194] Killed process 964 (httpd)
>> Jul  6 06:45:05 coyote kernel: [78751.502688] Killed process 965 (httpd)
>> Jul  6 06:45:05 coyote kernel: [78751.506025] Killed process 2512 (httpd)
>> Jul  6 06:45:05 coyote kernel: [78751.509376] Killed process 2513 (httpd)
>> Jul  6 06:45:05 coyote kernel: [78751.512713] Killed process 2514 (httpd)
>> Jul  6 06:45:05 coyote kernel: [78751.516057] Killed process 1995
>> (krunner_lock) Jul  6 06:45:05 coyote kernel: [78751.519481] Killed
>> process 3391 (kwin) Jul  6 06:45:05 coyote kernel: [78751.522674] Killed
>> process 3396 (plasma) Jul  6 06:45:05 coyote kernel: [78751.526006] Killed
>> process 6931 (kmail) Jul  6 06:45:05 coyote kernel: [78751.542786] Killed
>> process 16309 (spamd) Jul  6 06:45:05 coyote kernel: [78751.546042] Killed
>> process 3421 (krunner) Jul  6 06:45:05 coyote kernel: [78751.549521]
>> Killed process 3357 (klauncher) Jul  6 06:45:05 coyote kernel:
>> [78751.552760] Killed process 3526 (kcalc) Jul  6 06:45:05 coyote kernel:
>> [78751.759570] Killed process 3068 (X) Jul  6 06:45:05 coyote kernel:
>> [78751.765648] Killed process 3389 (ksmserver)
>
>Are you running thousands of httpd or other processes?

No, according to htop, the single start of httpd is running 9 instances total 
which ISTR is normal from previous observation.  This is booted to 2.6.30.1.  
htop says 662/4052 megs of memory, with the red bar extending to maybe the 3G 
mark when booted to this 2.6.30.1 kernel.

The above shows more httpd's than were running normally.  Does it start 
another instance to service a request?  My httpd server is only accessable to 
the net via a port forward in dd-wrt, so it isn't something a drive-by would 
normally find.

gkrellm shows about 316 processes running with 17 users, all of whom are 
either system or related to me (I'm the only real user but delegate some 
things to normal users, like mail fetching etc), and I don't recall seeing any 
noticeably larger values when 31-rc2 was running, at least not early in the 
run.  The oom deaths were all at times when I wasn't present.

>Thanks,
>Fengguang
>
>> The oom started at 6:45:01 this morning.  mysqld wasn't doing anything &
>> the only reason its even started is for mythtv, which is how I found my
>> pcHDTV-3000 was on the missing list even if occupying a slot.
>>
>> I've no idea if the rebuilt (with v4l drivers now) will also crash.
>> It feels normal.  And looks normal in htop's display, using 538M of 4096M,
>> no swap used yet.

But that rebuilt 31-rc2 also died in about 12 hours due to oom, as I posted 
later.
>>
>> >From my .config:
>>
>> # grep MEM .config
>> CONFIG_SHMEM=y
>> # CONFIG_MEMTEST is not set
>> # CONFIG_NOHIGHMEM is not set
>> # CONFIG_HIGHMEM4G is not set
>> CONFIG_HIGHMEM64G=y
>> CONFIG_HIGHMEM=y
>> CONFIG_ARCH_FLATMEM_ENABLE=y
>> CONFIG_ARCH_SPARSEMEM_ENABLE=y
>> CONFIG_ARCH_SELECT_MEMORY_MODEL=y
>> CONFIG_SELECT_MEMORY_MODEL=y
>> CONFIG_FLATMEM_MANUAL=y
>> # CONFIG_DISCONTIGMEM_MANUAL is not set
>> # CONFIG_SPARSEMEM_MANUAL is not set
>> CONFIG_FLATMEM=y
>> CONFIG_FLAT_NODE_MEM_MAP=y
>> CONFIG_SPARSEMEM_STATIC=y
>> CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
>> CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
>> # CONFIG_BLK_DEV_UMEM is not set
>> # CONFIG_INPUT_FF_MEMLESS is not set
>> CONFIG_DEVKMEM=y
>> CONFIG_FIX_EARLYCON_MEM=y
>> # CONFIG_HW_RANDOM_TIMERIOMEM is not set
>> # CONFIG_MEMSTICK is not set
>> CONFIG_FIRMWARE_MEMMAP=y
>> CONFIG_DEBUG_MEMORY_INIT=y
>> CONFIG_HAVE_ARCH_KMEMCHECK=y
>> CONFIG_STRICT_DEVMEM=y
>> CONFIG_HAS_IOMEM=y
>>
>> In case I have some option miss-set in that, plz advise.

Thanks guys.

-- 
Cheers, Gene
"There are four boxes to be used in defense of liberty:
 soap, ballot, jury, and ammo. Please use in that order."
-Ed Howdershelt (Author)
The NRA is offering FREE Associate memberships to anyone who wants them.
<https://www.nrahq.org/nrabonus/accept-membership.asp>

The best book on programming for the layman is "Alice in Wonderland";
but that's because it's the best book on anything for the layman.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
