Date: Sat, 18 Dec 2004 22:02:40 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 4/10] alternate 4-level page tables patches
Message-ID: <20041219060240.GQ771@holomorphy.com>
References: <20041218110608.GJ771@holomorphy.com> <41C411BD.6090901@yahoo.com.au> <20041218113252.GK771@holomorphy.com> <41C41ACE.7060002@yahoo.com.au> <20041218124635.GL771@holomorphy.com> <41C4C5C2.5000607@yahoo.com.au> <20041219002010.GN771@holomorphy.com> <Pine.LNX.4.58.0412181721520.22750@ppc970.osdl.org> <20041219020823.GP771@holomorphy.com> <Pine.LNX.4.58.0412182121020.22750@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0412182121020.22750@ppc970.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Sat, Dec 18, 2004 at 09:23:06PM -0800, Linus Torvalds wrote:
> Yes, we could avoid the flush entirely, since we've already "flushed" the 
> TLB by virtue of having switched to another TLB.
> And it's in no way x86-specific:

I'd say there's a little reliance on the semantics being emulated by
other architectures, but I doubt it strongly influences performance.


On Sat, 18 Dec 2004, William Lee Irwin III wrote:
>> The stale translations can't be left around for ASID-tagged TLB's, lest
>> the next user of the ASID inherit them.

On Sat, Dec 18, 2004 at 09:23:06PM -0800, Linus Torvalds wrote:
> We need to (and do) flush the TLB on ASID re-use, regardless. That's true
> in any case. 

If it's already been audited and there's nothing to do, all the better.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
