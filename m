Date: Tue, 18 Apr 2000 10:22:56 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: preemp / nonpreemp
Message-ID: <20000418102256.J3916@redhat.com>
References: <CA2568C5.002E89C4.00@d73mta05.au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA2568C5.002E89C4.00@d73mta05.au.ibm.com>; from pnilesh@in.ibm.com on Tue, Apr 18, 2000 at 01:50:20PM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: "Eric W. Biederman" <"ebiederm+eric"@ccr.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Apr 18, 2000 at 01:50:20PM +0530, pnilesh@in.ibm.com wrote:
> 
>  Does it mean that I can go and write schedule () in the kernel and it
> should             not create any problems ?/* not in handler */

It will be fine: it happens all over the place.  It's the standard
mechanism used to sleep on IO events.  Preemption implies that a timer
interrupt can forcibly reschedule a kernel task, and that won't ever
happen on current kernels.  Voluntary rescheduling, on the other hand,
is quite proper.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
