Date: Mon, 4 Oct 1999 11:52:50 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: MMIO regions
In-Reply-To: <14328.51304.207897.182095@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9910041146560.8080-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Oct 1999, Stephen C. Tweedie wrote:

> Hi,
> 
> On Mon, 4 Oct 1999 10:38:13 -0400 (EDT), James Simmons
> <jsimmons@edgeglobal.com> said:
> 
> >    I noticed something for SMP machines with all the dicussion about
> > concurrent access to memory regions. What happens when you have two
> > processes that have both mmapped the same MMIO region for some card.
> 
> The kernel doesn't impose any limits against this.  If you want to make
> this impossible, then you need to add locking to the driver itself to
> prevent multiple processes from conflicting.

And if the process holding the locks dies then no other process can access
this resource. Also if the program forgets to release the lock you end up
with other process never being able to access this piece of hardware.   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
