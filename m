Date: Fri, 22 Oct 1999 19:31:34 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: page faults
In-Reply-To: <14352.41043.903043.50156@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9910221930070.172-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Oct 1999, Stephen C. Tweedie wrote:

> Hi,
> 
> On Fri, 22 Oct 1999 10:59:25 -0400 (EDT), James Simmons
> <jsimmons@edgeglobal.com> said:
> 
> > Thank you for that answer. I remember you told me that threads under
> > linux is defined as two processes sharing the same memory. So when a
> > minor page fault happens by anyone one process will both process page
> > tables get updated? Or does the other process will have a minor page
> > itself independent of the other process?
> 
> Threads are a special case: there is only one set of page tables, and
> the pte will only be faulted in once.


Does this mean that linux/drivers/sgi/char/graphics.c page fault handler
not work for a threaded program? It works great switching between
different processes but if this is the case for threads this could be a
problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
