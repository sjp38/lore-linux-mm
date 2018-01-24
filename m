Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 287F2800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 13:46:11 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id h13so7354788qtj.1
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 10:46:11 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b190sor675635qka.152.2018.01.24.10.46.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jan 2018 10:46:10 -0800 (PST)
Date: Wed, 24 Jan 2018 10:46:06 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180124184606.GA17457@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110162900.GA21753@linux.suse>
 <20180110170223.GF3668920@devbig577.frc2.facebook.com>
 <20180124093607.GK2269@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180124093607.GK2269@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Petr Mladek <pmladek@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, akpm@linux-foundation.org, Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hello, Peter.

On Wed, Jan 24, 2018 at 10:36:07AM +0100, Peter Zijlstra wrote:
> On Wed, Jan 10, 2018 at 09:02:23AM -0800, Tejun Heo wrote:
> > 1. Console is IPMI emulated serial console.  Super slow.  Also
> >    netconsole is in use.
> 
> So my IPMI SoE typically run at 115200 Baud (or higher) and I've not had
> trouble like that (granted I don't typically trigger OOM storms, but
> they do occasionally happen).
> 
> Is your IPMI much slower and not fixable to be faster?

It looks like the latest machines have the baud rate at 57600 and I'm
pretty sure we have a lot of slower ones.  57600 isn't 9600 but is
still slow enough to get into trouble often enough.  There are a huge
number of machines running all sorts of things under heavy load and
trying to rapidly deploy new kernels / features contributes to
encountering bugs and weird corner cases.

UART can run a lot faster and I have no idea why IPMI consoles behave
as if they were connected over mile-long DB9 cables.  Maybe we can
convince hardware people to improve it but, even if that happened
today, we'd still be looking at years of dealing with slower ones, and
IPMI situation here is likely better than what many others are facing.

idk, it's not a particularly difficult problem to solve from kernel
side.  Just need to figure out a better / more robust trade-off.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
