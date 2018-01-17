Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 97DE6280263
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 21:19:03 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e185so12934499pfg.23
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 18:19:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor205873pgq.176.2018.01.16.18.19.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 18:19:02 -0800 (PST)
Date: Wed, 17 Jan 2018 11:18:56 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180117021856.GA423@jagdpanzerIV>
References: <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180113072834.GA1701@tigerII.localdomain>
 <20180115070637.1915ac20@gandalf.local.home>
 <20180115144530.pej3k3xmkybjr6zb@pathway.suse.cz>
 <20180116022349.GD6607@jagdpanzerIV>
 <20180116044716.GE6607@jagdpanzerIV>
 <20180116104508.515ca393@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180116104508.515ca393@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/16/18 10:45), Steven Rostedt wrote:
[..]
> > [1] https://marc.info/?l=linux-mm&m=145692016122716
> 
> Especially since Konstantin is working on pulling in all LKML archives,
> the above should be denoted as:
> 
>  Link: http://lkml.kernel.org/r/201603022101.CAH73907.OVOOMFHFFtQJSL%20()%20I-love%20!%20SAKURA%20!%20ne%20!%20jp

hm, may I ask why? is there a new rule now to percent-encode commit messages?

> Although the above is for linux-mm and not LKML (it still works), I
> should ask Konstantin if he will be pulling in any of the other
> archives. Perhaps have both? (in case marc.info goes away).
> 
> > Fixes: 6b97a20d3a79 ("printk: set may_schedule for some of console_trylock() callers")
> 
> Should we Cc stable@vger.kernel.org?

that's a good question... maybe yes, maybe no... I'd say this
change is "safer" when we have hand-off.

> Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
> 
> Thanks Sergey!

thanks.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
