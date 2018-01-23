Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52778800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 12:22:50 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id k11so1543916qth.23
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 09:22:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a197sor12163990qkc.51.2018.01.23.09.22.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jan 2018 09:22:49 -0800 (PST)
Date: Tue, 23 Jan 2018 09:22:46 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180123172246.GG1771050@devbig577.frc2.facebook.com>
References: <20180117134201.0a9cbbbf@gandalf.local.home>
 <20180119132052.02b89626@gandalf.local.home>
 <20180120071402.GB8371@jagdpanzerIV>
 <20180120104931.1942483e@gandalf.local.home>
 <20180121141521.GA429@tigerII.localdomain>
 <20180123064023.GA492@jagdpanzerIV>
 <20180123095652.5e14da85@gandalf.local.home>
 <20180123152130.GB429@tigerII.localdomain>
 <20180123104121.2ef96d81@gandalf.local.home>
 <20180123160153.GC429@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180123160153.GC429@tigerII.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hello, Sergey.

On Wed, Jan 24, 2018 at 01:01:53AM +0900, Sergey Senozhatsky wrote:
> On (01/23/18 10:41), Steven Rostedt wrote:
> [..]
> > We can have more. But if printk is causing printks, that's a major bug.
> > And work queues are not going to fix it, it will just spread out the
> > pain. Have it be 100 printks, it needs to be fixed if it is happening.
> > And having all printks just generate more printks is not helpful. Even
> > if we slow them down. They will still never end.
> 
> Dropping the messages is not the solution either. The original bug report
> report was - this "locks up my kernel". That's it. That's all people asked
> us to solve.
> 
> With WQ we don't lockup the kernel, because we flush printk_safe in
> preemptible context. And people are very much expected to fix the
> misbehaving consoles. But that should not be printk_safe problem.

I really don't care as long as it's robust enough.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
