Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 15C966B01F5
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 17:17:42 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o7ILHcc2029543
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 14:17:39 -0700
Received: from pwj6 (pwj6.prod.google.com [10.241.219.70])
	by kpbe17.cbf.corp.google.com with ESMTP id o7ILHZkm008096
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 14:17:37 -0700
Received: by pwj6 with SMTP id 6so552265pwj.30
        for <linux-mm@kvack.org>; Wed, 18 Aug 2010 14:17:37 -0700 (PDT)
Date: Wed, 18 Aug 2010 14:17:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q Cleanup2 2/6] slub: remove dynamic dma slab allocation
In-Reply-To: <20100818162637.055888444@linux.com>
Message-ID: <alpine.DEB.2.00.1008181417170.28227@chino.kir.corp.google.com>
References: <20100818162539.281413425@linux.com> <20100818162637.055888444@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Aug 2010, Christoph Lameter wrote:

> Remove the dynamic dma slab allocation since this causes too many issues with
> nested locks etc etc. The change avoids passing gfpflags into many functions.
> 
> V3->V4:
> - Create dma caches in kmem_cache_init() instead of kmem_cache_init_late().
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
