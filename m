Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id F01E46B0069
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 13:45:08 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a9so10719010pgf.12
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 10:45:08 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 34si12442164plm.322.2018.01.10.10.45.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 10:45:07 -0800 (PST)
Date: Wed, 10 Jan 2018 13:45:04 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110134504.37aaa032@vmware.local.home>
In-Reply-To: <20180110181459.GL3668920@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110140547.GZ3668920@devbig577.frc2.facebook.com>
	<20180110130517.6ff91716@vmware.local.home>
	<20180110181252.GK3668920@devbig577.frc2.facebook.com>
	<20180110181459.GL3668920@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed, 10 Jan 2018 10:14:59 -0800
Tejun Heo <tj@kernel.org> wrote:

> On Wed, Jan 10, 2018 at 10:12:52AM -0800, Tejun Heo wrote:
> > Hello, Steven.
> > 
> > So, everything else on your message, sure.  You do what you have to
> > do, but I really don't understand the following part, and this has
> > been the main source of frustration in the whole discussion.
> > 
> > On Wed, Jan 10, 2018 at 01:05:17PM -0500, Steven Rostedt wrote:  
> > > You on the other hand are showing unrealistic scenarios, and crying
> > > that it's what you see in production, with no proof of it.  
> > 
> > I've explained the same scenario multiple times.  Unless you're
> > assuming that I'm lying, it should be amply clear that the scenario is
> > unrealistic - we've been seeing them taking place repeatedly for quite
> > a while.  
> 
> Oops, I meant to write "not unrealistic".  Anyways, if you think I'm
> lying, please let me know.  I can ask others who have been seeing the
> issue to join the thread.

I don't believe you are lying. I believe you are interpreting one
problem as another. I don't see this is a printk bug, I see it as a
recursive OOM + net console bug. My patch is not trying to solve that,
and I don't believe it should be solved via printk.

I'm trying to solve the problem of printk spamming all CPUs causing a
single CPU to lock up. That is a real bug that has been hit in various
different scenarios, where there is no other underlying bug. This issue
is a printk problem, and my solution solves it for printk.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
