Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id C331A6B0038
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 00:23:07 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id w23so1136781plk.5
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 21:23:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r16sor291079pfh.69.2018.01.15.21.23.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jan 2018 21:23:06 -0800 (PST)
Date: Tue, 16 Jan 2018 14:23:01 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180116052301.GC13731@jagdpanzerIV>
References: <20180111045817.GA494@jagdpanzerIV>
 <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180113072834.GA1701@tigerII.localdomain>
 <20180115101743.qh5whicsn6hmac32@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180115101743.qh5whicsn6hmac32@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hi,

On (01/15/18 11:17), Petr Mladek wrote:
> Hi Sergey,
> 
> I wonder if there is still some miss understanding.
> 
> Steven and me are trying to get this patch in because we believe
> that it is a step forward. We know that it is not perfect. But
> we believe that it makes things better. In particular, it limits
> the time spent in console_unlock() in atomic context. It does
> not make it worse in preemptible context.
> 
> It does not block further improvements, including offloading
> to the kthread. We will happily discuss and review further
> improvements, it they prove to be necessary.
> 
> The advantage of this approach is that it is incremental. It should
> be easier for review and analyzing possible regressions.
> 
> What is the aim of your mails, please?
> Do you want to say that this patch might cause regressions?
> Or do you want to say that it does not solve all scenarios?
> 
> Please, answer the above questions. I am still confused.

I ACK-ed the patch set, given that I hope that we at least will
do (a)

a) remove preemption out of printk()->user critical path


---

b) the next thing would be - O(logbuf) is not a good boundary

c) the thing after that would be to - O(logbuf) boundary can be
   broken in both preemptible and non-preemptible contexts.

but (b) and (c) can wait.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
