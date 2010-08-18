Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F3BBF6B01F7
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 17:18:02 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id o7ILI0x1015177
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 14:18:00 -0700
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by hpaq1.eem.corp.google.com with ESMTP id o7ILHwOI017657
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 14:17:59 -0700
Received: by pxi7 with SMTP id 7so637427pxi.11
        for <linux-mm@kvack.org>; Wed, 18 Aug 2010 14:17:58 -0700 (PDT)
Date: Wed, 18 Aug 2010 14:17:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q Cleanup2 3/6] slub: Remove static kmem_cache_cpu array for
 boot
In-Reply-To: <20100818162637.630543318@linux.com>
Message-ID: <alpine.DEB.2.00.1008181417400.28227@chino.kir.corp.google.com>
References: <20100818162539.281413425@linux.com> <20100818162637.630543318@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 18 Aug 2010, Christoph Lameter wrote:

> The percpu allocator can now handle allocations during early boot.
> So drop the static kmem_cache_cpu array.
> 
> Cc: Tejun Heo <tj@kernel.org>
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
