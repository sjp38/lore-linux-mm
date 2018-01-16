Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 785C66B025F
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 00:05:20 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 34so5198945plm.23
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 21:05:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f6sor471629plr.88.2018.01.15.21.05.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jan 2018 21:05:19 -0800 (PST)
Date: Tue, 16 Jan 2018 14:05:14 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 2/2] printk: Hide console waiter logic into helpers
Message-ID: <20180116050514.GA13731@jagdpanzerIV>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110132418.7080-3-pmladek@suse.com>
 <20180110125220.69f5f930@vmware.local.home>
 <20180111120341.GB24419@linux.suse>
 <20180112103754.1916a1e2@gandalf.local.home>
 <20180112160837.GD24497@linux.suse>
 <20180112113627.7c454063@gandalf.local.home>
 <20180115160820.vsn7wyejlp2f654s@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180115160820.vsn7wyejlp2f654s@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/15/18 17:08), Petr Mladek wrote:
> > Besides the typos (which should be fixed)...
> > 
> > Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
> 
> JFYI, I have fixed the typos, updated the commit message for
> the 1st patch and pushed all into printk.git,
> branch for-4.16-console-waiter-logic, see
> https://git.kernel.org/pub/scm/linux/kernel/git/pmladek/printk.git/log/?h=for-4.16-console-waiter-logic
> 
> I know that the discussion is not completely finished but it is
> somehow cycling. Sergey few times wrote that he would not block
> these patches. It is high time, I put it into linux-next. I could
> always remove it if decided in the discussion.

Acked-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

at least we have preemption out of printk->user way (one of the
things I tried to tell you), which looks more like a step forward
to me personally.


p.s. the printk is still pretty far from what I want it to be.
     vprintk_emit() still can cause disturbance and damage in
     pretty unrelated places. e.g. hung tasks on console_sem,
     and so on. I'm going to keep my out-of-tree patches alive,
     may be they will be merged upstream in some form or another
     may be not.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
