Message-ID: <3994141A.D98D6DE@augan.com>
Date: Fri, 11 Aug 2000 16:56:26 +0200
From: Roman Zippel <roman@augan.com>
MIME-Version: 1.0
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
References: <200008111320.OAA02445@flint.arm.linux.org.uk>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Russell King wrote:

> > Can you send me that patch? I'd like to check it, if it can be used for
> > the m68k port. m68k still has its own support for discontinous mem and
> > from what I've seen so far I'm not really convinced yet to give it up.
> 
> I don't see anything wrong in continuing with this.  ARM also does
> this in addition to support for the discontig mem stuff.  Why?

My problem is that I'm not really familiar with the high memory support.
The problem here is that the relation between virtual address / physical
address / page struct / memmap+index is hardly documented and it gets
more interesting when a page struct might also represent an i/o area
(for direct i/o).

> The generial discontig code is ok so long as you have a lot of RAM
> in node 0.  However, since all allocations currently come from node
> 0, if this node is small, then there is a chance that you will run
> out of memory at bootup, and then not be able to continue (and
> because we both use fbcon, there is no message visible to the user,
> and hence no diagnostics).

Another problem on m68k: I can make almost no assumption about the
memory layout to play some clever tricks. If I remember correctly I had
some problems with the memmap layout, since lots of code assumed a
continuos memmap and there were some tricks to get the above
relationship right.

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
