Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0B9796B0037
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 11:07:08 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so5774226pde.24
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 08:07:08 -0700 (PDT)
Date: Mon, 30 Sep 2013 17:06:53 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] introduce synchronize_sched_{enter,exit}()
Message-ID: <20130930150653.GL26785@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-38-git-send-email-mgorman@suse.de>
 <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130929183634.GA15563@redhat.com>
 <20130930125942.GB12926@twins.programming.kicks-ass.net>
 <20130930142400.GK26785@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130930142400.GK26785@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Sep 30, 2013 at 04:24:00PM +0200, Peter Zijlstra wrote:
> For that we'd have to decrement xxx->gp_count from cb_rcu_func(),
> wouldn't we?
> 
> Without that there's no guarantee the fast path readers will have a MB
> to observe the write critical section, unless I'm completely missing
> something obviuos here.

Duh.. we should be looking at gp_state like Paul said.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
