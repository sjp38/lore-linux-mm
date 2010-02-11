Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 546386B0078
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 16:44:11 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o1BLi8h9021124
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 13:44:08 -0800
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by kpbe20.cbf.corp.google.com with ESMTP id o1BLhQag006693
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 13:44:07 -0800
Received: by pzk1 with SMTP id 1so253567pzk.16
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 13:44:07 -0800 (PST)
Date: Thu, 11 Feb 2010 13:44:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] [2/4] SLAB: Separate node initialization into separate
 function
In-Reply-To: <20100211205402.02E7EB1978@basil.firstfloor.org>
Message-ID: <alpine.DEB.2.00.1002111341590.8809@chino.kir.corp.google.com>
References: <20100211953.850854588@firstfloor.org> <20100211205402.02E7EB1978@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com
List-ID: <linux-mm.kvack.org>

On Thu, 11 Feb 2010, Andi Kleen wrote:

> Index: linux-2.6.32-memhotadd/mm/slab.c
> ===================================================================
> --- linux-2.6.32-memhotadd.orig/mm/slab.c
> +++ linux-2.6.32-memhotadd/mm/slab.c
> @@ -1158,19 +1158,9 @@ free_array_cache:
>  	}
>  }
>  
> -static int __cpuinit cpuup_prepare(long cpu)
> +static int slab_node_prepare(int node)

I still think this deserves a comment saying that slab_node_prepare() 
requires cache_chain_mutex, I'm not sure people interested in node hotadd 
would be concerned with whether the implementation needs to iterate slab 
caches or not.

Otherwise:

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
