Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 69C356B02C1
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 14:57:40 -0400 (EDT)
Date: Thu, 19 Aug 2010 13:57:47 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q Cleanup2 5/6] slub: Extract hooks for memory checkers from
 hotpaths
In-Reply-To: <alpine.DEB.2.00.1008181414040.11059@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008191357220.1839@router.home>
References: <20100818162539.281413425@linux.com> <20100818162638.772506283@linux.com> <alpine.DEB.2.00.1008181414040.11059@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Aug 2010, David Rientjes wrote:

> > -	if (should_failslab(s->objsize, gfpflags, s->flags))
> > +	if (!slab_pre_alloc_hook(s, gfpflags))
>
> Still inverted.

Argh. This patch was not refreshed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
