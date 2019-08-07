Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49DDDC19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 05:16:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1EFC217D7
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 05:16:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1EFC217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BD466B0003; Wed,  7 Aug 2019 01:16:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16DF46B0006; Wed,  7 Aug 2019 01:16:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05D8F6B0007; Wed,  7 Aug 2019 01:16:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0B776B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 01:16:44 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id t2so49738283plo.10
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 22:16:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=OjJ6Du/VJDETUn+UNHoNU9WbIhDh/m4bqFkpr765O90=;
        b=JwambafOvl+Pv0k0+lXMzB/cnNJT2ys+5nnZKOcTBwjvgZTyvKk8RECcyxlsBO4cC+
         xjptR0HL3M985qeUSssxJGYgoRfq5PLjVOheX1IQGs+a0NQzmOWRGiAL84j5t84iDoAO
         879ucvZIDwhS46fTk4yApyz3b/ZDerJgdN07f7TRMp5PCqNDJuynhM5MtDLx1ekOCqHI
         Eg0R1BLKhnDBoJsu2TVMTrtAldctGmH5aGn4ofaf43ChaKWW+cgDG9AH+8NFr8h2Rqas
         05GBIoAOUUoAxjuBPOsblSR+uvwiJl0ggGA5GPqVsJ+UEiDc2M9V6otfLVyTsIdroytV
         WBow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAXddGI/XN6TjUxGrMZosxOdYPK7HlzriWHFcO0yhxidHaSdtLbw
	VBg8+3pdZ9TXAarAITXSLsRHrnMcBxVazjyZT/oeMs+rgpwmaJFkd5MkW6EeBAMHi8flzPo0sGZ
	u3DZvPzdsQGTHUPRNYCg5gOHHKipXACnvydXZw9FlT9yf4c63xDtpSZr1dTVc1t2XTw==
X-Received: by 2002:a63:31cc:: with SMTP id x195mr6065147pgx.147.1565155004303;
        Tue, 06 Aug 2019 22:16:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxei8gMO1370p08Pfbr30JLPL9f+uMpk5ZeWoNYxC+HF39v5YZqR9Irc6draAOOlaJQ0fQ5
X-Received: by 2002:a63:31cc:: with SMTP id x195mr6065080pgx.147.1565155002723;
        Tue, 06 Aug 2019 22:16:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565155002; cv=none;
        d=google.com; s=arc-20160816;
        b=0kUuT4BOliYCf1OBVqdmzXjLa2lJAaj2GOnhpmTFW12mOgWhJ/F1girLQ2/AoNNJN/
         Wvf9MmG3ZrWPAuoD78zWIC3cvaD7Vrkg1A0v9vg38Gk4HnvIX6Wbiuhqd1IqiODr0pGt
         pVytWWs3PNC7i1413vzyKNIZec/ve5tIfYgTSqLw0Y63fA5xVx1erRdv+wdVhatnDoQh
         l0Txubc8iL4DeAea6prPnAmSDYvJACBq0gvj6X2r42h9BxnE9ZDl44S8t97BUQnVxqSB
         PXQSHoHpGBbtzwyohJUqW6eJIHrmDSb0jaRaeSOm4kMOHZ/zVkzkjaAmMNZOHose0F6e
         CqMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=OjJ6Du/VJDETUn+UNHoNU9WbIhDh/m4bqFkpr765O90=;
        b=GQSz4ZbXiSmHB2Q++JhP4tqzErHmkL+dg6fx7lFuHbMMzG4DFQohk/EOYtqzbvnnON
         ksyT0wGvwoTo01b3oBe13u3hdT1UTfaZ8ptiXo6v/lamr1bNzkNlTX12kKIucX/5wlHA
         UzFNTFhxyHY6FK4VVhaXqnI5BDwxP1D7drMAij+Rx5S4wLFs+BONTgasbBaIzmbEbhJO
         h37KrbECavQo48gJPFNHxYt4X/YikMt36NQRljq9pyjF1uTCSM3+hbD/Ox3pCMWP1eHA
         IO36jSTFxfeANLqNvamyTdM5yDVZesakHkGZZXsuZ+oDPHII8s3Y2EY0jneefOwaTRBP
         Fufg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from smtp-97-32.mail.sina.com.cn (mail3-165.sinamail.sina.com.cn. [202.108.3.165])
        by mx.google.com with SMTP id s9si43159020plr.146.2019.08.06.22.16.42
        for <linux-mm@kvack.org>;
        Tue, 06 Aug 2019 22:16:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) client-ip=202.108.3.165;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([114.253.230.179])
	by sina.com with ESMTP
	id 5D4A5EB700022F23; Wed, 7 Aug 2019 13:16:40 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 959209715101
From: Hillf Danton <hdanton@sina.com>
To: syzbot <syzbot+370e4739fa489334a4ef@syzkaller.appspotmail.com>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	syzkaller-bugs@googlegroups.com
Subject: Re: WARNING in cgroup_rstat_updated
Date: Wed,  7 Aug 2019 13:16:29 +0800
Message-Id: <20190807051629.4968-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Tue, 06 Aug 2019 20:18:05 -0700 (PDT)
> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    31cc088a Merge tag 'drm-next-2019-07-19' of git://anongit...
> git tree:       net-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=102db48c600000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=4dba67bf8b8c9ad7
> dashboard link: https://syzkaller.appspot.com/bug?extid=370e4739fa489334a4ef
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=16dd57dc600000
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+370e4739fa489334a4ef@syzkaller.appspotmail.com
> 
> 8021q: adding VLAN 0 to HW filter on device batadv0
> WARNING: CPU: 1 PID: 9095 at mm/page_counter.c:62 page_counter_cancel  
> mm/page_counter.c:62 [inline]
> WARNING: CPU: 1 PID: 9095 at mm/page_counter.c:62  
> page_counter_cancel+0x5a/0x70 mm/page_counter.c:55
> Kernel panic - not syncing: panic_on_warn set ...
> Shutting down cpus with NMI
> Kernel Offset: disabled
> 
> ======================================================
> WARNING: possible circular locking dependency detected
> 5.2.0+ #67 Not tainted
> ------------------------------------------------------
> syz-executor.2/9306 is trying to acquire lock:
> 00000000e4252251 ((console_sem).lock){-.-.}, at: down_trylock+0x13/0x70  
> kernel/locking/semaphore.c:135
> 
> but task is already holding lock:
> 000000000fdb8781 (per_cpu_ptr(&cgroup_rstat_cpu_lock, cpu)){-...}, at:  
> cgroup_rstat_updated+0x115/0x2f0 kernel/cgroup/rstat.c:49
> 
> which lock already depends on the new lock.
> 
> 
> the existing dependency chain (in reverse order) is:
> 
> -> #3 (per_cpu_ptr(&cgroup_rstat_cpu_lock, cpu)){-...}:
>         __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
>         _raw_spin_lock_irqsave+0x95/0xcd kernel/locking/spinlock.c:159
>         cgroup_rstat_updated+0x115/0x2f0 kernel/cgroup/rstat.c:49
>         cgroup_base_stat_cputime_account_end.isra.0+0x1d/0x60   kernel/cgroup/rstat.c:361
>         __cgroup_account_cputime+0x9e/0xd0 kernel/cgroup/rstat.c:371
>         cgroup_account_cputime include/linux/cgroup.h:782 [inline]
>         update_curr+0x3c8/0x8d0 kernel/sched/fair.c:862
>         dequeue_entity+0x1e/0x1100 kernel/sched/fair.c:4014
>         dequeue_task_fair+0x65/0x870 kernel/sched/fair.c:5306
>         dequeue_task+0x77/0x2e0 kernel/sched/core.c:1195
>         sched_move_task+0x1fb/0x350 kernel/sched/core.c:6847
>         cpu_cgroup_attach+0x6d/0xb0 kernel/sched/core.c:6970
>         cgroup_migrate_execute+0xc56/0x1350 kernel/cgroup/cgroup.c:2524
>         cgroup_migrate+0x14f/0x1f0 kernel/cgroup/cgroup.c:2780
>         cgroup_attach_task+0x57f/0x860 kernel/cgroup/cgroup.c:2817
>         cgroup_procs_write+0x340/0x400 kernel/cgroup/cgroup.c:4777
>         cgroup_file_write+0x241/0x790 kernel/cgroup/cgroup.c:3754
>         kernfs_fop_write+0x2b8/0x480 fs/kernfs/file.c:315
>         __vfs_write+0x8a/0x110 fs/read_write.c:494
>         vfs_write+0x268/0x5d0 fs/read_write.c:558
>         ksys_write+0x14f/0x290 fs/read_write.c:611
>         __do_sys_write fs/read_write.c:623 [inline]
>         __se_sys_write fs/read_write.c:620 [inline]
>         __x64_sys_write+0x73/0xb0 fs/read_write.c:620
>         do_syscall_64+0xfd/0x6a0 arch/x86/entry/common.c:296
>         entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> -> #2 (&rq->lock){-.-.}:
>         __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
>         _raw_spin_lock+0x2f/0x40 kernel/locking/spinlock.c:151
>         rq_lock kernel/sched/sched.h:1207 [inline]
>         task_fork_fair+0x6a/0x520 kernel/sched/fair.c:9940
>         sched_fork+0x3af/0x900 kernel/sched/core.c:2783
>         copy_process+0x1b04/0x6b00 kernel/fork.c:1987
>         _do_fork+0x146/0xfa0 kernel/fork.c:2369
>         kernel_thread+0xbb/0xf0 kernel/fork.c:2456
>         rest_init+0x28/0x37b init/main.c:417
>         arch_call_rest_init+0xe/0x1b
>         start_kernel+0x912/0x951 init/main.c:785
>         x86_64_start_reservations+0x29/0x2b arch/x86/kernel/head64.c:472
>         x86_64_start_kernel+0x77/0x7b arch/x86/kernel/head64.c:453
>         secondary_startup_64+0xa4/0xb0 arch/x86/kernel/head_64.S:243
> 
> -> #1 (&p->pi_lock){-.-.}:
>         __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
>         _raw_spin_lock_irqsave+0x95/0xcd kernel/locking/spinlock.c:159
>         try_to_wake_up+0xb0/0x1aa0 kernel/sched/core.c:2432
>         wake_up_process+0x10/0x20 kernel/sched/core.c:2548
>         __up.isra.0+0x136/0x1a0 kernel/locking/semaphore.c:261
>         up+0x9c/0xe0 kernel/locking/semaphore.c:186
>         __up_console_sem+0xb7/0x1c0 kernel/printk/printk.c:244
>         console_unlock+0x695/0xf10 kernel/printk/printk.c:2481
>         vprintk_emit+0x2a0/0x700 kernel/printk/printk.c:1986
>         vprintk_default+0x28/0x30 kernel/printk/printk.c:2013
>         vprintk_func+0x7e/0x189 kernel/printk/printk_safe.c:386
>         printk+0xba/0xed kernel/printk/printk.c:2046
>         check_stack_usage kernel/exit.c:765 [inline]
>         do_exit.cold+0x18b/0x314 kernel/exit.c:927
>         do_group_exit+0x135/0x360 kernel/exit.c:981
>         __do_sys_exit_group kernel/exit.c:992 [inline]
>         __se_sys_exit_group kernel/exit.c:990 [inline]
>         __x64_sys_exit_group+0x44/0x50 kernel/exit.c:990
>         do_syscall_64+0xfd/0x6a0 arch/x86/entry/common.c:296
>         entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> -> #0 ((console_sem).lock){-.-.}:
>         check_prev_add kernel/locking/lockdep.c:2405 [inline]
>         check_prevs_add kernel/locking/lockdep.c:2507 [inline]
>         validate_chain kernel/locking/lockdep.c:2897 [inline]
>         __lock_acquire+0x25a9/0x4c30 kernel/locking/lockdep.c:3880
>         lock_acquire+0x190/0x410 kernel/locking/lockdep.c:4413
>         __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
>         _raw_spin_lock_irqsave+0x95/0xcd kernel/locking/spinlock.c:159
>         down_trylock+0x13/0x70 kernel/locking/semaphore.c:135
>         __down_trylock_console_sem+0xa8/0x210 kernel/printk/printk.c:227
>         console_trylock+0x15/0xa0 kernel/printk/printk.c:2297
>         console_trylock_spinning kernel/printk/printk.c:1706 [inline]
>         vprintk_emit+0x283/0x700 kernel/printk/printk.c:1985
>         vprintk_default+0x28/0x30 kernel/printk/printk.c:2013
>         vprintk_func+0x7e/0x189 kernel/printk/printk_safe.c:386
>         printk+0xba/0xed kernel/printk/printk.c:2046
>         kasan_die_handler arch/x86/mm/kasan_init_64.c:254 [inline]
>         kasan_die_handler.cold+0x11/0x23 arch/x86/mm/kasan_init_64.c:249
>         notifier_call_chain+0xc2/0x230 kernel/notifier.c:95
>         __atomic_notifier_call_chain+0xa6/0x1a0 kernel/notifier.c:185
>         atomic_notifier_call_chain kernel/notifier.c:195 [inline]
>         notify_die+0xfb/0x180 kernel/notifier.c:551
>         do_general_protection+0x13d/0x300 arch/x86/kernel/traps.c:558
>         general_protection+0x1e/0x30 arch/x86/entry/entry_64.S:1181
>         cgroup_rstat_updated+0x174/0x2f0 kernel/cgroup/rstat.c:64
>         cgroup_base_stat_cputime_account_end.isra.0+0x1d/0x60   kernel/cgroup/rstat.c:361
>         __cgroup_account_cputime_field+0xd3/0x130 kernel/cgroup/rstat.c:395
>         cgroup_account_cputime_field include/linux/cgroup.h:797 [inline]
>         task_group_account_field kernel/sched/cputime.c:109 [inline]
>         account_system_index_time+0x1f7/0x390 kernel/sched/cputime.c:172
>         irqtime_account_process_tick.isra.0+0x386/0x490   kernel/sched/cputime.c:389
>         account_process_tick+0x27f/0x350 kernel/sched/cputime.c:484
>         update_process_times+0x25/0x80 kernel/time/timer.c:1637
>         tick_sched_handle+0xa2/0x190 kernel/time/tick-sched.c:167
>         tick_sched_timer+0x53/0x140 kernel/time/tick-sched.c:1296
>         __run_hrtimer kernel/time/hrtimer.c:1389 [inline]
>         __hrtimer_run_queues+0x364/0xe40 kernel/time/hrtimer.c:1451
>         hrtimer_interrupt+0x314/0x770 kernel/time/hrtimer.c:1509
>         local_apic_timer_interrupt arch/x86/kernel/apic/apic.c:1068 [inline]
>         smp_apic_timer_interrupt+0x160/0x610 arch/x86/kernel/apic/apic.c:1093
>         apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:828
> 
> other info that might help us debug this:
> 
> Chain exists of:
>    (console_sem).lock --> &rq->lock --> per_cpu_ptr(&cgroup_rstat_cpu_lock, cpu)
> 
>   Possible unsafe locking scenario:
> 
>         CPU0                    CPU1
>         ----                    ----
>    lock(per_cpu_ptr(&cgroup_rstat_cpu_lock, cpu));
>                                 lock(&rq->lock);
>                                 lock(per_cpu_ptr(&cgroup_rstat_cpu_lock, cpu));
>    lock((console_sem).lock);
> 
>   *** DEADLOCK ***
> 
> 6 locks held by syz-executor.2/9306:
>   #0: 0000000032d2cedf (&sb->s_type->i_mutex_key#12){+.+.}, at: inode_lock  
> include/linux/fs.h:778 [inline]
>   #0: 0000000032d2cedf (&sb->s_type->i_mutex_key#12){+.+.}, at:  
> __sock_release+0x89/0x280 net/socket.c:589
>   #1: 000000002033d24d (sk_lock-AF_INET6){+.+.}, at: lock_sock  
> include/net/sock.h:1522 [inline]
>   #1: 000000002033d24d (sk_lock-AF_INET6){+.+.}, at: tcp_close+0x27/0x10e0  
> net/ipv4/tcp.c:2329
>   #2: 0000000067f2fc6a (rcu_read_lock){....}, at: tcp_bpf_unhash+0x0/0x390  
> net/ipv4/tcp_bpf.c:480
>   #3: 0000000067f2fc6a (rcu_read_lock){....}, at: arch_atomic64_add  
> arch/x86/include/asm/atomic64_64.h:46 [inline]
>   #3: 0000000067f2fc6a (rcu_read_lock){....}, at: atomic64_add  
> include/asm-generic/atomic-instrumented.h:873 [inline]
>   #3: 0000000067f2fc6a (rcu_read_lock){....}, at: account_group_system_time  
> include/linux/sched/cputime.h:154 [inline]
>   #3: 0000000067f2fc6a (rcu_read_lock){....}, at:  
> account_system_index_time+0xf7/0x390 kernel/sched/cputime.c:169
>   #4: 000000000fdb8781 (per_cpu_ptr(&cgroup_rstat_cpu_lock, cpu)){-...}, at:  
> cgroup_rstat_updated+0x115/0x2f0 kernel/cgroup/rstat.c:49
>   #5: 0000000067f2fc6a (rcu_read_lock){....}, at:  
> __atomic_notifier_call_chain+0x0/0x1a0 kernel/notifier.c:404
> 
> stack backtrace:
> CPU: 0 PID: 9306 Comm: syz-executor.2 Not tainted 5.2.0+ #67
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
> Google 01/01/2011
> Call Trace:
>   <IRQ>
>   __dump_stack lib/dump_stack.c:77 [inline]
>   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
>   print_circular_bug.cold+0x163/0x172 kernel/locking/lockdep.c:1617
>   check_noncircular+0x345/0x3e0 kernel/locking/lockdep.c:1741
>   check_prev_add kernel/locking/lockdep.c:2405 [inline]
>   check_prevs_add kernel/locking/lockdep.c:2507 [inline]
>   validate_chain kernel/locking/lockdep.c:2897 [inline]
>   __lock_acquire+0x25a9/0x4c30 kernel/locking/lockdep.c:3880
>   lock_acquire+0x190/0x410 kernel/locking/lockdep.c:4413
>   __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
>   _raw_spin_lock_irqsave+0x95/0xcd kernel/locking/spinlock.c:159
>   down_trylock+0x13/0x70 kernel/locking/semaphore.c:135
>   __down_trylock_console_sem+0xa8/0x210 kernel/printk/printk.c:227
>   console_trylock+0x15/0xa0 kernel/printk/printk.c:2297
>   console_trylock_spinning kernel/printk/printk.c:1706 [inline]
>   vprintk_emit+0x283/0x700 kernel/printk/printk.c:1985
>   vprintk_default+0x28/0x30 kernel/printk/printk.c:2013
>   vprintk_func+0x7e/0x189 kernel/printk/printk_safe.c:386
>   printk+0xba/0xed kernel/printk/printk.c:2046
>   kasan_die_handler arch/x86/mm/kasan_init_64.c:254 [inline]
>   kasan_die_handler.cold+0x11/0x23 arch/x86/mm/kasan_init_64.c:249
>   notifier_call_chain+0xc2/0x230 kernel/notifier.c:95
>   __atomic_notifier_call_chain+0xa6/0x1a0 kernel/notifier.c:185
>   atomic_notifier_call_chain kernel/notifier.c:195 [inline]
>   notify_die+0xfb/0x180 kernel/notifier.c:551
>   do_general_protection+0x13d/0x300 arch/x86/kernel/traps.c:558
>   general_protection+0x1e/0x30 arch/x86/entry/entry_64.S:1181
> RIP: 0010:cgroup_rstat_updated+0x174/0x2f0 kernel/cgroup/rstat.c:64
> Code: 00 fc ff df 48 8b 45 c0 48 c1 e8 03 4c 01 f8 48 89 45 c8 eb 60 e8 6c  
> e1 05 00 49 8d 7c 24 30 48 8b 55 d0 49 89 f9 49 c1 e9 03 <43> 80 3c 39 00  
> 0f 85 00 01 00 00 49 8b 7c 24 30 48 89 7a 38 49 8d
> RSP: 0018:ffff8880ae809c08 EFLAGS: 00010006
> RAX: ffff88809378a480 RBX: 0000000000000000 RCX: ffffffff8159c5ca
> RDX: ffff8880ae800000 RSI: ffffffff816ca374 RDI: 47ff8883313e8861
> RBP: ffff8880ae809c58 R08: 0000000000000004 R09: 08fff1106627d10c
> R10: ffffed1015d0136d R11: 0000000000000003 R12: 47ff8883313e8831
> R13: ffff88807b60a280 R14: ffffffff8626cbf5 R15: dffffc0000000000
>   cgroup_base_stat_cputime_account_end.isra.0+0x1d/0x60   kernel/cgroup/rstat.c:361
>   __cgroup_account_cputime_field+0xd3/0x130 kernel/cgroup/rstat.c:395
>   cgroup_account_cputime_field include/linux/cgroup.h:797 [inline]
>   task_group_account_field kernel/sched/cputime.c:109 [inline]
>   account_system_index_time+0x1f7/0x390 kernel/sched/cputime.c:172
>   irqtime_account_process_tick.isra.0+0x386/0x490 kernel/sched/cputime.c:389
>   account_process_tick+0x27f/0x350 kernel/sched/cputime.c:484
>   update_process_times+0x25/0x80 kernel/time/timer.c:1637
>   tick_sched_handle+0xa2/0x190 kernel/time/tick-sched.c:167
>   tick_sched_timer+0x53/0x140 kernel/time/tick-sched.c:1296
>   __run_hrtimer kernel/time/hrtimer.c:1389 [inline]
>   __hrtimer_run_queues+0x364/0xe40 kernel/time/hrtimer.c:1451
>   hrtimer_interrupt+0x314/0x770 kernel/time/hrtimer.c:1509
>   local_apic_timer_interrupt arch/x86/kernel/apic/apic.c:1068 [inline]
>   smp_apic_timer_interrupt+0x160/0x610 arch/x86/kernel/apic/apic.c:1093
>   apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:828
>   </IRQ>
> Rebooting in 86400 seconds..
====================================

>   general_protection+0x1e/0x30 arch/x86/entry/entry_64.S:1181
> RIP: 0010:cgroup_rstat_updated+0x174/0x2f0 kernel/cgroup/rstat.c:64

Is rcu needed to avoid the gpf above while walking up the cgroup tree?


--- a/kernel/cgroup/rstat.c
+++ b/kernel/cgroup/rstat.c
@@ -47,6 +47,7 @@ void cgroup_rstat_updated(struct cgroup
 		return;
 
 	raw_spin_lock_irqsave(cpu_lock, flags);
+	rcu_read_lock();
 
 	/* put @cgrp and all ancestors on the corresponding updated lists */
 	for (parent = cgroup_parent(cgrp); parent;
@@ -65,6 +66,7 @@ void cgroup_rstat_updated(struct cgroup
 		prstatc->updated_children = cgrp;
 	}
 
+	rcu_read_unlock();
 	raw_spin_unlock_irqrestore(cpu_lock, flags);
 }
 EXPORT_SYMBOL_GPL(cgroup_rstat_updated);
--

