Date: Wed, 23 Jan 2008 00:39:50 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] #ifdef very expensive debug check in page fault path
Message-ID: <20080122233950.GA29901@wotan.suse.de>
References: <1200506488.32116.11.camel@cotte.boeblingen.de.ibm.com> <20080116234540.GB29823@wotan.suse.de> <20080116161021.c9a52c0f.akpm@linux-foundation.org> <Pine.LNX.4.64.0801182023350.5249@blonde.site> <479469A4.6090607@de.ibm.com> <Pine.LNX.4.64.0801222226350.28823@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801222226350.28823@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: carsteno@de.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, mschwid2@linux.vnet.ibm.com, Holger Wolf <holger.wolf@de.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 22, 2008 at 10:35:17PM +0000, Hugh Dickins wrote:
> On Mon, 21 Jan 2008, Carsten Otte wrote:
> > Hugh Dickins wrote:
> > > 
> > > Well: that patch still gets my Nack, but I guess I'm too late.  If
> > > s390 pagetables are better protected than x86 ones, add an s390 ifdef?
> > 
> > The alternative would be to just make
> > #define pfn_valid(pfn) (1)
> > on s390. That would also get _us_ rid of the check while others do benefit. We
> > would trap access to mem_map beyond its limits because we don't have a kernel
> > mapping there. For us, it would not silently corrupt things but crash proper.
> 
> Whilst I quite like the sound of that, I wonder whether it's safe to
> change s390's pfn_valid (rather surprisingly) for all its users.  And
> note that nobody but me has voiced any regret at the loss of the check.

I did want to get rid of the test, but not in a "sneak it in before he
notices" way. So I am disappointed it was merged before you replied.


> My guess is we let it rest for now, and reconsider if a case comes up
> later which would have got caught by the check (but the problem is that
> such a case is much harder to identify than it was).

The only cases I had imagined were repeatable things like a bug in pte
manipulation somewhere, which will hopefully be caught with
CONFIG_DEBUG_VM turned on. 

Are there many other cases where the test is useful? For hardware
failures, I'd say not -- those just tend to waste developers time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
