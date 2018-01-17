Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4AA056B0069
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 10:15:15 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id h32so9784809qtb.9
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 07:15:15 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q19sor2319616qta.61.2018.01.17.07.15.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 07:15:14 -0800 (PST)
Date: Wed, 17 Jan 2018 07:15:09 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180117151509.GT3460072@devbig577.frc2.facebook.com>
References: <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110130517.6ff91716@vmware.local.home>
 <20180111045817.GA494@jagdpanzerIV>
 <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180111203057.5b1a8f8f@gandalf.local.home>
 <20180111215547.2f66a23a@gandalf.local.home>
 <20180116194456.GS3460072@devbig577.frc2.facebook.com>
 <20180117091208.ezvuhumnsarz5thh@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180117091208.ezvuhumnsarz5thh@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hello,

On Wed, Jan 17, 2018 at 10:12:08AM +0100, Petr Mladek wrote:
> IMHO, the bad scenario with OOM was that any printk() called in
> the OOM report became console_lock owner and was responsible
> for pushing all new messages to the console. There was a possible
> livelock because OOM Killer was blocked in console_unlock() while
> other CPUs repeatedly complained about failed allocations.

I don't know why we're constantly back into this same loop on this
topic but that's not the problem we've been seeing.  There are no
other CPUs involved.

It's great that Steven's patches solve a good number of problems.  It
is also true that there's a class of problems that it doesn't solve,
which other approaches do.  The productive thing to do here is trying
to solve the unsolved one too, especially given that it doesn't seem
too difficuilt to do so on top of what's proposed.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
