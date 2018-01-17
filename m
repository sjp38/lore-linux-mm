Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8288D280263
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 21:24:15 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id r28so810230pgu.1
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 18:24:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k3sor624923pgf.39.2018.01.16.18.24.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 18:24:14 -0800 (PST)
Date: Wed, 17 Jan 2018 11:24:09 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180117022409.GB423@jagdpanzerIV>
References: <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180113072834.GA1701@tigerII.localdomain>
 <20180115070637.1915ac20@gandalf.local.home>
 <20180115144530.pej3k3xmkybjr6zb@pathway.suse.cz>
 <20180116022349.GD6607@jagdpanzerIV>
 <20180116044716.GE6607@jagdpanzerIV>
 <20180116101903.iuzgln2agdr46jfy@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180116101903.iuzgln2agdr46jfy@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/16/18 11:19), Petr Mladek wrote:
[..]
> > [1] https://marc.info/?l=linux-mm&m=145692016122716
> > Fixes: 6b97a20d3a79 ("printk: set may_schedule for some of console_trylock() callers")
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> IMHO, this is a step in the right direction.
> 
> Reviewed-by: Petr Mladek <pmladek@suse.com>
> 
> I'll wait for Steven's review and push this into printk.git.
> I'll also add your Acks for the other patches.
> 
> Thanks for the patch and the various observations.

thanks!


a side note,

our console output is still largely preemptible. a typical system
acquires console_sem via console_lock() all the time, so we still
can have "where is my printk output?" cases.


for instance, my IDLE PREEMPT x86 box, has the following stats

uptime 15 min

# of console_lock() calls: 10981          // can sleep under console_sem
# of vprintk_emit() calls: 825            // cannot sleep under console_sem

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
