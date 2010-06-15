Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 81BFC6B0258
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 17:41:15 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o5FLfClW005360
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 14:41:12 -0700
Received: from pwj1 (pwj1.prod.google.com [10.241.219.65])
	by kpbe15.cbf.corp.google.com with ESMTP id o5FLf9Aw014523
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 14:41:10 -0700
Received: by pwj1 with SMTP id 1so2795297pwj.11
        for <linux-mm@kvack.org>; Tue, 15 Jun 2010 14:41:09 -0700 (PDT)
Date: Tue, 15 Jun 2010 14:41:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: slub: Use kmem_cache flags to detect if slab is in debugging
 mode.
In-Reply-To: <alpine.DEB.2.00.1006151404160.10865@router.home>
Message-ID: <alpine.DEB.2.00.1006151440540.20327@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006151404160.10865@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 2010, Christoph Lameter wrote:

> Subject: slub: Use kmem_cache flags to detect if slab is in debugging mode.
> 
> The cacheline with the flags is reachable from the hot paths after the
> percpu allocator changes went in. So there is no need anymore to put a
> flag into each slab page. Get rid of the SlubDebug flag and use
> the flags in kmem_cache instead.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
