Date: Tue, 18 Apr 2000 12:23:36 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: preemp / nonpreemp
Message-ID: <20000418122336.Q3916@redhat.com>
References: <CA2568C5.003C28B0.00@d73mta05.au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA2568C5.003C28B0.00@d73mta05.au.ibm.com>; from pnilesh@in.ibm.com on Tue, Apr 18, 2000 at 04:19:00PM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <"ebiederm+eric"@ccr.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Apr 18, 2000 at 04:19:00PM +0530, pnilesh@in.ibm.com wrote:
> >  Does it mean that I can go and write schedule () in the kernel and it
> > should             not create any problems ?/* not in handler */
> 
> 1 But will there be any complication as Eric told ?

No, none.

> It will be fine: it happens all over the place.  It's the standard
> mechanism used to sleep on IO events.  Preemption implies that a timer
> interrupt can forcibly reschedule a kernel task, and that won't ever
> happen on current kernels.  Voluntary rescheduling, on the other hand,
> is quite proper.
> 
> 2 Is there any plan to make Linux kernel preemptable ?

Some talk, no definite plans.

> 3 What could be performance gain/loss compared to the current kernels ?

It would probably be a performance loss overall.  However, it would
allow for better response time guarantees.  It's the sort of thing 
best done only when response time is absolutely the most important
issue: if you use the RTLinux real time kernel, for example, then you
can make certain tasks operate in a fully preemptible environment 
without changing the whole of the kernel.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
