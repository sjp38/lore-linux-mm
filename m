Date: Wed, 7 Mar 2007 11:04:30 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070307100430.GA5080@wotan.suse.de>
References: <20070306225101.f393632c.akpm@linux-foundation.org> <20070307070853.GB15877@wotan.suse.de> <20070307081948.GA9563@wotan.suse.de> <20070307082755.GA25733@elte.hu> <E1HOrfO-0008AW-00@dorka.pomaz.szeredi.hu> <20070307004709.432ddf97.akpm@linux-foundation.org> <E1HOrsL-0008Dv-00@dorka.pomaz.szeredi.hu> <20070307010756.b31c8190.akpm@linux-foundation.org> <1173259942.6374.125.camel@twins> <20070307094503.GD8609@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070307094503.GD8609@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 07, 2007 at 10:45:03AM +0100, Nick Piggin wrote:
> On Wed, Mar 07, 2007 at 10:32:22AM +0100, Peter Zijlstra wrote:
> > 
> > Can recollect as much, I modelled it after page_referenced() and can't
> > find any VM_NONLINEAR specific code in there either.
> > 
> > Will have a hard look, but if its broken, then page_referenced if
> > equally broken it seems, which would make page reclaim funny in the
> > light of nonlinear mappings.
> 
> page_referenced is just an heuristic, and it ignores nonlinear mappings
> and the page which will get filtered down to try_to_unmap.
> 
> Page reclaim is already "funny" for nonlinear mappings, page_referenced
> is the least of its worries ;) It works, though.

Or, to be more helpful, unmap_mapping_range is what it should be
modelled on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
