Subject: Re: preemp / nonpreemp
References: <CA2568C5.002E8BFC.00@d73mta03.au.ibm.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 18 Apr 2000 10:03:22 -0500
In-Reply-To: pnilesh@in.ibm.com's message of "Tue, 18 Apr 2000 13:50:20 +0530"
Message-ID: <m1u2gzih8l.fsf@flinx.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: "Eric W. Biederman" <"ebiederm+eric"@ccr.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

pnilesh@in.ibm.com writes:

>   Using the architecture it is also possible
> to prempt kernel threads that don't hold the big kernel lock on
> non-SMP systems as well.
> 
>  Does it mean that I can go and write schedule () in the kernel and it
> should             not create any problems ?/* not in handler */

Right.  As a general rule you can never assume any function call
doesn't call schedule in the kernel.

> 
>   non-SMP premption probably won't appear until
> early 2.5 however as it may have a few complications.
> 
> Can you tell me any complication ?

The compilications were in partially balance pairs like:
spin_lock_irqsave....
spin_unlock...
restore_flags....

That the proposed trivial implentations of the locking
primitives might not handle quite correctly.

That's for premption in the kernel not calling schedule.
You can find the details on the lowlatency thread a while
ago on linux-kernel.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
