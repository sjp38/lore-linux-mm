Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DDEC06B01F1
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 19:01:45 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id o7JN1csD022827
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:01:38 -0700
Received: from pwj5 (pwj5.prod.google.com [10.241.219.69])
	by hpaq2.eem.corp.google.com with ESMTP id o7JN1ERC003431
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:01:37 -0700
Received: by pwj5 with SMTP id 5so1282943pwj.38
        for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:01:36 -0700 (PDT)
Date: Thu, 19 Aug 2010 16:01:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q Cleanup3 4/6] slub: Dynamically size kmalloc cache
 allocations
In-Reply-To: <alpine.DEB.2.00.1008191627100.5611@router.home>
Message-ID: <alpine.DEB.2.00.1008191600240.25634@chino.kir.corp.google.com>
References: <20100819203324.549566024@linux.com> <20100819203438.745611155@linux.com> <alpine.DEB.2.00.1008191405230.18994@chino.kir.corp.google.com> <alpine.DEB.2.00.1008191627100.5611@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010, Christoph Lameter wrote:

> Correct. Then we also do not need the sysfs_slab_add in
> create_kmalloc_cache.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

This doesn't apply on top of this patchset, it was generated from the 
entire SLUB+Q patchset (we don't have __ALIEN_CACHE yet).  Besides the 
conflicts, the patch is good.

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
