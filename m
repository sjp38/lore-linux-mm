Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 24DD86B025E
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 00:43:58 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 199so8149022pfy.18
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 21:43:58 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m26sor1336779pgc.259.2018.01.17.21.43.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 21:43:57 -0800 (PST)
Date: Thu, 18 Jan 2018 14:43:52 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180118054352.GC6529@jagdpanzerIV>
References: <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180111203057.5b1a8f8f@gandalf.local.home>
 <20180111215547.2f66a23a@gandalf.local.home>
 <20180116194456.GS3460072@devbig577.frc2.facebook.com>
 <20180117091208.ezvuhumnsarz5thh@pathway.suse.cz>
 <20180117151509.GT3460072@devbig577.frc2.facebook.com>
 <20180117121251.7283a56e@gandalf.local.home>
 <20180117200551.GW3460072@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180117200551.GW3460072@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/17/18 12:05), Tejun Heo wrote:
[..]
> > This could very well be a great place to force offloading. If a printk
> > is called from within a printk, at the same context (normal, softirq,
> > irq or NMI), then we should trigger the offloading.
> 
> I was thinking more of a timeout based approach (ie. if stuck for
> longer than X or X messages, offload)

yep, that's what I want. for a whole bunch of different reasons.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
