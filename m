Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 632D26B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 11:08:30 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id c11so3404523wrb.23
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 08:08:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e13si8732895wra.463.2018.01.15.08.08.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jan 2018 08:08:28 -0800 (PST)
Date: Mon, 15 Jan 2018 17:08:20 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 2/2] printk: Hide console waiter logic into helpers
Message-ID: <20180115160820.vsn7wyejlp2f654s@pathway.suse.cz>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110132418.7080-3-pmladek@suse.com>
 <20180110125220.69f5f930@vmware.local.home>
 <20180111120341.GB24419@linux.suse>
 <20180112103754.1916a1e2@gandalf.local.home>
 <20180112160837.GD24497@linux.suse>
 <20180112113627.7c454063@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180112113627.7c454063@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Fri 2018-01-12 11:36:27, Steven Rostedt wrote:
> On Fri, 12 Jan 2018 17:08:37 +0100
> Petr Mladek <pmladek@suse.com> wrote:
> > >From f67f70d910d9cf310a7bc73e97bf14097d31b059 Mon Sep 17 00:00:00 2001  
> > From: Petr Mladek <pmladek@suse.com>
> > Date: Fri, 22 Dec 2017 18:58:46 +0100
> > Subject: [PATCH v6 2/4] printk: Hide console waiter logic into helpers
> > 
> > The commit ("printk: Add console owner and waiter logic to load balance
> > console writes") made vprintk_emit() and console_unlock() even more
> > complicated.
> > 
> > This patch extracts the new code into 3 helper functions. They should
> > help to keep it rather self-contained. It will be easier to use and
> > maintain.
> > 
> > This patch just shuffles the existing code. It does not change
> > the functionality.
> > 
> Besides the typos (which should be fixed)...
> 
> Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

JFYI, I have fixed the typos, updated the commit message for
the 1st patch and pushed all into printk.git,
branch for-4.16-console-waiter-logic, see
https://git.kernel.org/pub/scm/linux/kernel/git/pmladek/printk.git/log/?h=for-4.16-console-waiter-logic

I know that the discussion is not completely finished but it is
somehow cycling. Sergey few times wrote that he would not block
these patches. It is high time, I put it into linux-next. I could
always remove it if decided in the discussion.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
