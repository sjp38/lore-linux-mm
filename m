Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB126B0253
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 13:12:56 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id f188so11945382qkb.13
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 10:12:56 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 25sor10878014qtv.48.2018.01.10.10.12.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 10:12:55 -0800 (PST)
Date: Wed, 10 Jan 2018 10:12:52 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110181252.GK3668920@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110130517.6ff91716@vmware.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110130517.6ff91716@vmware.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hello, Steven.

So, everything else on your message, sure.  You do what you have to
do, but I really don't understand the following part, and this has
been the main source of frustration in the whole discussion.

On Wed, Jan 10, 2018 at 01:05:17PM -0500, Steven Rostedt wrote:
> You on the other hand are showing unrealistic scenarios, and crying
> that it's what you see in production, with no proof of it.

I've explained the same scenario multiple times.  Unless you're
assuming that I'm lying, it should be amply clear that the scenario is
unrealistic - we've been seeing them taking place repeatedly for quite
a while.

What I don't understand is why we can't address this seemingly obvious
problem.  If there are technical reasons and the consensus is to not
solve this within flushing logic, sure, we can deal with it otherwise,
but we at least have to be able to agree that there are actual issues
here, no?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
