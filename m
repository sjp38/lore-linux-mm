Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 820006B01F2
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 14:54:41 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o7HIsdwV006533
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 11:54:39 -0700
Received: from pxi14 (pxi14.prod.google.com [10.243.27.14])
	by wpaz17.hot.corp.google.com with ESMTP id o7HIrv4P013466
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 11:54:38 -0700
Received: by pxi14 with SMTP id 14so3409087pxi.24
        for <linux-mm@kvack.org>; Tue, 17 Aug 2010 11:54:38 -0700 (PDT)
Date: Tue, 17 Aug 2010 11:54:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q3 00/23] SLUB: The Unified slab allocator (V3)
In-Reply-To: <alpine.DEB.2.00.1008171346530.13665@router.home>
Message-ID: <alpine.DEB.2.00.1008171153490.21770@chino.kir.corp.google.com>
References: <20100804024514.139976032@linux.com> <alpine.DEB.2.00.1008032138160.20049@chino.kir.corp.google.com> <alpine.DEB.2.00.1008041115500.11084@router.home> <alpine.DEB.2.00.1008050136340.30889@chino.kir.corp.google.com> <alpine.DEB.2.00.1008051231400.6787@router.home>
 <alpine.DEB.2.00.1008151627450.27137@chino.kir.corp.google.com> <alpine.DEB.2.00.1008171217440.11915@router.home> <alpine.DEB.2.00.1008171052500.6486@chino.kir.corp.google.com> <alpine.DEB.2.00.1008171346530.13665@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@kernel.dk>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Aug 2010, Christoph Lameter wrote:

> > I didn't know if that was a debugging patch for me or if you wanted to
> > push that as part of your series, I'm not sure if you actually need to
> > move it to kmem_cache_init() now that slub_state is protected by
> > slub_lock.  I'm not sure if we want to allocate DMA objects between
> > kmem_cache_init() and kmem_cache_init_late().
> 
> Drivers may allocate dma buffers during initialization.
> 

Ok, I moved the DMA cache creation from kmem_cache_init_late() to 
kmem_cache_init().  Note: the kasprintf() will need to use GFP_NOWAIT and 
not GFP_KERNEL now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
