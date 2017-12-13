Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id EB4706B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 20:50:15 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id n4so109094plp.23
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 17:50:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e87sor189311pfm.133.2017.12.12.17.50.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Dec 2017 17:50:14 -0800 (PST)
Date: Wed, 13 Dec 2017 10:50:04 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171213015004.GA9462@jagdpanzerIV>
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
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Byungchul Park <byungchul.park@lge.com>, LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, kernel-team@lge.com

On (12/12/17 14:27), Steven Rostedt wrote:
> > p.s.
> > frankly, I don't see any "locking issues" in Steven's patch.
> 
> Should I push out another revision of mine?

well, up to you :)

I've picked up some bits of your console-owner patch and it's
part of printk-kthread patch set [as of now]:

lkml.kernel.org/r/20171204134825.7822-13-sergey.senozhatsky@gmail.com


the series:
lkml.kernel.org/r/20171204134825.7822-1-sergey.senozhatsky@gmail.com

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
