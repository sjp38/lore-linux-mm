Subject: Re: page faults
References: <Pine.LNX.4.10.9910221930070.172-100000@imperial.edgeglobal.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 24 Oct 1999 12:15:29 -0500
In-Reply-To: James Simmons's message of "Fri, 22 Oct 1999 19:31:34 -0400 (EDT)"
Message-ID: <m1wvsc8ytq.fsf@flinx.hidden>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

James Simmons <jsimmons@edgeglobal.com> writes:

> On Fri, 22 Oct 1999, Stephen C. Tweedie wrote:
> 
> > Hi,
> > 
> > On Fri, 22 Oct 1999 10:59:25 -0400 (EDT), James Simmons
> > <jsimmons@edgeglobal.com> said:
> > 
> > > Thank you for that answer. I remember you told me that threads under
> > > linux is defined as two processes sharing the same memory. So when a
> > > minor page fault happens by anyone one process will both process page
> > > tables get updated? Or does the other process will have a minor page
> > > itself independent of the other process?
> > 
> > Threads are a special case: there is only one set of page tables, and
> > the pte will only be faulted in once.
> 
> 
> Does this mean that linux/drivers/sgi/char/graphics.c page fault handler
> not work for a threaded program? It works great switching between
> different processes but if this is the case for threads this could be a
> problem.

It means it may not work as intended.
Once the page is faulted in all threads will have access to it.

If the hardware cannot support two processors hitting the region simultaneously,
(support would be worst case the graphics would look strange)
you could have problems.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
