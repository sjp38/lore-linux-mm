Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id DFB086B06F5
	for <linux-mm@kvack.org>; Sat, 12 May 2018 17:50:49 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id d9-v6so7444799plj.4
        for <linux-mm@kvack.org>; Sat, 12 May 2018 14:50:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b185-v6sor2372986pgc.146.2018.05.12.14.50.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 12 May 2018 14:50:17 -0700 (PDT)
Date: Sat, 12 May 2018 14:52:22 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: BUG: workqueue lockup (2)
Message-ID: <20180512215222.GC817@sol.localdomain>
References: <94eb2c03c9bc75aff2055f70734c@google.com>
 <001a113f711a528a3f0560b08e76@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <001a113f711a528a3f0560b08e76@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+e38be687a2450270a3b593bacb6b5795a7a74edb@syzkaller.appspotmail.com>
Cc: dvyukov@google.com, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penguin-kernel@I-love.SAKURA.ne.jp, pombredanne@nexb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de

On Tue, Dec 19, 2017 at 04:25:01AM -0800, syzbot wrote:
> syzkaller has found reproducer for the following crash on
> f3b5ad89de16f5d42e8ad36fbdf85f705c1ae051
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
>   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
>     pending: cache_reap
> workqueue events_power_efficient: flags=0x80
>   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
>     pending: neigh_periodic_work, do_cache_clean
> workqueue mm_percpu_wq: flags=0x8
>   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
>     pending: vmstat_update
> workqueue kblockd: flags=0x18
>   pwq 3: cpus=1 node=0 flags=0x0 nice=-20 active=1/256
>     pending: blk_timeout_work
> 

The bug that this reproducer reproduces was fixed a while ago by commit
966031f340185e, so I'm marking this bug report fixed by it:

#syz fix: n_tty: fix EXTPROC vs ICANON interaction with TIOCINQ (aka FIONREAD)

Note that the error message was not always "BUG: workqueue lockup"; it was also
sometimes like "watchdog: BUG: soft lockup - CPU#5 stuck for 22s!".

syzbot still is hitting the "BUG: workqueue lockup" error sometimes, but it must
be for other reasons.  None has a reproducer currently.

- Eric
