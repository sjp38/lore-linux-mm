Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2856B0033
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 00:35:14 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id g68so797806pfb.17
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:35:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k191sor853656pgd.368.2018.01.10.21.35.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 21:35:12 -0800 (PST)
Date: Thu, 11 Jan 2018 14:35:07 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180111053507.GD494@jagdpanzerIV>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110130517.6ff91716@vmware.local.home>
 <20180110181252.GK3668920@devbig577.frc2.facebook.com>
 <20180110134157.1c3ce4b9@vmware.local.home>
 <20180110185747.GO3668920@devbig577.frc2.facebook.com>
 <20180110141758.1f88e1a0@vmware.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110141758.1f88e1a0@vmware.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Tejun Heo <tj@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/10/18 14:17), Steven Rostedt wrote:
[..]
> OK, lets start over.

good.

> Right now my focus is an incremental approach. I'm not trying to solve
> all issues that printk has. I've focused on a single issue, and that is
> that printk is unbounded. Coming from a Real Time background, I find
> that is a big problem. I hate unbounded algorithms.

agreed! so why not bound it to watchdog threshold then? why bound
it to a random O(logbuf) thing? which is not even constant. when you
un-register or disable one or several consoles then call_console_drivers()
becomes faster; when you register/enable consoles then the entire
call_console_drivers() becomes slower. how do we build a reliable
algorithm on that O(logbuf)?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
