Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8CE6B0033
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 10:21:47 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id v25so18189719pfg.14
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 07:21:47 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n7si6150104pgv.156.2018.01.18.07.21.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 07:21:46 -0800 (PST)
Date: Thu, 18 Jan 2018 10:21:39 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 1/2] printk: Add console owner and waiter logic to
 load balance console writes
Message-ID: <20180118102139.43c04de5@gandalf.local.home>
In-Reply-To: <171cf5b9-2cb6-8e70-87f5-44ace35c2ce4@lge.com>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110132418.7080-2-pmladek@suse.com>
	<f4ea1404-404d-11d2-550c-7367add3f5fa@lge.com>
	<20180117120446.44ewafav7epaibde@pathway.suse.cz>
	<4a24ce1d-a606-3add-ec30-91ce9a1a1281@lge.com>
	<20180117211953.2403d189@vmware.local.home>
	<171cf5b9-2cb6-8e70-87f5-44ace35c2ce4@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Thu, 18 Jan 2018 13:01:46 +0900
Byungchul Park <byungchul.park@lge.com> wrote:

> > I disagree. It is like a spinlock. You can say a spinlock() that is
> > blocked is also waiting for an event. That event being the owner does a
> > spin_unlock().  
> 
> That's exactly what I was saying. Excuse me but, I don't understand
> what you want to say. Could you explain more? What do you disagree?

I guess I'm confused at what you are asking for then.


> > I find your way confusing. I'm simulating a spinlock not a wait for
> > completion. A wait for completion usually initiates something then  
> 
> I used the word, *event* instead of *completion*. wait_for_completion()
> and complete() are just an example of a pair of waiter and event.
> Lock and unlock can also be another example, too.
> 
> Important thing is that who waits and who triggers the event. Using the
> pair, we can achieve various things, for examples:
> 
>     1. Synchronization like wait_for_completion() does.
>     2. Control exclusively entering into a critical area.
>     3. Whatever.
> 
> > waits for it to complete. This is trying to get into a critical area
> > but another task is currently in it. It's simulating a spinlock as far
> > as I can see.  
> 
> Anyway it's an example of "waiter for an event, and the event".
> 
> JFYI, spinning or sleeping does not matter. Those are just methods to
> achieve a wait. I know you're not talking about this though. It's JFYI.

OK, if it is just FYI.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
