Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 149BE6B01F5
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 19:39:35 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id o7JNdXn3004176
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:39:33 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by kpbe13.cbf.corp.google.com with ESMTP id o7JNdWWU025424
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:39:32 -0700
Received: by pwi5 with SMTP id 5so1499342pwi.26
        for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:39:31 -0700 (PDT)
Date: Thu, 19 Aug 2010 16:39:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q Cleanup3 4/6] slub: Dynamically size kmalloc cache
 allocations
In-Reply-To: <alpine.DEB.2.00.1008191819420.7903@router.home>
Message-ID: <alpine.DEB.2.00.1008191638390.29676@chino.kir.corp.google.com>
References: <20100819203324.549566024@linux.com> <20100819203438.745611155@linux.com> <alpine.DEB.2.00.1008191405230.18994@chino.kir.corp.google.com> <alpine.DEB.2.00.1008191627100.5611@router.home> <alpine.DEB.2.00.1008191600240.25634@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1008191819420.7903@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010, Christoph Lameter wrote:

> Right. I will merge this correctly for the next release that has all
> patches acked by you.
> 

It would really be nice to get rid of all the #ifdefs in kmem_cache_init() 
for CONFIG_NUMA by extracting them to helper functions if you're 
interested.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
