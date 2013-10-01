Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D5E9D6B003B
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 11:24:57 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so7644713pab.29
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 08:24:57 -0700 (PDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 1 Oct 2013 09:24:55 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id A06F71FF001B
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 09:24:44 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r91FOp5i312512
	for <linux-mm@kvack.org>; Tue, 1 Oct 2013 09:24:51 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r91FRtYo026304
	for <linux-mm@kvack.org>; Tue, 1 Oct 2013 09:27:56 -0600
Date: Tue, 1 Oct 2013 08:24:49 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20131001152449.GD5790@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20130925212200.GA7959@linux.vnet.ibm.com>
 <20130926111042.GS3081@twins.programming.kicks-ass.net>
 <20130926165840.GA863@redhat.com>
 <20130926175016.GI3657@laptop.programming.kicks-ass.net>
 <20130927181532.GA8401@redhat.com>
 <20130927204116.GJ15690@laptop.programming.kicks-ass.net>
 <20131001035604.GW19582@linux.vnet.ibm.com>
 <20131001141429.GA32423@redhat.com>
 <20131001144537.GC5790@linux.vnet.ibm.com>
 <20131001144820.GP3657@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131001144820.GP3657@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Tue, Oct 01, 2013 at 04:48:20PM +0200, Peter Zijlstra wrote:
> On Tue, Oct 01, 2013 at 07:45:37AM -0700, Paul E. McKenney wrote:
> > If you don't have cpuhp_seq, you need some other way to avoid
> > counter overflow.  Which might be provided by limited number of
> > tasks, or, on 64-bit systems, 64-bit counters.
> 
> How so? PID space is basically limited to 30 bits, so how could we
> overflow a 32bit reference counter?

Nesting.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
