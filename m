From: pnilesh@in.ibm.com
Message-ID: <CA2568C5.003C28B0.00@d73mta05.au.ibm.com>
Date: Tue, 18 Apr 2000 16:19:00 +0530
Subject: Re: preemp / nonpreemp
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Eric W. Biederman" <"ebiederm+eric"@ccr.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Apr 18, 2000 at 01:50:20PM +0530, pnilesh@in.ibm.com wrote:
>
>  Does it mean that I can go and write schedule () in the kernel and it
> should             not create any problems ?/* not in handler */

1 But will there be any complication as Eric told ?

It will be fine: it happens all over the place.  It's the standard
mechanism used to sleep on IO events.  Preemption implies that a timer
interrupt can forcibly reschedule a kernel task, and that won't ever
happen on current kernels.  Voluntary rescheduling, on the other hand,
is quite proper.

2 Is there any plan to make Linux kernel preemptable ?
3 What could be performance gain/loss compared to the current kernels ?

Nilesh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
