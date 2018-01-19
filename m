Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6946B0038
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 19:20:29 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id i1so16394356pgv.22
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 16:20:29 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d8si7369921pgu.184.2018.01.18.16.20.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 16:20:27 -0800 (PST)
Date: Thu, 18 Jan 2018 19:20:23 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 1/2] printk: Add console owner and waiter logic to
 load balance console writes
Message-ID: <20180118192023.1c29abbb@gandalf.local.home>
In-Reply-To: <20180118220323.GC17196@amd>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110132418.7080-2-pmladek@suse.com>
	<20180112115454.17c03c8f@gandalf.local.home>
	<20180118220323.GC17196@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org

On Thu, 18 Jan 2018 23:03:24 +0100
Pavel Machek <pavel@ucw.cz> wrote:


> > To demonstrate the issue, this module has been shown to lock up a
> > system with 4 CPUs and a slow console (like a serial console). It is
> > also able to lock up a 8 CPU system with only a fast (VGA) console, by
> > passing in "loops=100". The changes in this commit prevent this module
> > from locking up the system.
> > 
> > #include <linux/module.h>
> > #include <linux/delay.h>
> > #include <linux/sched.h>
> > #include <linux/mutex.h>
> > #include <linux/workqueue.h>
> > #include <linux/hrtimer.h>  
> 
> Programs in commit messages. Not preffered way to distribute code, I'd
> say. What about putting it into kernel selftests directory or
> something like that?

It's not really a program, but a module. I could add a real module that
can test this, and people can modprobe it if they want to make sure
there's no regressions.

I can send a patch.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
