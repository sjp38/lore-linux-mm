Date: Mon, 24 Jan 2000 23:38:47 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [PATCH] 2.2.14 VM fix #3
In-Reply-To: <14476.42622.777454.521474@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.10001242335450.467-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Mon, 24 Jan 2000, Stephen C. Tweedie wrote:
> On Fri, 21 Jan 2000 14:34:14 +0100 (CET), Andrea Arcangeli
> <andrea@suse.de> said:
> 
> > Sorry but I will never agree with your patch. The GFP_KERNEL change is not
> > something for 2.2.x. We have major deadlocks in getblk for example and you
> > may trigger tham more easily forbidding GFP_MID allocations to
> > succeed. 
> 
> Agreed, definitely.

OTOH, 2.2.1{3,4} have seen deadlocks because GFP_KERNEL
allocations had eaten up all of memory and a PF_MEMALLOC
allocation couldn't get through. It has also DoSed some
servers where the network driver got temporarily confused
when a GFP_ATOMIC allocation failed.

> > Also killing the low_on_memory will harm performance. You doesn't seems to
> > see what such bit (that should be a per-process thing) is good for.
> 
> Also agreed --- removing the per-process flag will just penalise
> _all_ processes when we enter thrashing.

Except that it never was a per-process flag...
(so we didn't lose anything there)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
