Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2F9366B023C
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 17:39:35 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o5FLdSCr001010
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 14:39:30 -0700
Received: from pvd12 (pvd12.prod.google.com [10.241.209.204])
	by wpaz29.hot.corp.google.com with ESMTP id o5FLdQrA030713
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 14:39:27 -0700
Received: by pvd12 with SMTP id 12so209491pvd.15
        for <linux-mm@kvack.org>; Tue, 15 Jun 2010 14:39:26 -0700 (PDT)
Date: Tue, 15 Jun 2010 14:39:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 4/4] slub: remove gfp_flags argument from
 create_kmalloc_cache
In-Reply-To: <alpine.DEB.2.00.1006151231400.9031@router.home>
Message-ID: <alpine.DEB.2.00.1006151438220.20327@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006082347440.30606@chino.kir.corp.google.com> <alpine.DEB.2.00.1006082348450.30606@chino.kir.corp.google.com> <alpine.DEB.2.00.1006091124240.21686@router.home> <4C0FC509.9060605@cs.helsinki.fi>
 <alpine.DEB.2.00.1006151231400.9031@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 2010, Christoph Lameter wrote:

> > > Acked-by: Christoph Lameter <cl@linux-foundation.org>
> >
> > Applied, thanks!
> >
> 
> Breaks DMA cache creation since one can no longer set the
> SLAB_CACHE_DMA on create_kmalloc_cache.
> 

How?  There are no callers to create_kmalloc_cache() that pass anything 
except GFP_NOWAIT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
