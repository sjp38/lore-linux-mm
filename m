Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 33A6D6B0069
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 13:42:15 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id n62so342552iod.17
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 10:42:15 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id u11si11691765iou.230.2018.01.10.10.42.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 10 Jan 2018 10:42:14 -0800 (PST)
Date: Wed, 10 Jan 2018 19:41:44 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110184144.GR6176@hirez.programming.kicks-ass.net>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110162900.GA21753@linux.suse>
 <20180110170223.GF3668920@devbig577.frc2.facebook.com>
 <20180110182153.GP6176@hirez.programming.kicks-ass.net>
 <20180110183055.GM3668920@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110183055.GM3668920@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Petr Mladek <pmladek@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, akpm@linux-foundation.org, Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed, Jan 10, 2018 at 10:30:55AM -0800, Tejun Heo wrote:
> > Why not kill recursive OOM (msgs) ?
> 
> Sure, we can do that too, e.g. marking flushing thread and ignoring
> new messages from it, although that does come with its own downsides.

Typically we (scheduler) have removed printk()s (on boot) when BIGSMP
folks say it creates boot pain. Much of it is now behind the sched_debug
parameter, others are compressed.

I've also seen other people reduce printk()s.

In general reducing printk() is a good thing, its a low bandwidth
channel for critical stuff like OOPSen and the like.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
