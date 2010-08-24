Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0CFBD6B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 16:21:58 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o7OKOMrS025578
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 13:24:25 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by kpbe18.cbf.corp.google.com with ESMTP id o7OKNumO018104
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 13:24:21 -0700
Received: by pzk2 with SMTP id 2so3073055pzk.20
        for <linux-mm@kvack.org>; Tue, 24 Aug 2010 13:24:20 -0700 (PDT)
Date: Tue, 24 Aug 2010 13:24:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] slob: fix gfp flags for order-0 page allocations
In-Reply-To: <alpine.DEB.2.00.1008241036250.344@router.home>
Message-ID: <alpine.DEB.2.00.1008241323400.21242@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008221615350.29062@chino.kir.corp.google.com>  <1282623994.10679.921.camel@calx>  <alpine.DEB.2.00.1008232134480.25742@chino.kir.corp.google.com> <1282663241.10679.958.camel@calx>
 <alpine.DEB.2.00.1008241036250.344@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2010, Christoph Lameter wrote:

> > kmalloc-32        1113344 1113344     32  128    1 : tunables    0    0
> > 0 : slabdata   8698   8698      0
> >
> > That's /proc/slabinfo on my laptop with SLUB. It looks like my last
> > reboot popped me back to 2.6.33 so it may also be old news, but I
> > couldn't spot any reports with Google.
> 
> Boot with "slub_debug" as a kernel parameter
> 
> and then do a
> 
> cat /sys/kernel/slab/kmalloc-32/alloc_calls
> 
> to find the caller allocating the objets.
> 

I'd suspect this was anon_vma, and enabling CONFIG_DEBUG_KMEMLEAK would 
probably reveal exactly where it's getting leaked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
