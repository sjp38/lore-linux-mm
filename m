Date: Sat, 18 Dec 2004 21:23:06 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH 4/10] alternate 4-level page tables patches
In-Reply-To: <20041219020823.GP771@holomorphy.com>
Message-ID: <Pine.LNX.4.58.0412182121020.22750@ppc970.osdl.org>
References: <20041218095050.GC338@wotan.suse.de> <41C40125.3060405@yahoo.com.au>
 <20041218110608.GJ771@holomorphy.com> <41C411BD.6090901@yahoo.com.au>
 <20041218113252.GK771@holomorphy.com> <41C41ACE.7060002@yahoo.com.au>
 <20041218124635.GL771@holomorphy.com> <41C4C5C2.5000607@yahoo.com.au>
 <20041219002010.GN771@holomorphy.com> <Pine.LNX.4.58.0412181721520.22750@ppc970.osdl.org>
 <20041219020823.GP771@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>


On Sat, 18 Dec 2004, William Lee Irwin III wrote:
> 
> For x86-style MMU's you could literally not bother flushing the TLB at
> all, since you'll just switch to another set of pagetables.

Yes, we could avoid the flush entirely, since we've already "flushed" the 
TLB by virtue of having switched to another TLB.

And it's in no way x86-specific:

> The stale translations can't be left around for ASID-tagged TLB's, lest
> the next user of the ASID inherit them.

We need to (and do) flush the TLB on ASID re-use, regardless. That's true
in any case. 

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
