Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 03CC16B0012
	for <linux-mm@kvack.org>; Thu, 26 May 2011 01:03:28 -0400 (EDT)
Received: by wwi18 with SMTP id 18so4014315wwi.2
        for <linux-mm@kvack.org>; Wed, 25 May 2011 22:03:25 -0700 (PDT)
From: Hussam Al-Tayeb <ht990332@gmail.com>
Subject: Re: [Bugme-new] [Bug 35662] New: softlockup with kernel 2.6.39
Date: Thu, 26 May 2011 08:03:17 +0300
References: <bug-35662-10286@https.bugzilla.kernel.org/> <20110523164804.572cecfd.akpm@linux-foundation.org> <201105241001.47111.hussam@visp.net.lb>
In-Reply-To: <201105241001.47111.hussam@visp.net.lb>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201105260803.17827.hussam@visp.net.lb>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org

It happened again. also while doing a test build of libreoffice (very disk 
intensive stuff). 
The build process seems frozen. I did cat /var/log/kernel.log and run 
/bin/dmesg but didn't find any error.

so I typed init s then 
echo w > /proc/sysrq-trigger

and then I typed ps aux | grep D

root        23  0.0  0.0      0     0 ?        DN   May25   0:06 [khugepaged]
root      8673  0.0  0.0   4412   832 pts/2    S+   08:02   0:00 grep D

then I typed exit and I found the following in my kernel.log

11/05/26 07:54:00	udevd[7360]	starting version 170
11/05/26 07:54:01	leds_ss4200	no LED devices found
11/05/26 07:54:01	intel_rng	Firmware space is locked read-only. If you can't 
or
11/05/26 07:54:01	intel_rng	don't want to disable this in firmware setup, and 
if
11/05/26 07:54:01	intel_rng	you are certain that your system has a 
functional
11/05/26 07:54:01	intel_rng	RNG, try using the 'no_fwh_detect' option.
11/05/26 07:54:32	SysRq 	Show Blocked State
11/05/26 07:54:32		task PC stack pid father
11/05/26 07:54:32		khugepaged D f4393ca4 0 23 2 0x00000000
11/05/26 07:54:32		f4393cb4 00000046 00000002 f4393ca4 f4044dcc 00000000 
c0a8204e 000033ba
11/05/26 07:54:32		00000000 e20eba00 f4393c5c c10026ce 00000000 0098c500 
00000001 c14e1440
11/05/26 07:54:32		f4393c64 c14e1440 f5506440 f4044da0 f4042f70 e20eba00 
f4393d0c 00000286
11/05/26 07:54:32	Call Trace	
11/05/26 07:54:32		[<c10026ce>] ? __switch_to+0xce/0x180
11/05/26 07:54:32		[<c1052076>] ? lock_timer_base.isra.31+0x26/0x50
11/05/26 07:54:32		[<c1052106>] ? try_to_del_timer_sync+0x66/0x100
11/05/26 07:54:32		[<c1052076>] ? lock_timer_base.isra.31+0x26/0x50
11/05/26 07:54:32		[<c132e3ca>] schedule_timeout+0x12a/0x2e0
11/05/26 07:54:32		[<c1051630>] ? init_timer_deferrable_key+0x20/0x20
11/05/26 07:54:32		[<c132e231>] io_schedule_timeout+0x81/0xd0
11/05/26 07:54:32		[<c10d7ea2>] congestion_wait+0x52/0xe0
11/05/26 07:54:32		[<c1061750>] ? abort_exclusive_wait+0x80/0x80
11/05/26 07:54:32		[<c10f2501>] compact_zone+0x721/0x750
11/05/26 07:54:32		[<c10f25a9>] compact_zone_order+0x79/0xa0
11/05/26 07:54:32		[<c10f266d>] try_to_compact_pages+0x9d/0xd0
11/05/26 07:54:32		[<c10c6eee>] __alloc_pages_direct_compact+0x7e/0x160
11/05/26 07:54:32		[<c10c73ad>] __alloc_pages_nodemask+0x3dd/0x7b0
11/05/26 07:54:32		[<c10e5f7c>] ? page_add_new_anon_rmap+0x8c/0xa0
11/05/26 07:54:32		[<c10faea8>] khugepaged+0x418/0xe10
11/05/26 07:54:32		[<c1061750>] ? abort_exclusive_wait+0x80/0x80
11/05/26 07:54:32		[<c10faa90>] ? khugepaged_defrag_store+0x50/0x50
11/05/26 07:54:32		[<c1061098>] kthread+0x68/0x70
11/05/26 07:54:32		[<c1061030>] ? kthread_worker_fn+0x150/0x150
11/05/26 07:54:32		[<c133147e>] kernel_thread_helper+0x6/0xd
11/05/26 07:54:32	Sched Debug Version	v0.10, 2.6.39-ARCH #1
11/05/26 07:54:32		ktime : 56907897.973146
11/05/26 07:54:32		sched_clk : 56892856.276187
11/05/26 07:54:32		cpu_clk : 56907897.973092
11/05/26 07:54:32		jiffies : 16982371
11/05/26 07:54:32		sched_clock_stable : 0
11/05/26 07:54:32		
11/05/26 07:54:32		sysctl_sched
11/05/26 07:54:32		.sysctl_sched_latency : 12.000000
11/05/26 07:54:32		.sysctl_sched_min_granularity : 1.500000
11/05/26 07:54:32		.sysctl_sched_wakeup_granularity : 2.000000
11/05/26 07:54:32		.sysctl_sched_child_runs_first : 0
11/05/26 07:54:32		.sysctl_sched_features : 7279
11/05/26 07:54:32		.sysctl_sched_tunable_scaling : 1 (logaritmic)
11/05/26 07:54:32		
11/05/26 07:54:32		cpu#0, 2933.889 MHz
11/05/26 07:54:32		.nr_running : 1
11/05/26 07:54:32		.load : 1024
11/05/26 07:54:32		.nr_switches : 66131673
11/05/26 07:54:32		.nr_load_updates : 4725405
11/05/26 07:54:32		.nr_uninterruptible : 0
11/05/26 07:54:32		.next_balance : 16.982350
11/05/26 07:54:32		.curr->pid : 7949
11/05/26 07:54:32		.clock : 56907897.673964
11/05/26 07:54:32		.cpu_load[0] : 0
11/05/26 07:54:32		.cpu_load[1] : 0
11/05/26 07:54:32		.cpu_load[2] : 0
11/05/26 07:54:32		.cpu_load[3] : 0
11/05/26 07:54:32		.cpu_load[4] : 0
11/05/26 07:54:32		
11/05/26 07:54:32	cfs_rq[0]	autogroup-105
11/05/26 07:54:32		.exec_clock : 0.000000
11/05/26 07:54:32		.MIN_vruntime : 0.000001
11/05/26 07:54:32		.min_vruntime : 19.599979
11/05/26 07:54:32		.max_vruntime : 0.000001
11/05/26 07:54:32		.spread : 0.000000
11/05/26 07:54:32		.spread0 : -13633115.574964
11/05/26 07:54:32		.nr_spread_over : 0
11/05/26 07:54:32		.nr_running : 1
11/05/26 07:54:32		.load : 1024
11/05/26 07:54:32		.load_avg : 0.000000
11/05/26 07:54:32		.load_period : 9.999999
11/05/26 07:54:32		.load_contrib : 0
11/05/26 07:54:32		.load_tg : 0
11/05/26 07:54:32		.se->exec_start : 56907897.673964
11/05/26 07:54:32		.se->vruntime : 13633135.174943
11/05/26 07:54:32		.se->sum_exec_runtime : 19.279330
11/05/26 07:54:32		.se->load.weight : 1024
11/05/26 07:54:32		
11/05/26 07:54:32	cfs_rq[0]	
11/05/26 07:54:32		.exec_clock : 0.000000
11/05/26 07:54:32		.MIN_vruntime : 0.000001
11/05/26 07:54:32		.min_vruntime : 13633135.174943
11/05/26 07:54:32		.max_vruntime : 0.000001
11/05/26 07:54:32		.spread : 0.000000
11/05/26 07:54:32		.spread0 : 0.000000
11/05/26 07:54:32		.nr_spread_over : 0
11/05/26 07:54:32		.nr_running : 1
11/05/26 07:54:32		.load : 1024
11/05/26 07:54:32		.load_avg : 0.000000
11/05/26 07:54:32		.load_period : 0.000000
11/05/26 07:54:32		.load_contrib : 0
11/05/26 07:54:32		.load_tg : 0
11/05/26 07:54:32		
11/05/26 07:54:32	runnable tasks	
11/05/26 07:54:32		task PID tree-key switches prio exec-runtime sum-exec 
sum-sleep
11/05/26 07:54:32		
----------------------------------------------------------------------------------------------------------
11/05/26 07:54:32		R bash 7949 19.599979 63 120 0 0 0.000000 0.000000 
0.000000 /autogroup-105
11/05/26 07:54:32		
11/05/26 07:54:32		cpu#1, 2933.889 MHz
11/05/26 07:54:32		.nr_running : 0
11/05/26 07:54:32		.load : 0
11/05/26 07:54:32		.nr_switches : 66462726
11/05/26 07:54:32		.nr_load_updates : 4571341
11/05/26 07:54:32		.nr_uninterruptible : 1
11/05/26 07:54:32		.next_balance : 16.982370
11/05/26 07:54:32		.curr->pid : 0
11/05/26 07:54:32		.clock : 56907897.675594
11/05/26 07:54:32		.cpu_load[0] : 0
11/05/26 07:54:32		.cpu_load[1] : 0
11/05/26 07:54:32		.cpu_load[2] : 0
11/05/26 07:54:32		.cpu_load[3] : 0
11/05/26 07:54:32		.cpu_load[4] : 5
11/05/26 07:54:32		
11/05/26 07:54:32	cfs_rq[1]	
11/05/26 07:54:32		.exec_clock : 0.000000
11/05/26 07:54:32		.MIN_vruntime : 0.000001
11/05/26 07:54:32		.min_vruntime : 13650531.404239
11/05/26 07:54:32		.max_vruntime : 0.000001
11/05/26 07:54:32		.spread : 0.000000
11/05/26 07:54:32		.spread0 : 17396.229296
11/05/26 07:54:32		.nr_spread_over : 0
11/05/26 07:54:32		.nr_running : 0
11/05/26 07:54:32		.load : 0
11/05/26 07:54:32		.load_avg : 0.000000
11/05/26 07:54:32		.load_period : 0.000000
11/05/26 07:54:32		.load_contrib : 0
11/05/26 07:54:32		.load_tg : 0
11/05/26 07:54:32		
11/05/26 07:54:32	runnable tasks	
11/05/26 07:54:32		task PID tree-key switches prio exec-runtime sum-exec 
sum-sleep
11/05/26 07:54:32		
----------------------------------------------------------------------------------------------------------
11/05/26 07:54:32		
11/05/26 07:55:01	usb 3-2	USB disconnect, device number 2
11/05/26 07:55:02	ppp0	Features changed: 0x00006800 -> 0x00006000
11/05/26 07:55:02	usb 3-2	new low speed USB device number 3 using uhci_hcd
11/05/26 07:55:03	input	PIXART USB OPTICAL MOUSE as 
/devices/pci0000:00/0000:00:1d.1/usb3/3-2/3-2:1.0/input/input9
11/05/26 07:55:03	generic-usb 0003	93A:2510.0002: input,hidraw0: USB HID 
v1.11 Mouse [PIXART USB OPTICAL MOUSE] on usb-0000:00:1d.1-2/input0
11/05/26 07:55:05	0000	2:05.0: tulip_stop_rxtx() failed (CSR5 0xfc664010 
CSR6 0xff972113)
11/05/26 07:55:05	net eth0	Setting full-duplex based on MII#1 link partner 
capability of 45e1
11/05/26 07:55:05	w83627ehf	Found W83627DHG chip at 0x290
11/05/26 07:55:12	eth0	no IPv6 routers present
11/05/26 07:55:19	EXT4-fs (dm-0)	re-mounted. Opts: user_xattr,commit=0
11/05/26 07:55:19	EXT4-fs (sda1)	re-mounted. Opts: user_xattr,commit=0
11/05/26 07:55:20	EXT4-fs (dm-1)	re-mounted. Opts: user_xattr,commit=0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
