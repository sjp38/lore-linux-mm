Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3076D6B0266
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 04:51:46 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 82so1374689pfs.8
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 01:51:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o2sor1853409pge.239.2018.01.19.01.51.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jan 2018 01:51:44 -0800 (PST)
Date: Fri, 19 Jan 2018 18:51:41 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v5 1/2] printk: Add console owner and waiter logic to
 load balance console writes
Message-ID: <20180119095141.GA29479@tigerII.localdomain>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110132418.7080-2-pmladek@suse.com>
 <20180112115454.17c03c8f@gandalf.local.home>
 <20180112121148.20778932@gandalf.local.home>
 <2c4e5175-e806-02f9-1467-081a9f533de1@prevas.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2c4e5175-e806-02f9-1467-081a9f533de1@prevas.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <rasmus.villemoes@prevas.dk>
Cc: Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/17/18 20:13), Rasmus Villemoes wrote:
[..]
> >> Hmm, how does one have git commit not remove the C preprocessor at the
> >> start of the module?
> > 
> > Probably just add a space in front of the entire program.
> 
> If you use at least git 2.0.0 [1], set commit.cleanup to "scissors".
> Something like
> 
>   git config commit.cleanup scissors
> 
> should do the trick. Instead of stripping all lines starting with #,
> that will only strip stuff below a line containing
> 
> # ------------------------ >8 ------------------------

one thing that it changes is that now when you squash commits


# This is the first patch

first patch commit messages

# This is the second patch

second patch commit message

# ------------------------ >8 ------------------------



those "# This is the first patch" and "# This is the second patch"
won't be removed automatically. takes some time to get used to it.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
