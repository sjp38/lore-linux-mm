Message-ID: <42F83849.9090107@yahoo.com.au>
Date: Tue, 09 Aug 2005 14:59:53 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
References: <42F57FCA.9040805@yahoo.com.au>	 <200508090710.00637.phillips@arcor.de> <1123562392.4370.112.camel@localhost>
In-Reply-To: <1123562392.4370.112.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ncunningham@cyclades.com
Cc: Daniel Phillips <phillips@arcor.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Nigel Cunningham wrote:
> Hi.
> 
> On Tue, 2005-08-09 at 07:09, Daniel Phillips wrote:
> 
>>>It doesn't look like they'll be able to easily free up a page
>>>flag for 2 reasons. First, PageReserved will probably be kept
>>>around for at least one release. Second, swsusp and some arch
>>>code (ioremap) wants to know about struct pages that don't point
>>>to valid RAM - currently they use PageReserved, but we'll probably
>>>just introduce a PageValidRAM or something when PageReserved goes.
> 
> 
> Changing the e820 code so it sets PageNosave instead of PageReserved,
> along with a couple of modifications in swsusp itself should get rid of
> the swsusp dependency.
> 

That would work for swsusp, but there are other users that want to
know if a struct page is valid ram (eg. ioremap), so in that case
swsusp would not be able to mess with the flag.

I do think swsusp should (and can, quite easily though I may have
missed something) consolidate PG_nosave and PG_nosave_free, however
that's out of the scope of this patch.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
