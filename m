Date: Tue, 26 Oct 1999 11:05:58 +0200
From: Ralf Baechle <ralf@uni-koblenz.de>
Subject: Re: page faults
Message-ID: <19991026110558.A1588@uni-koblenz.de>
References: <Pine.LNX.4.10.9910221930070.172-100000@imperial.edgeglobal.com> <m1wvsc8ytq.fsf@flinx.hidden>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m1wvsc8ytq.fsf@flinx.hidden>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: James Simmons <jsimmons@edgeglobal.com>, "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Oct 24, 1999 at 12:15:29PM -0500, Eric W. Biederman wrote:

> > Does this mean that linux/drivers/sgi/char/graphics.c page fault handler
> > not work for a threaded program? It works great switching between
> > different processes but if this is the case for threads this could be a
> > problem.
> 
> It means it may not work as intended.
> Once the page is faulted in all threads will have access to it.

This interface is inherited from IRIX where it is used for the X server
and other direct rendering programs.  It probably even predates the
IRIX sproc(2) interface for kernel threads.  And sproc(2) again has the
advantage that it allows for thread-local mappings.  So for example
IRIX threads always have their PRDA mapped locally and can have their
stacks all at the same address because the stack area is mapped only
locally.

In the past Linus already said that he doesn't want such a feature to
enter mm and I agree with him because of the involved complexity.  So
in short I'd say it's best to leave the operation of this interface
undefined and recommend the usage of a separate rendering thread or
a suitable mutual exclusion algorithem.

> If the hardware cannot support two processors hitting the region
> simultaneously, (support would be worst case the graphics would look
> strange) you could have problems.

I'm sure there is stupid hardware which will allow to crash the system.

  Ralf
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
