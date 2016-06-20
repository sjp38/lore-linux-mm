Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B93716B0005
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 16:29:05 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id z142so407239284qkb.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 13:29:05 -0700 (PDT)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id x67si19905044yba.1.2016.06.20.13.29.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 13:29:04 -0700 (PDT)
Received: by mail-yw0-x244.google.com with SMTP id i12so2904193ywa.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 13:29:04 -0700 (PDT)
Date: Mon, 20 Jun 2016 16:29:03 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v9 11/12] kthread: Allow to modify delayed kthread work
Message-ID: <20160620202903.GC3262@mtj.duckdns.org>
References: <1466075851-24013-1-git-send-email-pmladek@suse.com>
 <1466075851-24013-12-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466075851-24013-12-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jun 16, 2016 at 01:17:30PM +0200, Petr Mladek wrote:
> There are situations when we need to modify the delay of a delayed kthread
> work. For example, when the work depends on an event and the initial delay
> means a timeout. Then we want to queue the work immediately when the event
> happens.
> 
> This patch implements kthread_mod_delayed_work() as inspired workqueues.
> It cancels the timer, removes the work from any worker list and queues it
> again with the given timeout.
> 
> A very special case is when the work is being canceled at the same time.
> It might happen because of the regular kthread_cancel_delayed_work_sync()
> or by another kthread_mod_delayed_work(). In this case, we do nothing and
> let the other operation win. This should not normally happen as the caller
> is supposed to synchronize these operations a reasonable way.
> 
> Signed-off-by: Petr Mladek <pmladek@suse.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
