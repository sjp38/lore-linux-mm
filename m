Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 028FA6B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 12:40:59 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so75383pab.34
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 09:40:59 -0700 (PDT)
Date: Wed, 25 Sep 2013 18:33:57 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130925163357.GB17447@redhat.com>
References: <20130923175052.GA20991@redhat.com> <20130924123821.GT12926@twins.programming.kicks-ass.net> <20130924160359.GA2739@redhat.com> <20130924124341.64d57912@gandalf.local.home> <20130924170631.GB5059@redhat.com> <20130924174717.GH9093@linux.vnet.ibm.com> <20130924180005.GA7148@redhat.com> <20130924203512.GS9326@twins.programming.kicks-ass.net> <20130925151642.GA13244@redhat.com> <20130925153533.GN3081@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130925153533.GN3081@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Steven Rostedt <rostedt@goodmis.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>

On 09/25, Peter Zijlstra wrote:
>
> On Wed, Sep 25, 2013 at 05:16:42PM +0200, Oleg Nesterov wrote:
>
> > And in this case (I think) we do not care, we are already in the critical
> > section.
>
> I tend to agree, however paranoia..

Ah, in this case I tend to agree. better be paranoid ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
