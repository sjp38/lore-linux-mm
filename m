Received: from mailrelay1.lanl.gov (localhost.localdomain [127.0.0.1])
	by mailwasher-b.lanl.gov (8.12.10/8.12.10/(ccn-5)) with ESMTP id i2PI4Sjt024168
	for <linux-mm@kvack.org>; Thu, 25 Mar 2004 11:04:28 -0700
Subject: 2.6.5-rc2-mm3 blizzard of "bad: scheduling while atomic" with
	PREEMPT
From: Steven Cole <elenstev@mesatop.com>
Content-Type: text/plain
Message-Id: <1080237733.2269.31.camel@spc0.esa.lanl.gov>
Mime-Version: 1.0
Date: Thu, 25 Mar 2004 11:02:14 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Apologies in advance if this is a known problem.  I looked through
some recent archives and didn't find this exact situation, so here it
is.  I'm just starting to test the -mm kernels again after a pause,
so I'm not up on the current problem set.

Kernel is 2.6.5-rc2-mm3 with SMP and PREEMPT.  Box is dual PIII.
Base distro is Mandrake 10.

These messages were the start of about 8,000 lines of similar.
The "while atomic" message came out about 374 times before it
seemed to stop.

Recompiling without PREEMPT made this go away.

Once, with 2.6.5-rc2-mm3 and PREEMPT, the box hung (during password
entry) while attempting to login via the KDE graphical login.  I have
not been able to reproduce this yet.

I usually reboot this box at least once a day with the current 2.6-bk
kernel, and haven't noticed any problems of that sort.

Steven

Mar 25 08:21:04 spc0 syslogd 1.4.1: restart.
Mar 25 08:21:04 spc0 kernel: klogd 1.4.1, log source = /proc/kmsg started.
Mar 25 08:21:04 spc0 kernel: Inspecting /boot/System.map-2.6.5-rc2-mm3
Mar 25 08:21:05 spc0 kernel: Loaded 20371 symbols from /boot/System.map-2.6.5-rc2-mm3.
Mar 25 08:21:05 spc0 kernel: Symbols match kernel version 2.6.5.
Mar 25 08:21:05 spc0 kernel: No module symbols loaded - kernel modules not enabled. 
Mar 25 08:21:05 spc0 kernel: 0/0x260
Mar 25 08:21:05 spc0 partmon: Checking if partitions have enough free diskspace: 
Mar 25 08:21:05 spc0 kernel:  [do_page_fault+294/1274] do_page_fault+0x126/0x4fa
Mar 25 08:21:05 spc0 kernel:  [<c0117676>] do_page_fault+0x126/0x4fa
Mar 25 08:21:05 spc0 kernel:  [do_sigaction+443/656] do_sigaction+0x1bb/0x290
Mar 25 08:21:05 spc0 kernel:  [<c012c92b>] do_sigaction+0x1bb/0x290
Mar 25 08:21:05 spc0 kernel:  [sys_rt_sigaction+192/256] sys_rt_sigaction+0xc0/0x100
Mar 25 08:21:05 spc0 kernel:  [<c012cdd0>] sys_rt_sigaction+0xc0/0x100
Mar 25 08:21:05 spc0 kernel:  [getname+130/176] getname+0x82/0xb0
Mar 25 08:21:05 spc0 kernel:  [<c0164012>] getname+0x82/0xb0
Mar 25 08:21:05 spc0 kernel:  [sys_execve+53/112] sys_execve+0x35/0x70
Mar 25 08:21:05 spc0 kernel:  [<c01073e5>] sys_execve+0x35/0x70
Mar 25 08:21:05 spc0 kernel:  [sysenter_past_esp+67/101] sysenter_past_esp+0x43/0x65
Mar 25 08:21:05 spc0 kernel:  [<c031b882>] sysenter_past_esp+0x43/0x65
Mar 25 08:21:05 spc0 kernel: 
Mar 25 08:21:05 spc0 kernel: bad: scheduling while atomic!
Mar 25 08:21:05 spc0 kernel: Call Trace:
Mar 25 08:21:05 spc0 kernel:  [schedule+1391/1472] schedule+0x56f/0x5c0
Mar 25 08:21:05 spc0 kernel:  [<c011b03f>] schedule+0x56f/0x5c0
Mar 25 08:21:05 spc0 kernel:  [recalc_task_prio+139/416] recalc_task_prio+0x8b/0x1a0
Mar 25 08:21:05 spc0 kernel:  [<c011886b>] recalc_task_prio+0x8b/0x1a0
Mar 25 08:21:05 spc0 kernel:  [wait_for_completion+156/304] wait_for_completion+0x9c/0x130
Mar 25 08:21:05 spc0 kernel:  [<c011b3ec>] wait_for_completion+0x9c/0x130
Mar 25 08:21:05 spc0 kernel:  [default_wake_function+0/16] default_wake_function+0x0/0x10
Mar 25 08:21:05 spc0 kernel:  [<c011b0e0>] default_wake_function+0x0/0x10
Mar 25 08:21:05 spc0 kernel:  [default_wake_function+0/16] default_wake_function+0x0/0x10
Mar 25 08:21:05 spc0 kernel:  [<c011b0e0>] default_wake_function+0x0/0x10
Mar 25 08:21:05 spc0 kernel:  [sched_migrate_task+141/176] sched_migrate_task+0x8d/0xb0
Mar 25 08:21:05 spc0 kernel:  [<c011977d>] sched_migrate_task+0x8d/0xb0
Mar 25 08:21:05 spc0 kernel:  [sched_balance_exec+92/128] sched_balance_exec+0x5c/0x80
Mar 25 08:21:05 spc0 kernel:  [<c01198fc>] sched_balance_exec+0x5c/0x80
Mar 25 08:21:05 spc0 kernel:  [do_execve+46/608] do_execve+0x2e/0x260
Mar 25 08:21:05 spc0 kernel:  [<c016269e>] do_execve+0x2e/0x260
Mar 25 08:21:05 spc0 kernel:  [buffered_rmqueue+269/576] buffered_rmqueue+0x10d/0x240
Mar 25 08:21:05 spc0 kernel:  [<c013aafd>] buffered_rmqueue+0x10d/0x240
Mar 25 08:21:05 spc0 kernel:  [__alloc_pages+176/752] __alloc_pages+0xb0/0x2f0
Mar 25 08:21:05 spc0 kernel:  [<c013ace0>] __alloc_pages+0xb0/0x2f0
Mar 25 08:21:05 spc0 kernel:  [page_remove_rmap+36/448] page_remove_rmap+0x24/0x1c0
Mar 25 08:21:05 spc0 kernel:  [<c014be44>] page_remove_rmap+0x24/0x1c0
Mar 25 08:21:05 spc0 kernel:  [do_wp_page+613/1008] do_wp_page+0x265/0x3f0
Mar 25 08:21:05 spc0 kernel:  [<c01465f5>] do_wp_page+0x265/0x3f0
Mar 25 08:21:05 spc0 kernel:  [handle_mm_fault+480/608] handle_mm_fault+0x1e0/0x260
Mar 25 08:21:05 spc0 kernel:  [<c0147860>] handle_mm_fault+0x1e0/0x260
Mar 25 08:21:05 spc0 kernel:  [do_page_fault+294/1274] do_page_fault+0x126/0x4fa
Mar 25 08:21:05 spc0 kernel:  [<c0117676>] do_page_fault+0x126/0x4fa
Mar 25 08:21:05 spc0 kernel:  [do_sigaction+443/656] do_sigaction+0x1bb/0x290
Mar 25 08:21:05 spc0 kernel:  [<c012c92b>] do_sigaction+0x1bb/0x290
Mar 25 08:21:05 spc0 kernel:  [sys_rt_sigaction+192/256] sys_rt_sigaction+0xc0/0x100
Mar 25 08:21:05 spc0 kernel:  [<c012cdd0>] sys_rt_sigaction+0xc0/0x100
Mar 25 08:21:05 spc0 kernel:  [getname+130/176] getname+0x82/0xb0
Mar 25 08:21:05 spc0 kernel:  [<c0164012>] getname+0x82/0xb0
Mar 25 08:21:05 spc0 kernel:  [sys_execve+53/112] sys_execve+0x35/0x70
Mar 25 08:21:05 spc0 kernel:  [<c01073e5>] sys_execve+0x35/0x70
Mar 25 08:21:05 spc0 kernel:  [sysenter_past_esp+67/101] sysenter_past_esp+0x43/0x65
Mar 25 08:21:05 spc0 kernel:  [<c031b882>] sysenter_past_esp+0x43/0x65
Mar 25 08:21:05 spc0 kernel: 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
