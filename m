Date: Sun, 18 Apr 2004 11:06:14 -0700
From: Marc Singer <elf@buici.com>
Subject: Re: vmscan.c heuristic adjustment for smaller systems
Message-ID: <20040418180614.GA29280@flea>
References: <20040418174743.GC28744@flea> <20040418175324.GB743@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040418175324.GB743@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Apr 18, 2004 at 10:53:24AM -0700, William Lee Irwin III wrote:
> On Sun, Apr 18, 2004 at 10:47:44AM -0700, Marc Singer wrote:
> > That has been my hypothesis all along.  But I have failed to prove it
> > to myself.  Please steer me if I've missed your point about flushing
> > TLB entries when we age PTEs.
> 
> Well, there's a point of some kind to it.

I don't think I understand what you mean.

> On Sun, Apr 18, 2004 at 10:47:44AM -0700, Marc Singer wrote:
> > So, I tried this.  Since I don't know the virtual address for a PTE in
> > the set_pte() routine, I changed it to flush the whole TLB whenever it
> > sets a hardware PTE entry to zero.  Yet, I still get the slow-down
> > behavior.  I also changed the TLB flush routines to always do a
> > complete TLB flush instead of flushing individual entries.  Still, no
> > change in the slow-down.
> 
> Actually ptep_to_address() should find the uvaddr for you.

The set_pte function is assembler coded.  For a proof of concept, I am
willing to be blunt.

> On Sun, Apr 18, 2004 at 10:47:44AM -0700, Marc Singer wrote:
> > So, if my slow-down is related to lazy TLB flushing then I am at a
> > loss to explain how.
> 
> I'm not going to tell ou what your results are.

Perhaps, though, this isn't such a bad result.  It could mean that the
lazy TLB flush is OK and that my bug is something different.  Or, it
could mean that I'm still doing the flush incorrectly and that that is
the correct solution were it done right.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
