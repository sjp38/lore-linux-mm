Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 079A56B01C8
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 13:36:56 -0400 (EDT)
Date: Tue, 15 Jun 2010 12:33:28 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 4/4] slub: remove gfp_flags argument from
 create_kmalloc_cache
In-Reply-To: <4C0FC509.9060605@cs.helsinki.fi>
Message-ID: <alpine.DEB.2.00.1006151231400.9031@router.home>
References: <alpine.DEB.2.00.1006082347440.30606@chino.kir.corp.google.com> <alpine.DEB.2.00.1006082348450.30606@chino.kir.corp.google.com> <alpine.DEB.2.00.1006091124240.21686@router.home> <4C0FC509.9060605@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 Jun 2010, Pekka Enberg wrote:

> Christoph Lameter wrote:
> > Acked-by: Christoph Lameter <cl@linux-foundation.org>
>
> Applied, thanks!
>

Breaks DMA cache creation since one can no longer set the
SLAB_CACHE_DMA on create_kmalloc_cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
