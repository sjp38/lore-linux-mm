Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D59DB6B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 23:13:22 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 15so5492869pgc.21
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 20:13:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z4sor2394787plo.98.2017.11.03.20.13.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Nov 2017 20:13:20 -0700 (PDT)
Date: Sat, 4 Nov 2017 12:13:13 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v3] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171104031313.GA539@tigerII.localdomain>
References: <20171102134515.6eef16de@gandalf.local.home>
 <82a3df5e-c8ad-dc41-8739-247e5034de29@suse.cz>
 <20171102231507.18f6b3b6@vmware.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171102231507.18f6b3b6@vmware.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On (11/02/17 23:15), Steven Rostedt wrote:
> On Thu, 2 Nov 2017 23:16:16 +0100
> Vlastimil Babka <vbabka@suse.cz> wrote:
> 
> > > +			if (spin) {
> > > +				/* We spin waiting for the owner to release us */
> > > +				spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
> > > +				/* Owner will clear console_waiter on hand off */
> > > +				while (!READ_ONCE(console_waiter))  
> > 
> > This should not be negated, right? We should spin while it's true, not
> > false.
> 
> Ug, yes. How did that not crash in my tests.

Ah, right... Good catch, Vlastimil. The V1 didn't work as expected
on my tests.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
