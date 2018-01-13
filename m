Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 89CA86B0253
	for <linux-mm@kvack.org>; Sat, 13 Jan 2018 02:31:05 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id p17so6675289pfh.18
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 23:31:05 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f4sor7806615plb.116.2018.01.12.23.31.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jan 2018 23:31:04 -0800 (PST)
Date: Sat, 13 Jan 2018 16:31:00 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180113073100.GB1701@tigerII.localdomain>
References: <20180110130517.6ff91716@vmware.local.home>
 <20180111045817.GA494@jagdpanzerIV>
 <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180112125536.GC24497@linux.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180112125536.GC24497@linux.suse>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/12/18 13:55), Petr Mladek wrote:
[..]
> > I'm not fixing console_unlock(), I'm fixing printk(). BTW, all my
> > kernels are CONFIG_PREEMPT (I'm a RT guy), my mind thinks more about
> > PREEMPT kernels than !PREEMPT ones.
> 
> I would say that the patch improves also console_unlock() but only in
> non-preemttive context.
> 
> By other words, it makes console_unlock() finite in preemptible context
> (limited by buffer size). It might still be unlimited in
> non-preemtible context.

could you elaborate a bit?

[..]
> > > reverting 6b97a20d3a7909daa06625d4440c2c52d7bf08d7 may be the right
> > > thing after all.
> > 
> > I would analyze that more before doing so. Because with my patch, I
> > think we make those that can do long prints (without triggering a
> > watchdog), the ones most likely doing the long prints.
> 
> IMHO, it might make sense because it would help to see the messages
> faster. But I would prefer to handle this separately because it
> might also increase the risk of softlockups. Therefore it might
> cause regressions.
> 
> We should also take into account the commit 8d91f8b15361dfb438ab6
> ("printk: do cond_resched() between lines while outputting to
> consoles"). It has the same effect for console_lock() callers.

I replied in another email.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
