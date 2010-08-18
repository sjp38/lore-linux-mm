Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BF04A6B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:46:25 -0400 (EDT)
Date: Wed, 18 Aug 2010 10:46:22 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q Cleanup 6/6] slub: Move gfpflag masking out of the
 hotpath
In-Reply-To: <alpine.DEB.2.00.1008171734150.21514@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008180958420.4025@router.home>
References: <20100817211118.958108012@linux.com> <20100817211137.816192692@linux.com> <alpine.DEB.2.00.1008171734150.21514@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Aug 2010, David Rientjes wrote:

> > +	gfpflags &= gfp_allowed_mask;
> >  	if (gfpflags & __GFP_WAIT)
> >  		local_irq_enable();
> >
>
> Couldn't this include the masking of __GFP_ZERO at the beginning of
> __slab_alloc()?

We could move it together but then the masking of GFP_ZERO has never done
anything and AFAICT is there because some people felt unsafe with the
masking already done nearer to the page alloc functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
