Date: Sun, 19 Dec 2004 17:00:08 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 4/10] alternate 4-level page tables patches
Message-ID: <20041220010008.GU771@holomorphy.com>
References: <20041218113252.GK771@holomorphy.com> <41C41ACE.7060002@yahoo.com.au> <20041218124635.GL771@holomorphy.com> <41C4C5C2.5000607@yahoo.com.au> <20041219002010.GN771@holomorphy.com> <Pine.LNX.4.58.0412181721520.22750@ppc970.osdl.org> <20041219020823.GP771@holomorphy.com> <Pine.LNX.4.58.0412182121020.22750@ppc970.osdl.org> <20041219060240.GQ771@holomorphy.com> <Pine.LNX.4.58.0412191014140.22750@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0412191014140.22750@ppc970.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Sat, 18 Dec 2004, William Lee Irwin III wrote:
>> If it's already been audited and there's nothing to do, all the better.

On Sun, Dec 19, 2004 at 10:17:44AM -0800, Linus Torvalds wrote:
> It's more an issue of "if they don't, it won't work". 
> That should be true at least for the "traditional" kind of ASI's, where
> the ASI space is smaller than the process space, and ASI's get re-used
> while a process is live anyway.
> Of course, who knows what evil things the ppc external hash does with the 
> thing. 
> Anyway, I don't think we should necessariyl remove the flush entirely, and
> the simple one-liner only did the "immediate free" thing without the
> complex "batch things up and free them only after a flush".


The "adversary argument" I used to brew up things to look for involved
eagerly flushing ASID's during exit(), marking the ASID dead at exit
on account of reliance on the flush, and reusing it without a flush due
to the death marker. I didn't bother coming up with more than one
possible scenario. Others will be visible while searching for one.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
