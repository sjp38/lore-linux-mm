Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C5B06B0253
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 00:10:43 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id q6so699156pff.16
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:10:43 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p9sor4101428pge.28.2018.01.10.21.10.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 21:10:42 -0800 (PST)
Date: Thu, 11 Jan 2018 14:10:36 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180111051036.GB494@jagdpanzerIV>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110162900.GA21753@linux.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110162900.GA21753@linux.suse>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Tejun Heo <tj@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/10/18 17:29), Petr Mladek wrote:
[..]
> The next versions used lazy offload from console_unlock() when
> the thread spent there too much time. IMHO, this is one
> very promising solution. It guarantees that softlockup
> would never happen. But it tries hard to get the messages
> out immediately.

a small addition. my motivation was not exactly the "lazy offload",
but to keep the existing printk behavior as long as possible. and
that "as long as possible" is determined by watchdog threshold, which
is the only limit we must care about. as long as printing task spends
more than 1/2 of watchdog threshold - we offload. otherwise we don't
mess up with the existing logic/guarantees/etc.

there is also a bunch of other things in the patch now. but nothing
fantastically complex.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
