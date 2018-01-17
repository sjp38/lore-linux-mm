Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C3FA828029C
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 08:04:18 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id 194so4104532wmv.9
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 05:04:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t12si4329368wra.453.2018.01.17.05.04.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Jan 2018 05:04:16 -0800 (PST)
Date: Wed, 17 Jan 2018 14:04:07 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180117130407.unwy6noeorzretvn@pathway.suse.cz>
References: <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180113072834.GA1701@tigerII.localdomain>
 <20180115070637.1915ac20@gandalf.local.home>
 <20180115144530.pej3k3xmkybjr6zb@pathway.suse.cz>
 <20180116022349.GD6607@jagdpanzerIV>
 <20180116044716.GE6607@jagdpanzerIV>
 <20180116104508.515ca393@gandalf.local.home>
 <20180117021856.GA423@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180117021856.GA423@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed 2018-01-17 11:18:56, Sergey Senozhatsky wrote:
> On (01/16/18 10:45), Steven Rostedt wrote:
> [..]
> > > [1] https://marc.info/?l=linux-mm&m=145692016122716
> > 
> > Especially since Konstantin is working on pulling in all LKML archives,
> > the above should be denoted as:
> > 
> >  Link: http://lkml.kernel.org/r/201603022101.CAH73907.OVOOMFHFFtQJSL%20()%20I-love%20!%20SAKURA%20!%20ne%20!%20jp
> 
> hm, may I ask why? is there a new rule now to percent-encode commit messages?

IMHO, the most important thing is that Steven's link is based
on the Message-ID and the stable redirector
https://lkml.kernel.org/. It has a better chance to work
even in the future.

I have been asked by other people to use this type
of links as well.

> > Although the above is for linux-mm and not LKML (it still works), I
> > should ask Konstantin if he will be pulling in any of the other
> > archives. Perhaps have both? (in case marc.info goes away).
> > 
> > > Fixes: 6b97a20d3a79 ("printk: set may_schedule for some of console_trylock() callers")
> > 
> > Should we Cc stable@vger.kernel.org?
> 
> that's a good question... maybe yes, maybe no... I'd say this
> change is "safer" when we have hand-off.

I would keep it as is in stable kernels unless there are
many bug reports.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
