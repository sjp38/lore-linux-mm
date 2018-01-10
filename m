Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A6E076B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 11:50:36 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id x1so8514574plb.2
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 08:50:36 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m69si3693492pfc.51.2018.01.10.08.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 08:50:35 -0800 (PST)
Date: Wed, 10 Jan 2018 11:50:31 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 1/2] printk: Add console owner and waiter logic to
 load balance console writes
Message-ID: <20180110115031.3bdaa5c6@vmware.local.home>
In-Reply-To: <20180110132418.7080-2-pmladek@suse.com>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110132418.7080-2-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed, 10 Jan 2018 14:24:17 +0100
Petr Mladek <pmladek@suse.com> wrote:

> From: Steven Rostedt <rostedt@goodmis.org>

Please remove the above From:, it will overwrite the one below which I
would prefer to have.

Thanks!

-- Steve

> 
> From: Steven Rostedt (VMware) <rostedt@goodmis.org>
> 
> This patch implements what I discussed in Kernel Summit. I added
> lockdep annotation (hopefully correctly), and it hasn't had any splats
> (since I fixed some bugs in the first iterations). It did catch
> problems when I had the owner covering too much. But now that the owner
> is only set when actively calling the consoles, lockdep has stayed
> quiet.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
