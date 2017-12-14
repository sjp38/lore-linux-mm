Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 610BB6B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 09:34:17 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id p17so4814081pfh.18
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:34:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e18si2981789pgq.134.2017.12.14.06.34.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Dec 2017 06:34:16 -0800 (PST)
Date: Thu, 14 Dec 2017 15:34:12 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171214143412.frjrq4lykjahlqq6@pathway.suse.cz>
References: <20171108102723.602216b1@gandalf.local.home>
 <20171124152857.ahnapnwmmsricunz@pathway.suse.cz>
 <20171124155816.pxp345ch4gevjqjm@pathway.suse.cz>
 <20171128014229.GA2899@X58A-UD3R>
 <20171208140022.uln4t5e5drrhnvvt@pathway.suse.cz>
 <20171212053921.GA1392@jagdpanzerIV>
 <20171212142710.21e82ecd@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171212142710.21e82ecd@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Byungchul Park <byungchul.park@lge.com>, LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, kernel-team@lge.com

On Tue 2017-12-12 14:27:10, Steven Rostedt wrote:
> On Tue, 12 Dec 2017 14:39:21 +0900
> Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:
> 
> > p.s.
> > frankly, I don't see any "locking issues" in Steven's patch.
> 
> Should I push out another revision of mine?

I am going to to give some more testing v4 within next few days.
If it works well, I think that it would need just some cosmetic
changes.

For example, it would be nice to somehow encapsulate
the handshake-related code into few helpers. I believe that
it might help us to understand and maintain it. Both
vprintk_emit() and console_unlock() were too long already
before.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
