Message-ID: <42FB15C9.9050406@yahoo.com.au>
Date: Thu, 11 Aug 2005 19:09:29 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
References: <42F57FCA.9040805@yahoo.com.au>	 <200508090710.00637.phillips@arcor.de>	 <1123562392.4370.112.camel@localhost> <42F83849.9090107@yahoo.com.au>	 <20050809080853.A25492@flint.arm.linux.org.uk>	 <523240000.1123598289@[10.10.2.4]>	 <20050809204100.B29945@flint.arm.linux.org.uk> <1123666046.30257.226.camel@gaston>
In-Reply-To: <1123666046.30257.226.camel@gaston>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Russell King <rmk+lkml@arm.linux.org.uk>, "Martin J. Bligh" <mbligh@mbligh.org>, ncunningham@cyclades.com, Daniel Phillips <phillips@arcor.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:
> On Tue, 2005-08-09 at 20:41 +0100, Russell King wrote:
> 
>>On Tue, Aug 09, 2005 at 07:38:52AM -0700, Martin J. Bligh wrote:
>>
>>>pfn_valid() doesn't tell you it's RAM or not - it tells you whether you
>>>have a backing struct page for that address. Could be an IO mapped device,
>>>a small memory hole, whatever.
>>
>>The only things which have a struct page is RAM.  Nothing else does.
> 
> 
> Well, not anymore :)
> 

Well thanks everyone for the discussion and input. If I have missed
answering a question, please just mail me privately to let me know.

I guess that despite some architecture implementation differences,
everyone will be happy to see PageReserved go from core code. So
I will send Andrew the patches.

After that, we have a few options to move forward with completely
getting rid of the flag from the other funny places it has cropped
up. A portable page_is_ram() sounds like the best way to go, as it
would not use up a page flag.

As far as ioremap goes - I would rather completely disallow it from
remapping physical pages and enforce that where possible (eg. with
page_is_ram()).

However, these issues (page_is_ram, swsusp, ioremap) need not be
tackled right now. I will bring them up on the lists some time after
the core mm/ is working nicely without PageReserved.

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
