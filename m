Date: Wed, 1 Aug 2007 02:23:13 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] balance-on-fork NUMA placement
Message-ID: <20070801002313.GC31006@wotan.suse.de>
References: <20070731054142.GB11306@wotan.suse.de> <200707311114.09284.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200707311114.09284.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 31, 2007 at 11:14:08AM +0200, Andi Kleen wrote:
> On Tuesday 31 July 2007 07:41, Nick Piggin wrote:
> 
> > I haven't given this idea testing yet, but I just wanted to get some
> > opinions on it first. NUMA placement still isn't ideal (eg. tasks with
> > a memory policy will not do any placement, and process migrations of
> > course will leave the memory behind...), but it does give a bit more
> > chance for the memory controllers and interconnects to get evenly
> > loaded.
> 
> I didn't think slab honored mempolicies by default? 
> At least you seem to need to set special process flags.
> 
> > NUMA balance-on-fork code is in a good position to allocate all of a new
> > process's memory on a chosen node. However, it really only starts
> > allocating on the correct node after the process starts running.
> >
> > task and thread structures, stack, mm_struct, vmas, page tables etc. are
> > all allocated on the parent's node.
> 
> The page tables should be only allocated when the process runs; except
> for the PGD.

We certainly used to copy all page tables on fork. Not any more, but we
must still copy anonymous page tables.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
