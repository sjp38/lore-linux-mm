From: Russell King <rmk@arm.linux.org.uk>
Message-Id: <200008111320.OAA02445@flint.arm.linux.org.uk>
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Date: Fri, 11 Aug 2000 14:20:23 +0100 (BST)
In-Reply-To: <3993E87A.234FDEE7@augan.com> from "Roman Zippel" at Aug 11, 2000 01:50:18 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <roman@augan.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Roman Zippel writes:
> Can you send me that patch? I'd like to check it, if it can be used for
> the m68k port. m68k still has its own support for discontinous mem and
> from what I've seen so far I'm not really convinced yet to give it up.

I don't see anything wrong in continuing with this.  ARM also does
this in addition to support for the discontig mem stuff.  Why?

The generial discontig code is ok so long as you have a lot of RAM
in node 0.  However, since all allocations currently come from node
0, if this node is small, then there is a chance that you will run
out of memory at bootup, and then not be able to continue (and
because we both use fbcon, there is no message visible to the user,
and hence no diagnostics).

Continuing with the single node but many "areas" that ARM follows, and
from what it sounds like m68k does, means that you can allocate from
any "area", and therefore don't hit this restriction.

One way out of this would be if the NUMA stuff can have the "allocations
only from node 0" feature turned off, and then I'd be happy to let the
ARM version be replaced totally by the discontig case.
   _____
  |_____| ------------------------------------------------- ---+---+-
  |   |         Russell King        rmk@arm.linux.org.uk      --- ---
  | | | | http://www.arm.linux.org.uk/personal/aboutme.html   /  /  |
  | +-+-+                                                     --- -+-
  /   |               THE developer of ARM Linux              |+| /|\
 /  | | |                                                     ---  |
    +-+-+ -------------------------------------------------  /\\\  |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
