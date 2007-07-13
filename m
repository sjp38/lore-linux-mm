Subject: Re: mmu_gather changes & generalization
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.64.0707121715500.4887@blonde.wat.veritas.com>
References: <1184046405.6059.17.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0707112100050.16237@blonde.wat.veritas.com>
	 <1184195933.6059.111.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0707121715500.4887@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Fri, 13 Jul 2007 10:51:55 +1000
Message-Id: <1184287915.6059.163.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

> If you wait for next -mm, I think you'll find Martin Schwidefsky has
> done a little cleanup (including removing ptep_test_and_clear_dirty,
> which did indeed pose some problem when it had no examples of use);
> and Jan Beulich some other cleanups already in the last -mm (removing
> some unused macros like pte_exec).  But it sounds like you want to go
> a lot further.
> 
> Hmm, well, if your cross-building environment is good enough that you
> won't waste any of Andrew's time with the results, I guess go ahead.

I have compilers for x86 (&64) and sparc(&64) at hand (in addition to
ppc flavors of course), I'm not sure I have anything else but I can
always ask our local toolchain guru to setup something up :-)

I suppose I need at least ia64 and possibly mips & arm (though the later
seem to be harder to get the right version of the toolchain).
 
> Personally, I'm not in favour of removing every last unused macro:
> if only from a debugging or learning point of view, it can be useful
> to see what pte_exec is on each architecture, and it might be needed
> again tomorrow.  But I am very much in favour of reducing the spread
> of unnecessary difference between architectures, the quantity of
> evidence you have to wade through when considering them for changes.

I don't care about the small macros that just set/test bits like
pte_exec. I want to remove the ones that do more than that and are
unused (ptep_test_and_clear_dirty() was a good example, there was some
semantics subtleties vs. flushing or not flusing, etc...). Those things
need to go if they aren't used.

I'll have a look after the next -mm to see what's left. There may be
nothing left to cleanup :-)

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
