Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F123C6B026D
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 08:19:46 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id b75so432700pfk.22
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 05:19:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b8sor445875pgr.420.2018.01.11.05.19.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jan 2018 05:19:45 -0800 (PST)
Date: Thu, 11 Jan 2018 22:19:40 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180111131940.GA3479@tigerII.localdomain>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110162900.GA21753@linux.suse>
 <20180110170223.GF3668920@devbig577.frc2.facebook.com>
 <532107698.142.1515609640436.JavaMail.zimbra@efficios.com>
 <20180111073618.GA477@jagdpanzerIV>
 <20180111112426.GB24497@linux.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180111112426.GB24497@linux.suse>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel <linux-kernel@vger.kernel.org>

On (01/11/18 12:24), Petr Mladek wrote:
[..]
> You might argue that we already know that Steven's solution will
> not be enough. IMHO, the problem here is the term "real life example".

this is really boring, how real life examples happen only on Steven's PC
or Petr's qemu image. whatever.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
