Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3E0D76B0253
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 23:51:37 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z12so8695745pgv.6
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 20:51:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9sor261870pge.152.2018.01.15.20.51.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jan 2018 20:51:36 -0800 (PST)
Date: Tue, 16 Jan 2018 13:51:31 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180116045131.GF6607@jagdpanzerIV>
References: <20180111045817.GA494@jagdpanzerIV>
 <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180112125536.GC24497@linux.suse>
 <20180115070821.40f044d6@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180115070821.40f044d6@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/15/18 07:08), Steven Rostedt wrote:
> On Fri, 12 Jan 2018 13:55:37 +0100
> Petr Mladek <pmladek@suse.com> wrote:
> 
> > > I'm not fixing console_unlock(), I'm fixing printk(). BTW, all my
> > > kernels are CONFIG_PREEMPT (I'm a RT guy), my mind thinks more about
> > > PREEMPT kernels than !PREEMPT ones.  
> > 
> > I would say that the patch improves also console_unlock() but only in
> > non-preemttive context.
> > 
> > By other words, it makes console_unlock() finite in preemptible context
> > (limited by buffer size). It might still be unlimited in
> > non-preemtible context.
> 
> Since I'm worried most about printk(), I would argue to make printk
> console unlock always non-preempt.

+1


// The next stop is "victims of O(logbuf) memorial" station :)

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
