Date: Fri, 2 May 2008 06:47:25 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/4] spufs: convert nopfn to fault
Message-ID: <20080502044725.GI11844@wotan.suse.de>
References: <20080502031903.GD11844@wotan.suse.de> <20080502032214.GG11844@wotan.suse.de> <200805021406.38980.jk@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200805021406.38980.jk@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Kerr <jk@ozlabs.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, jes@trained-monkey.org, cpw@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, May 02, 2008 at 02:06:38PM +1000, Jeremy Kerr wrote:
> Hi Nick,
> 
> > -static unsigned long spufs_mem_mmap_nopfn(struct vm_area_struct
> > *vma, -					  unsigned long address)
> 
> Aside from the > 80 character lines, all is OK here.
> 
> Acked-by: Jeremy Kerr <jk@ozlabs.org>

Great, thanks very much!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
