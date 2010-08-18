Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 229486B01F2
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 10:58:28 -0400 (EDT)
Date: Wed, 18 Aug 2010 09:58:24 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q Cleanup 5/6] slub: Extract hooks for memory checkers from
 hotpaths
In-Reply-To: <alpine.DEB.2.00.1008171726210.21514@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008180957250.4025@router.home>
References: <20100817211118.958108012@linux.com> <20100817211137.241962968@linux.com> <alpine.DEB.2.00.1008171726210.21514@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Aug 2010, David Rientjes wrote:

> > -	might_sleep_if(gfpflags & __GFP_WAIT);
> > -
> > -	if (should_failslab(s->objsize, gfpflags, s->flags))
> > +	if (!slab_pre_alloc_hook(s, gfpflags))
>
> That's inverted, it should be slab_pre_alloc_hook()?

Correct.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
