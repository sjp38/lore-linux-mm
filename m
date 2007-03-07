In-reply-to: <20070307010756.b31c8190.akpm@linux-foundation.org> (message from
	Andrew Morton on Wed, 7 Mar 2007 01:07:56 -0800)
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes
 nonlinear)
References: <20070221023656.6306.246.sendpatchset@linux.site>
	<20070221023735.6306.83373.sendpatchset@linux.site>
	<20070306225101.f393632c.akpm@linux-foundation.org>
	<20070307070853.GB15877@wotan.suse.de>
	<20070307081948.GA9563@wotan.suse.de>
	<20070307082755.GA25733@elte.hu>
	<E1HOrfO-0008AW-00@dorka.pomaz.szeredi.hu>
	<20070307004709.432ddf97.akpm@linux-foundation.org>
	<E1HOrsL-0008Dv-00@dorka.pomaz.szeredi.hu> <20070307010756.b31c8190.akpm@linux-foundation.org>
Message-Id: <E1HOsP0-0008K3-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 07 Mar 2007 10:25:42 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: mingo@elte.hu, npiggin@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

> > 
> > Look in page_mkclean().  Where does it handle non-linear mappings?
> > 
> 
> OK, I'd forgotten about that.  It won't break dirty memory accounting,
> but it'll potentially break dirty memory balancing.
> 
> If we have the wrong page (due to nonlinear), page_check_address() will
> fail and we'll leave the pte dirty.

It won't even get that far, because it only looks at vmas on
mapping->i_mmap, and not on i_mmap_nonlinear.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
