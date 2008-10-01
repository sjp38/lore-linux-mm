Message-ID: <48E3B904.7020206@cs.helsinki.fi>
Date: Wed, 01 Oct 2008 20:53:08 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 2/3] cpu alloc: Remove slub fields
References: <20080919203703.312007962@quilx.com> <20080919203724.240858174@quilx.com>
In-Reply-To: <20080919203724.240858174@quilx.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

Christoph Lameter wrote:
> @@ -2196,8 +2163,11 @@
>  	if (!init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
>  		goto error;
>  
> -	if (alloc_kmem_cache_cpus(s, gfpflags & ~SLUB_DMA))
> +	s->cpu_slab = CPU_ALLOC(struct kmem_cache_cpu,
> +				(flags & ~SLUB_DMA) | __GFP_ZERO);
> +	if (!s->cpu_slab)
>  		return 1;

This should be s->cpu_slab, no?

> +
>  	free_kmem_cache_nodes(s);
>  error:
>  	if (flags & SLAB_PANIC)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
