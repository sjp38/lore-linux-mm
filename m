Received: from mail.sisk.pl ([127.0.0.1])
 by localhost (grendel [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26871-06 for <linux-mm@kvack.org>; Tue,  9 Aug 2005 12:20:19 +0200 (CEST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
Date: Tue, 9 Aug 2005 12:24:36 +0200
References: <42F57FCA.9040805@yahoo.com.au> <1123576719.3839.13.camel@laptopd505.fenrus.org> <42F877FF.9000803@yahoo.com.au>
In-Reply-To: <42F877FF.9000803@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508091224.37668.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Arjan van de Ven <arjan@infradead.org>, Russell King <rmk+lkml@arm.linux.org.uk>, ncunningham@cyclades.com, Daniel Phillips <phillips@arcor.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Pavel Machek <pavel@ucw.cz>
List-ID: <linux-mm.kvack.org>

On Tuesday, 9 of August 2005 11:31, Nick Piggin wrote:
> Arjan van de Ven wrote:
> > On Tue, 2005-08-09 at 08:08 +0100, Russell King wrote:
> 
> >>Can we straighten out the terminology so it's less confusing please?
> >>
> > 
> > 
> > and..... can we make a general page_is_ram() function that does what it
> > says? on x86 it can go via the e820 table, other architectures can do
> > whatever they need....
> > 
> 
> That would be very helpful. That should cover the remaining (ab)users
> of PageReserved.
> 
> It would probably be fastest to implement this with a page flag,
> however if swsusp and ioremap are the only users then it shouldn't
> be a problem to go through slower lookups (and this would remove the
> need for the PageValidRAM flag that I had worried about earlier).

I think swsusp can be modified to use PageNosave only and everything
that is not to be touched by swsusp should be marked as no-save.

Greets,
Rafael


-- 
- Would you tell me, please, which way I ought to go from here?
- That depends a good deal on where you want to get to.
		-- Lewis Carroll "Alice's Adventures in Wonderland"
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
