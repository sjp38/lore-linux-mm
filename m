Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7AE37600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 12:27:12 -0500 (EST)
Date: Mon, 4 Jan 2010 11:27:07 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH v2] slab: initialize unused alien cache entry as NULL at
 alloc_alien_cache().
In-Reply-To: <4B31E9C3.6010109@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1001041126340.7191@router.home>
References: <4B30BDA8.1070904@linux.intel.com> <1261521485.3000.1692.camel@calx> <4B31E9C3.6010109@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Haicheng Li <haicheng.li@linux.intel.com>
Cc: linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, andi@firstfloor.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Dec 2009, Haicheng Li wrote:

> @@ -966,18 +966,16 @@ static void *alternate_node_alloc(struct kmem_cache *,
> gfp_t);
>  static struct array_cache **alloc_alien_cache(int node, int limit, gfp_t gfp)
>  {
>  	struct array_cache **ac_ptr;
> -	int memsize = sizeof(void *) * nr_node_ids;
> +	int memsize = sizeof(void *) * MAX_NUMNODES;
>  	int i;

Remove this change and I will ack the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
