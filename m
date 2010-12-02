Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B31EE8D000E
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 23:27:02 -0500 (EST)
Date: Wed, 1 Dec 2010 23:26:54 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <414645031.1024011291264014168.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <AANLkTi=tfDQhcNwhDeLz9jM5QHjDR_8WL+v6AWU3SJpZ@mail.gmail.com>
Subject: Re: oom is broken in mmotm 2010-11-09-15-31 tree?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>


> Interesting. That commit is not supposed to make any semantic
> difference at all. And even if we do end up in the retry path, the
> arch/x86/mm/fault.c code is very explicitly designed so that it
> retries only _once_.
> 
> Michel, any ideas? I could see problems with the mmap_sem if
> VM_FAULT_OOM is set at the same time as VM_FAULT_RETRY, but I can't
> see how that could ever happen.
> 
> Anybody?
> 
> CAI, can you get any output from sysrq-W when this happens?
Hi Linus, please see below,

CAI Qian

[  580.191996] SysRq : Show Blocked State
[  580.192024]   task                        PC stack   pid father
[  580.192024] Sched Debug Version: v0.09, 2.6.36+ #22
[  580.192024] now at 580203.234510 msecs
[  580.192024]   .jiffies                                 : 4295247509
[  580.192024]   .sysctl_sched_latency                    : 18.000000
[  580.192024]   .sysctl_sched_min_granularity            : 2.250000
[  580.192024]   .sysctl_sched_wakeup_granularity         : 3.000000
[  580.192024]   .sysctl_sched_child_runs_first           : 0
[  580.192024]   .sysctl_sched_features                   : 31855
[  580.192024]   .sysctl_sched_tunable_scaling            : 1 (logaritmic)
[  580.192024] 
[  580.192024] cpu#0, 2826.528 MHz
[  580.192024]   .nr_running                    : 1
[  580.192024]   .load                          : 1024
[  580.192024]   .nr_switches                   : 35799
[  580.192024]   .nr_load_updates               : 128515
[  580.192024]   .nr_uninterruptible            : 0
[  580.192024]   .next_balance                  : 4295.247545
[  580.192024]   .curr->pid                     : 1366
[  580.192024]   .clock                         : 580191.025058
[  580.192024]   .cpu_load[0]                   : 1024
[  580.192024]   .cpu_load[1]                   : 1016
[  580.192024]   .cpu_load[2]                   : 957
[  580.192024]   .cpu_load[3]                   : 872
[  580.192024]   .cpu_load[4]                   : 799
[  580.192024]   .yld_count                     : 140
[  580.192024]   .sched_switch                  : 0
[  580.192024]   .sched_count                   : 44224
[  580.192024]   .sched_goidle                  : 6268
[  580.192024]   .avg_idle                      : 1000000
[  580.192024]   .ttwu_count                    : 11413
[  580.192024]   .ttwu_local                    : 8684
[  580.192024]   .bkl_count                     : 0
[  580.192024] 
[  580.192024] cfs_rq[0]:/
[  580.192024]   .exec_clock                    : 125215.744234
[  580.192024]   .MIN_vruntime                  : 0.000001
[  580.192024]   .min_vruntime                  : 45692.541683
[  580.192024]   .max_vruntime                  : 0.000001
[  580.192024]   .spread                        : 0.000000
[  580.192024]   .spread0                       : 0.000000
[  580.192024]   .nr_running                    : 1
[  580.192024]   .load                          : 1024
[  580.192024]   .nr_spread_over                : 4
[  580.192024]   .shares                        : 0
[  580.192024] 
[  580.192024] rt_rq[0]:/
[  580.192024]   .rt_nr_running                 : 0
[  580.192024]   .rt_throttled                  : 0
[  580.192024]   .rt_time                       : 0.000000
[  580.192024]   .rt_runtime                    : 950.000000
[  580.192024] 
[  580.192024] runnable tasks:
[  580.192024]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[  580.192024] ----------------------------------------------------------------------------------------------------------
[  580.192024] R       sendmail  1366     45692.541683      9276   120     45692.541683     46469.996943    411694.347209 /
[  580.192024] 
[  580.192024] cpu#1, 2826.528 MHz
[  580.192024]   .nr_running                    : 2
[  580.192024]   .load                          : 2048
[  580.192024]   .nr_switches                   : 46514
[  580.192024]   .nr_load_updates               : 130936
[  580.192024]   .nr_uninterruptible            : 0
[  580.192024]   .next_balance                  : 4295.247917
[  580.192024]   .curr->pid                     : 1295
[  580.192024]   .clock                         : 580557.002284
[  580.192024]   .cpu_load[0]                   : 2048
[  580.192024]   .cpu_load[1]                   : 1520
[  580.192024]   .cpu_load[2]                   : 1679
[  580.192024]   .cpu_load[3]                   : 1513
[  580.192024]   .cpu_load[4]                   : 1688
[  580.192024]   .yld_count                     : 124
[  580.192024]   .sched_switch                  : 0
[  580.192024]   .sched_count                   : 54526
[  580.192024]   .sched_goidle                  : 6063
[  580.192024]   .avg_idle                      : 1000000
[  580.192024]   .ttwu_count                    : 9145
[  580.192024]   .ttwu_local                    : 5902
[  580.192024]   .bkl_count                     : 0
[  580.192024] 
[  580.192024] cfs_rq[1]:/
[  580.192024]   .exec_clock                    : 122340.374690
[  580.192024]   .MIN_vruntime                  : 51807.120538
[  580.192024]   .min_vruntime                  : 51807.120538
[  580.192024]   .max_vruntime                  : 51807.120538
[  580.192024]   .spread                        : 0.000000
[  580.192024]   .spread0                       : 6114.578855
[  580.192024]   .nr_running                    : 2
[  580.192024]   .load                          : 2048
[  580.192024]   .nr_spread_over                : 1
[  580.192024]   .shares                        : 0
[  580.192024] 
[  580.192024] rt_rq[1]:/
[  580.192024]   .rt_nr_running                 : 0
[  580.192024]   .rt_throttled                  : 0
[  580.192024]   .rt_time                       : 0.000000
[  580.192024]   .rt_runtime                    : 950.000000
[  580.192024] 
[  580.192024] runnable tasks:
[  580.192024]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[  580.192024] ----------------------------------------------------------------------------------------------------------
[  580.192024]      kworker/1:1    30     51798.120538      3390   120     51798.120538        14.488166    578377.071351 /
[  580.192024] Rhald-addon-inpu  1295     52383.947330      3612   120     52388.948353     21427.078504    454223.044707 /
[  580.192024]             sshd  1494     51807.120538      4985   120     51807.120538     41792.344148     43008.912088 /
[  580.192024] 
[  580.192024] cpu#2, 2826.528 MHz
[  580.192024]   .nr_running                    : 3
[  580.192024]   .load                          : 3072
[  580.192024]   .nr_switches                   : 38687
[  580.192024]   .nr_load_updates               : 128857
[  580.192024]   .nr_uninterruptible            : 0
[  580.192024]   .next_balance                  : 4295.248178
[  580.192024]   .curr->pid                     : 1002
[  580.192024]   .clock                         : 580830.001334
[  580.192024]   .cpu_load[0]                   : 3072
[  580.192024]   .cpu_load[1]                   : 2688
[  580.192024]   .cpu_load[2]                   : 2231
[  580.192024]   .cpu_load[3]                   : 2408
[  580.192024]   .cpu_load[4]                   : 2606
[  580.192024]   .yld_count                     : 0
[  580.192024]   .sched_switch                  : 0
[  580.192024]   .sched_count                   : 49977
[  580.192024]   .sched_goidle                  : 4442
[  580.192024]   .avg_idle                      : 1000000
[  580.192024]   .ttwu_count                    : 7958
[  580.192024]   .ttwu_local                    : 5710
[  580.192024]   .bkl_count                     : 0
[  580.192024] 
[  580.192024] cfs_rq[2]:/
[  580.192024]   .exec_clock                    : 122185.543310
[  580.192024]   .MIN_vruntime                  : 49939.236793
[  580.192024]   .min_vruntime                  : 49948.236793
[  580.192024]   .max_vruntime                  : 49939.236793
[  580.192024]   .spread                        : 0.000000
[  580.192024]   .spread0                       : 4255.695110
[  580.192024]   .nr_running                    : 3
[  580.192024]   .load                          : 3072
[  580.192024]   .nr_spread_over                : 5
[  580.192024]   .shares                        : 0
[  580.192024] 
[  580.192024] rt_rq[2]:/
[  580.192024]   .rt_nr_running                 : 0
[  580.192024]   .rt_throttled                  : 0
[  580.192024]   .rt_time                       : 0.000000
[  580.192024]   .rt_runtime                    : 950.000000
[  580.192024] 
[  580.192024] runnable tasks:
[  580.192024]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[  580.192024] ----------------------------------------------------------------------------------------------------------
[  580.192024]      kworker/2:1    31     49939.236793      3110   120     49939.236793        16.244410    577598.865226 /
[  580.192024]          kswapd0    33     49939.236793      5021   120     49939.236793     39855.128906    456899.562827 /
[  580.192024] R     irqbalance  1002     50700.231326     10599   120     50705.232536     37995.007739    451842.051677 /
[  580.192024] 
[  580.192024] cpu#3, 2826.528 MHz
[  580.192024]   .nr_running                    : 2
[  580.192024]   .load                          : 2048
[  580.192024]   .nr_switches                   : 28514
[  580.192024]   .nr_load_updates               : 142983
[  580.192024]   .nr_uninterruptible            : 0
[  580.192024]   .next_balance                  : 4295.248441
[  580.192024]   .curr->pid                     : 1517
[  580.192024]   .clock                         : 581105.001367
[  580.192024]   .cpu_load[0]                   : 2048
[  580.192024]   .cpu_load[1]                   : 2048
[  580.192024]   .cpu_load[2]                   : 6702
[  580.192024]   .cpu_load[3]                   : 6746
[  580.192024]   .cpu_load[4]                   : 5982
[  580.192024]   .yld_count                     : 179
[  580.192024]   .sched_switch                  : 0
[  580.192024]   .sched_count                   : 38579
[  580.192024]   .sched_goidle                  : 5981
[  580.192024]   .avg_idle                      : 1000000
[  580.192024]   .ttwu_count                    : 8881
[  580.192024]   .ttwu_local                    : 7007
[  580.192024]   .bkl_count                     : 0
[  580.192024] 
[  580.192024] cfs_rq[3]:/
[  580.192024]   .exec_clock                    : 135810.747600
[  580.192024]   .MIN_vruntime                  : 64636.582469
[  580.192024]   .min_vruntime                  : 64645.582469
[  580.192024]   .max_vruntime                  : 64636.582469
[  580.192024]   .spread                        : 0.000000
[  580.192024]   .spread0                       : 18953.040786
[  580.192024]   .nr_running                    : 3
[  580.192024]   .load                          : 8148
[  580.192024]   .nr_spread_over                : 4
[  580.192024]   .shares                        : 0
[  580.192024] 
[  580.192024] rt_rq[3]:/
[  580.192024]   .rt_nr_running                 : 0
[  580.192024]   .rt_throttled                  : 0
[  580.192024]   .rt_time                       : 0.000000
[  580.192024]   .rt_runtime                    : 950.000000
[  580.192024] 
[  580.192024] runnable tasks:
[  580.192024]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[  580.192024] ----------------------------------------------------------------------------------------------------------
[  580.192024]      kworker/3:1    32     64636.582469      4854   120     64636.582469       856.962108    576060.366837 /
[  580.192024]          audispd   952     64636.582469        96   112     64636.582469      7948.252669    553967.243338 /
[  580.192024] R          oom01  1517     65744.576906        64   120     65748.577669     11613.730238         0.000000 /
[  580.192024] 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
