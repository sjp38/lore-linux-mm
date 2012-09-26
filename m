Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id BA8316B0062
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 00:18:05 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so143985pad.14
        for <linux-mm@kvack.org>; Tue, 25 Sep 2012 21:18:04 -0700 (PDT)
Date: Tue, 25 Sep 2012 21:18:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/slab: Fix kmem_cache_alloc_node_trace() declaration
In-Reply-To: <1348571229-844-2-git-send-email-elezegarcia@gmail.com>
Message-ID: <alpine.DEB.2.00.1209252115000.28360@chino.kir.corp.google.com>
References: <1348571229-844-1-git-send-email-elezegarcia@gmail.com> <1348571229-844-2-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: kernel-janitors@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, Pekka Enberg <penberg@kernel.org>

On Tue, 25 Sep 2012, Ezequiel Garcia wrote:

> The bug was introduced in commit 4052147c0afa
> "mm, slab: Match SLAB and SLUB kmem_cache_alloc_xxx_trace() prototype".
> 

This isn't a candidate for kernel-janitors@vger.kernel.org, these are 
patches that are one of Pekka's branches and would never make it to Linus' 
tree in this form.

> Cc: Pekka Enberg <penberg@kernel.org>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

So now we have this for SLAB:

extern void *kmem_cache_alloc_node_trace(size_t size,
					 struct kmem_cache *cachep,
					 gfp_t flags,
					 int nodeid);

and this for SLUB:

extern void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
					 gfp_t gfpflags,
					 int node, size_t size);

Would you like to send a follow-up patch to make these the same?  (My 
opinion is that the SLUB variant is the correct order.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
