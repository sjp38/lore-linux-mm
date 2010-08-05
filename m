Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 94B026B02A6
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 04:38:23 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o758cWdc032387
	for <linux-mm@kvack.org>; Thu, 5 Aug 2010 01:38:32 -0700
Received: from pzk3 (pzk3.prod.google.com [10.243.19.131])
	by kpbe12.cbf.corp.google.com with ESMTP id o758cVHl009523
	for <linux-mm@kvack.org>; Thu, 5 Aug 2010 01:38:31 -0700
Received: by pzk3 with SMTP id 3so2340318pzk.22
        for <linux-mm@kvack.org>; Thu, 05 Aug 2010 01:38:30 -0700 (PDT)
Date: Thu, 5 Aug 2010 01:38:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q3 00/23] SLUB: The Unified slab allocator (V3)
In-Reply-To: <alpine.DEB.2.00.1008041115500.11084@router.home>
Message-ID: <alpine.DEB.2.00.1008050136340.30889@chino.kir.corp.google.com>
References: <20100804024514.139976032@linux.com> <alpine.DEB.2.00.1008032138160.20049@chino.kir.corp.google.com> <alpine.DEB.2.00.1008041115500.11084@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Aug 2010, Christoph Lameter wrote:

> > This insta-reboots on my netperf benchmarking servers (but works with
> > numa=off), so I'll have to wait until I can hook up a serial before
> > benchmarking this series.
> 
> There are potential issues with
> 
> 1. The size of per cpu reservation on bootup and the new percpu code that
> allows allocations for per cpu areas during bootup. Sometime I wonder if I
> should just go back to static allocs for that.
> 
> 2. The topology information provided by the machine for the cache setup.
> 
> 3. My code of course.
> 

I bisected this to patch 8 but still don't have a bootlog.  I'm assuming 
in the meantime that something is kmallocing DMA memory on this machine 
prior to kmem_cache_init_late() and get_slab() is returning a NULL 
pointer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
