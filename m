From: Russell King <rmk@arm.linux.org.uk>
Message-Id: <200009252023.VAA13816@flint.arm.linux.org.uk>
Subject: Re: the new VMt
Date: Mon, 25 Sep 2000 21:23:41 +0100 (BST)
In-Reply-To: <20000925181817.A25553@gruyere.muc.suse.de> from "Andi Kleen" at Sep 25, 2000 06:18:17 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Andi Kleen writes:
> On Mon, Sep 25, 2000 at 06:19:07PM +0200, Ingo Molnar wrote:
> > > Another thing I would worry about are ports with multiple user page
> > > sizes in 2.5. Another ugly case is the x86-64 port which has 4K pages
> > > but may likely need a 16K kernel stack due to the 64bit stack bloat.
> > 
> > yep, but these cases are not affected, i think in the order != 0 case we
> > should return NULL if a certain number of iterations did not yield any
> > free page.
> 
> Ok, that would just break fork()

Especially so when, on the ARM, the first level page table is 16K, and the
page size is 4K.  Should Ingo's suggestion happen, we still need a way
of allocating 16K aligned chunks of memory for such stuff.

Just a small question... I thought we were discussing 2.4, not possible
features for 2.5?
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
