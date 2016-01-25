Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1416B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 13:44:41 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id yy13so84541967pab.3
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:44:41 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id rl9si359915pab.109.2016.01.25.10.44.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 10:44:40 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id e65so7259444pfe.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:44:40 -0800 (PST)
Date: Mon, 25 Jan 2016 13:44:38 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4 01/22] timer: Allow to check when the timer callback
 has not finished yet
Message-ID: <20160125184438.GA3628@mtj.duckdns.org>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
 <1453736711-6703-2-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453736711-6703-2-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Mon, Jan 25, 2016 at 04:44:50PM +0100, Petr Mladek wrote:
> timer_pending() checks whether the list of callbacks is empty.
> Each callback is removed from the list before it is called,
> see call_timer_fn() in __run_timers().
> 
> Sometimes we need to make sure that the callback has finished.
> For example, if we want to free some resources that are accessed
> by the callback.
> 
> For this purpose, this patch adds timer_active(). It checks both
> the list of callbacks and the running_timer. It takes the base_lock
> to see a consistent state.
> 
> I plan to use it to implement delayed works in kthread worker.
> But I guess that it will have wider use. In fact, I wonder if
> timer_pending() is misused in some situations.

I don't think this is still necessary.  More on this later.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
