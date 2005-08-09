Message-ID: <42F88514.9080104@yahoo.com.au>
Date: Tue, 09 Aug 2005 20:27:32 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
References: <42F57FCA.9040805@yahoo.com.au> <200508090710.00637.phillips@arcor.de> <1123562392.4370.112.camel@localhost> <42F83849.9090107@yahoo.com.au> <20050809080853.A25492@flint.arm.linux.org.uk> <Pine.LNX.4.61.0508091012480.10693@goblin.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.61.0508091012480.10693@goblin.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Russell King <rmk+lkml@arm.linux.org.uk>, ncunningham@cyclades.com, Daniel Phillips <phillips@arcor.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:

> 
> You're right (though I imagine might sometimes be holes rather than RAM).
> 

Yep. These holes are what I have in mind, and random other things
like the !(bad_ppro && page_kills_ppro(pfn)) check.

[...]

> I think Nick is treating the "use" of PageReserved in ioremap much too
> reverentially.  Fine to leave its removal from there to a later stage,
> but why shouldn't that also be removed?
> 

Well, as far as I had been able to gather, ioremap is trying to
ensure it does indeed only hit one of these holes, and not valid
RAM. I thought the fact that it *won't* bail out when encountering
kernel text or remap_pfn_range'ed pages was only due to PG_reserved
being the proverbial jack of all trades, master of none.

I could be wrong here though.

But in either case: I agree that it is probably not a great loss
to remove the check, although considering it will be needed for
swsusp anyway...

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
