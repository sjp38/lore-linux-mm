Subject: Re: preemp / nonpreemp
References: <CA2568C5.0017E931.00@d73mta05.au.ibm.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 18 Apr 2000 01:40:41 -0500
In-Reply-To: pnilesh@in.ibm.com's message of "Tue, 18 Apr 2000 09:42:27 +0530"
Message-ID: <m14s8zkj2u.fsf@flinx.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

pnilesh@in.ibm.com writes:

> The Linux kernel is preemptable.
> 
> Does the preemption mean that inside system calls in kernel a call to
> schedule is possible .
> Or is there more to it .

Well there is the obvious part about being able to prempt user space
from a timer tick which gives you most of the work.

As far as internally to the kernel on a SMP box unless you 
are holding the big kernel lock to threads can be running at the
same time in kernel.  Using the architecture it is also possible
to prempt kernel threads that don't hold the big kernel lock on
non-SMP systems as well.  non-SMP premption probably won't appear until
early 2.5 however as it may have a few complications.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
