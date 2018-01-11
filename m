Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C91876B0069
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 02:36:25 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id w7so1282208pfd.4
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 23:36:25 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x20sor4282948pfh.4.2018.01.10.23.36.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 23:36:24 -0800 (PST)
Date: Thu, 11 Jan 2018 16:36:18 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180111073618.GA477@jagdpanzerIV>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110162900.GA21753@linux.suse>
 <20180110170223.GF3668920@devbig577.frc2.facebook.com>
 <532107698.142.1515609640436.JavaMail.zimbra@efficios.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <532107698.142.1515609640436.JavaMail.zimbra@efficios.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Tejun Heo <tj@kernel.org>, Petr Mladek <pmladek@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel <linux-kernel@vger.kernel.org>

Hi Mathieu,

On (01/10/18 18:40), Mathieu Desnoyers wrote:
[..]
> 
> There appears to be two problems at hand. One is making sure a console
> buffer owner only flushes a bounded amount of data.

which, realistically, has quite little to do with the "and thus it
fixes the lockups". logbuf size is mutable, the number of consoles we
need to sequentially push the data to is mutable, the watchdog threshold
is mutable... if combination of first two mutable things produces the
result which makes the check based on the third mutable thing happy,
then it's just an accident. my 5 cents.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
