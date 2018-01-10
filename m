Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFAB6B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 14:06:01 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id d125so58003qkb.8
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 11:06:01 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v47sor12044684qtj.37.2018.01.10.11.06.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 11:06:00 -0800 (PST)
Date: Wed, 10 Jan 2018 11:05:57 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110190557.GA3460072@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110162900.GA21753@linux.suse>
 <20180110170223.GF3668920@devbig577.frc2.facebook.com>
 <20180110182153.GP6176@hirez.programming.kicks-ass.net>
 <20180110183055.GM3668920@devbig577.frc2.facebook.com>
 <20180110184144.GR6176@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110184144.GR6176@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Petr Mladek <pmladek@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, akpm@linux-foundation.org, Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hello,

On Wed, Jan 10, 2018 at 07:41:44PM +0100, Peter Zijlstra wrote:
> Typically we (scheduler) have removed printk()s (on boot) when BIGSMP
> folks say it creates boot pain. Much of it is now behind the sched_debug
> parameter, others are compressed.
> 
> I've also seen other people reduce printk()s.
> 
> In general reducing printk() is a good thing, its a low bandwidth
> channel for critical stuff like OOPSen and the like.

Yeah, sure, no disagreement there.  It's just that this is a provision
for when that breaks down.  In the described scenario, it's also not
caused by any particular one printing too many messages.  OOM is just
printing OOM info and packet tx is just printing standard alloc failed
message (and some other following errors).  It's the feedback loop
which kills the machine.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
