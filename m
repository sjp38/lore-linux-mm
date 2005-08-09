Message-ID: <42F83D04.7090802@yahoo.com.au>
Date: Tue, 09 Aug 2005 15:20:04 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
References: <42F57FCA.9040805@yahoo.com.au>	 <200508090710.00637.phillips@arcor.de>	 <1123562392.4370.112.camel@localhost>  <42F83849.9090107@yahoo.com.au> <1123564294.4370.119.camel@localhost>
In-Reply-To: <1123564294.4370.119.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ncunningham@cyclades.com
Cc: Daniel Phillips <phillips@arcor.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Nigel Cunningham wrote:
> Hi Nick et al.
> 
> On Tue, 2005-08-09 at 14:59, Nick Piggin wrote:

>>>Changing the e820 code so it sets PageNosave instead of PageReserved,
>>>along with a couple of modifications in swsusp itself should get rid of
>>>the swsusp dependency.
>>>
>>
>>That would work for swsusp, but there are other users that want to
>>know if a struct page is valid ram (eg. ioremap), so in that case
>>swsusp would not be able to mess with the flag.
> 
> 
> Um. Mess with which flag? I guess you mean Reserved. I was saying that

Mess with PageNosave (if that is what we used to denote a struct page
not pointing to valid RAM).

Ie. when swsusp allocates its save map (or whatever it calls it), setting
PageNosave would make other parts of the kernel think the area is not
valid ram.

In other words - we can't combine swsusp's PageNosave with our mythical
PageValidRAM.

> imaging Reserved going away, so for the short term I'd be meaning making
> the e820 set both Nosave and Reserved for those pages (which is what the
> Suspend2 patches do so as to play nicely with swsusp - I don't use
> Reserved at all).
> 

In the short term, PageReserved can stay around - swsusp does still
work if I hadn't made that clear.

By the way - how does swsusp2 handle this problem if not using
PageReserved?


-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
