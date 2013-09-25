Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 378226B0034
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 11:35:50 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so5343347pab.24
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 08:35:49 -0700 (PDT)
Date: Wed, 25 Sep 2013 17:35:33 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130925153533.GN3081@twins.programming.kicks-ass.net>
References: <20130919143241.GB26785@twins.programming.kicks-ass.net>
 <20130923175052.GA20991@redhat.com>
 <20130924123821.GT12926@twins.programming.kicks-ass.net>
 <20130924160359.GA2739@redhat.com>
 <20130924124341.64d57912@gandalf.local.home>
 <20130924170631.GB5059@redhat.com>
 <20130924174717.GH9093@linux.vnet.ibm.com>
 <20130924180005.GA7148@redhat.com>
 <20130924203512.GS9326@twins.programming.kicks-ass.net>
 <20130925151642.GA13244@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130925151642.GA13244@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Steven Rostedt <rostedt@goodmis.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Sep 25, 2013 at 05:16:42PM +0200, Oleg Nesterov wrote:
> Yes, but my point was, this can only happen in recursive fast path.

Right, I understood.

> And in this case (I think) we do not care, we are already in the critical
> section.

I tend to agree, however paranoia..

> OK, please forget. I guess I will never understand this ;)

It might just be I'm less certain about there not being any avenue of
mischief.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
