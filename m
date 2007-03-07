Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes
	nonlinear)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070307010756.b31c8190.akpm@linux-foundation.org>
References: <20070221023656.6306.246.sendpatchset@linux.site>
	 <20070221023735.6306.83373.sendpatchset@linux.site>
	 <20070306225101.f393632c.akpm@linux-foundation.org>
	 <20070307070853.GB15877@wotan.suse.de>
	 <20070307081948.GA9563@wotan.suse.de> <20070307082755.GA25733@elte.hu>
	 <E1HOrfO-0008AW-00@dorka.pomaz.szeredi.hu>
	 <20070307004709.432ddf97.akpm@linux-foundation.org>
	 <E1HOrsL-0008Dv-00@dorka.pomaz.szeredi.hu>
	 <20070307010756.b31c8190.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 07 Mar 2007 10:32:22 +0100
Message-Id: <1173259942.6374.125.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, mingo@elte.hu, npiggin@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-03-07 at 01:07 -0800, Andrew Morton wrote:
> On Wed, 07 Mar 2007 09:51:57 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:
> 
> > > > Dirty page accounting doesn't work either on
> > > > non-linear mappings
> > > 
> > > It doesn't?  Confused - these things don't have anything to do with each
> > > other do they?
> > 
> > Look in page_mkclean().  Where does it handle non-linear mappings?
> > 
> 
> OK, I'd forgotten about that.  It won't break dirty memory accounting,
> but it'll potentially break dirty memory balancing.
> 
> If we have the wrong page (due to nonlinear), page_check_address() will
> fail and we'll leave the pte dirty.  That puts us back to the pre-2.6.17
> algorithms and I guess it'll break the msync guarantees.
> 
> Peter, I thought we went through the nonlinear problem ages ago and decided
> it was OK?

Can recollect as much, I modelled it after page_referenced() and can't
find any VM_NONLINEAR specific code in there either.

Will have a hard look, but if its broken, then page_referenced if
equally broken it seems, which would make page reclaim funny in the
light of nonlinear mappings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
