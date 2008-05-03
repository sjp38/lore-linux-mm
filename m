Date: Sat, 3 May 2008 07:41:35 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/4] spufs: convert nopfn to fault
Message-ID: <20080503054135.GA15552@wotan.suse.de>
References: <20080502031903.GD11844@wotan.suse.de> <200805021406.38980.jk@ozlabs.org> <20080502044725.GI11844@wotan.suse.de> <200805021943.54638.jk@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200805021943.54638.jk@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Kerr <jk@ozlabs.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, jes@trained-monkey.org, cpw@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, May 02, 2008 at 07:43:53PM +1000, Jeremy Kerr wrote:
> Hi Nick,
> 
> > > Acked-by: Jeremy Kerr <jk@ozlabs.org>
> >
> > Great, thanks very much!
> 
> After more testing, it looks like these patches cause a huge increase in 
> load (ie, system is unresponsive for large amounts of time) for various 
> tests which depend on the fault path.
> 
> I need to get some quantitative numbers, but it looks like oprofile is 
> broken at the moment. More debugging coming..

OK, thanks for testing that... It _should_ be 100% equivalent really,
so it must be some problem in the conversion. Don't worry too much
about getting exact numbers because any noticable difference would be
a bug.

Hmm, in spufs_mem_mmap_fault, vm_insert_pfn should just take
address (corrected for 64K), rather than the uncorrected address I
gave it...

Can't see any other problems though. Is it getting stuck looping in
faults somehow?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
