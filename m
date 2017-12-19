Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 536A36B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 09:27:33 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id n6so14665481pfg.19
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 06:27:33 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u19si5121108pgn.488.2017.12.19.06.27.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 06:27:32 -0800 (PST)
Subject: Re: BUG: workqueue lockup (2)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <94eb2c03c9bc75aff2055f70734c@google.com>
	<001a113f711a528a3f0560b08e76@google.com>
In-Reply-To: <001a113f711a528a3f0560b08e76@google.com>
Message-Id: <201712192327.FIJ64026.tMQFOOVFFLHOSJ@I-love.SAKURA.ne.jp>
Date: Tue, 19 Dec 2017 23:27:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bot+e38be687a2450270a3b593bacb6b5795a7a74edb@syzkaller.appspotmail.com, syzkaller-bugs@googlegroups.com
Cc: dvyukov@google.com, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, tglx@linutronix.de

syzbot wrote:
> 
> syzkaller has found reproducer for the following crash on  
> f3b5ad89de16f5d42e8ad36fbdf85f705c1ae051

"BUG: workqueue lockup" is not a crash.

> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers
> 
> 
> BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 stuck for 37s!
> BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=-20 stuck for 32s!
> Showing busy workqueues and worker pools:
> workqueue events: flags=0x0
>    pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
>      pending: cache_reap
> workqueue events_power_efficient: flags=0x80
>    pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
>      pending: neigh_periodic_work, do_cache_clean
> workqueue mm_percpu_wq: flags=0x8
>    pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
>      pending: vmstat_update
> workqueue kblockd: flags=0x18
>    pwq 3: cpus=1 node=0 flags=0x0 nice=-20 active=1/256
>      pending: blk_timeout_work

You gave up too early. There is no hint for understanding what was going on.
While we can observe "BUG: workqueue lockup" under memory pressure, there is
no hint like SysRq-t and SysRq-m. Thus, I can't tell something is wrong.

At least you need to confirm that lockup lasts for a few minutes. Otherwise,
this might be just overstressing. (According to repro.c , 12 threads are
created and soon SEGV follows? According to above message, only 2 CPUs?
Triggering SEGV suggests memory was low due to saving coredump?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
