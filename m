Date: Tue, 6 May 2008 10:38:09 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/4] spufs: convert nopfn to fault
Message-ID: <20080506083809.GA10141@wotan.suse.de>
References: <20080502031903.GD11844@wotan.suse.de> <200805021943.54638.jk@ozlabs.org> <20080503054135.GA15552@wotan.suse.de> <200805061301.26791.jk@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200805061301.26791.jk@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Kerr <jk@ozlabs.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, jes@trained-monkey.org, cpw@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, May 06, 2008 at 01:01:26PM +1000, Jeremy Kerr wrote:
> Hi Nick,
> 
> > Hmm, in spufs_mem_mmap_fault, vm_insert_pfn should just take
> > address (corrected for 64K), rather than the uncorrected address I
> > gave it...
> 
> Yep, using the 'address' var for vm_insert_pfn fixes the problem for me.

Ah, thanks for testing. Will send an updated patch also with the warning
you noticed fixed.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
