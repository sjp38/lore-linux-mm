Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3316D6B0033
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 14:33:59 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id g186so4525107pfb.11
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 11:33:59 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f6si5155991pln.303.2018.01.17.11.33.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 11:33:58 -0800 (PST)
Date: Wed, 17 Jan 2018 14:33:53 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 1/2] printk: Add console owner and waiter logic to
 load balance console writes
Message-ID: <20180117143353.2e86dbde@gandalf.local.home>
In-Reply-To: <2c4e5175-e806-02f9-1467-081a9f533de1@prevas.dk>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110132418.7080-2-pmladek@suse.com>
	<20180112115454.17c03c8f@gandalf.local.home>
	<20180112121148.20778932@gandalf.local.home>
	<2c4e5175-e806-02f9-1467-081a9f533de1@prevas.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <rasmus.villemoes@prevas.dk>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed, 17 Jan 2018 20:13:28 +0100
Rasmus Villemoes <rasmus.villemoes@prevas.dk> wrote:

> If you use at least git 2.0.0 [1], set commit.cleanup to "scissors".
> Something like
> 
>   git config commit.cleanup scissors
> 
> should do the trick. Instead of stripping all lines starting with #,
> that will only strip stuff below a line containing
> 
> # ------------------------ >8 ------------------------
> 
> and git should be smart enough to insert that in the editor it fires up
> for a commit message.
> 
> 
> [1] https://github.com/git/git/blob/master/Documentation/RelNotes/2.0.0.txt
> 
> 

Thanks for the pointer.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
