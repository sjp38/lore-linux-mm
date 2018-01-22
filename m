Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 19E0B800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 05:36:18 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id b4so8388466pgs.5
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 02:36:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k14sor3007738pgt.294.2018.01.22.02.36.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 02:36:17 -0800 (PST)
Date: Mon, 22 Jan 2018 19:36:11 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180122103611.GD403@jagdpanzerIV>
References: <20180117151509.GT3460072@devbig577.frc2.facebook.com>
 <20180117121251.7283a56e@gandalf.local.home>
 <20180117134201.0a9cbbbf@gandalf.local.home>
 <20180119132052.02b89626@gandalf.local.home>
 <20180120071402.GB8371@jagdpanzerIV>
 <20180120104931.1942483e@gandalf.local.home>
 <20180121141521.GA429@tigerII.localdomain>
 <20180121160441.7ea4b6d9@gandalf.local.home>
 <20180122085632.GA403@jagdpanzerIV>
 <20180122102857.GC403@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180122102857.GC403@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, Petr Mladek <pmladek@suse.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/22/18 19:28), Sergey Senozhatsky wrote:
> On (01/22/18 17:56), Sergey Senozhatsky wrote:
> [..]
> > Assume the following,
> 
> But more importantly we are missing another huge thing - console_unlock().

IOW, not every console_unlock() is from vprintk_emit(). We can have
console_trylock() -> console_unlock() being from non-preemptible context,
etc. And then irq work to flush printk_safe -> printk_deferred all the time.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
