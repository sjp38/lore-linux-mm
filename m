Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D916B6B0292
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:45:00 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id q185so13489396qke.2
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 11:45:00 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s66sor2124960qkc.162.2018.01.16.11.45.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 11:45:00 -0800 (PST)
Date: Tue, 16 Jan 2018 11:44:56 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180116194456.GS3460072@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110130517.6ff91716@vmware.local.home>
 <20180111045817.GA494@jagdpanzerIV>
 <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180111203057.5b1a8f8f@gandalf.local.home>
 <20180111215547.2f66a23a@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180111215547.2f66a23a@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hello, Steven.

On Thu, Jan 11, 2018 at 09:55:47PM -0500, Steven Rostedt wrote:
> All I did was start off a work queue on each CPU, and each CPU does one
> printk() followed by a millisecond sleep. No 10,000 printks, nothing
> in an interrupt handler. Preemption is disabled while the printk
> happens, but that's normal.
> 
> This is much closer to an OOM happening all over the system, where OOMs
> stack dumps are occurring on different CPUS.

OOMs can't happen all over the system.  It can only happen on a single
CPU at a time.  If you're printing from multiple CPUs, your solution
would work great.  That is the situation your patches are designed to
address to begin with.  That isn't the problem that I reported tho.  I
understand that your solution works for that class of problems and
that is great.  I really wish that it could address the other class of
problems too tho, and it doesn't seem like it would be that difficult
to cover both cases, right?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
