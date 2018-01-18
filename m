Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 389AC6B0069
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 23:31:25 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id i1so13329028pgv.22
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 20:31:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q5sor2162726pll.2.2018.01.17.20.31.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 20:31:24 -0800 (PST)
Date: Thu, 18 Jan 2018 13:31:16 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180118043116.GA6529@jagdpanzerIV>
References: <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180113072834.GA1701@tigerII.localdomain>
 <20180115070637.1915ac20@gandalf.local.home>
 <20180115144530.pej3k3xmkybjr6zb@pathway.suse.cz>
 <20180116022349.GD6607@jagdpanzerIV>
 <20180116044716.GE6607@jagdpanzerIV>
 <20180116104508.515ca393@gandalf.local.home>
 <20180117021856.GA423@jagdpanzerIV>
 <20180117130407.unwy6noeorzretvn@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180117130407.unwy6noeorzretvn@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/17/18 14:04), Petr Mladek wrote:
> On Wed 2018-01-17 11:18:56, Sergey Senozhatsky wrote:
> > On (01/16/18 10:45), Steven Rostedt wrote:
> > [..]
> > > > [1] https://marc.info/?l=linux-mm&m=145692016122716
> > > 
> > > Especially since Konstantin is working on pulling in all LKML archives,
> > > the above should be denoted as:
> > > 
> > >  Link: http://lkml.kernel.org/r/201603022101.CAH73907.OVOOMFHFFtQJSL%20()%20I-love%20!%20SAKURA%20!%20ne%20!%20jp
> > 
> > hm, may I ask why? is there a new rule now to percent-encode commit messages?
> 
> IMHO, the most important thing is that Steven's link is based
> on the Message-ID and the stable redirector
> https://lkml.kernel.org/. It has a better chance to work
> even in the future.

d'oh... indeed, I copy-pasted the wrong URL... it should
have been lkml.kernel.org/r/ [and it actually was].

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
