Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 5C8266B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 02:45:54 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id 13so6330376lba.2
        for <linux-mm@kvack.org>; Wed, 10 Jul 2013 23:45:52 -0700 (PDT)
Message-ID: <51DE549F.9070505@kernel.org>
Date: Thu, 11 Jul 2013 09:45:51 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/slub.c: remove 'per_cpu' which is useless variable
References: <51DA734B.4060608@asianux.com>
In-Reply-To: <51DA734B.4060608@asianux.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: cl@linux-foundation.org, mpm@selenic.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Hi,

On 07/08/2013 11:07 AM, Chen Gang wrote:
> Remove 'per_cpu', since it is useless now after the patch: "205ab99
> slub: Update statistics handling for variable order slabs".

Whoa, that's a really old commit. Christoph?

> Also beautify code with tab alignment.

That needs to be a separate patch.

>
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>   mm/slub.c |   17 ++++++-----------
>   1 files changed, 6 insertions(+), 11 deletions(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 2caaa67..aa847eb 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -4271,12 +4271,10 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
>   	int node;
>   	int x;
>   	unsigned long *nodes;
> -	unsigned long *per_cpu;
>
> -	nodes = kzalloc(2 * sizeof(unsigned long) * nr_node_ids, GFP_KERNEL);
> +	nodes = kzalloc(sizeof(unsigned long) * nr_node_ids, GFP_KERNEL);
>   	if (!nodes)
>   		return -ENOMEM;
> -	per_cpu = nodes + nr_node_ids;
>
>   	if (flags & SO_CPU) {
>   		int cpu;
> @@ -4307,8 +4305,6 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
>   				total += x;
>   				nodes[node] += x;
>   			}
> -
> -			per_cpu[node]++;
>   		}
>   	}
>
> @@ -4318,12 +4314,11 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
>   		for_each_node_state(node, N_NORMAL_MEMORY) {
>   			struct kmem_cache_node *n = get_node(s, node);
>
> -		if (flags & SO_TOTAL)
> -			x = atomic_long_read(&n->total_objects);
> -		else if (flags & SO_OBJECTS)
> -			x = atomic_long_read(&n->total_objects) -
> -				count_partial(n, count_free);
> -
> +			if (flags & SO_TOTAL)
> +				x = atomic_long_read(&n->total_objects);
> +			else if (flags & SO_OBJECTS)
> +				x = atomic_long_read(&n->total_objects) -
> +					count_partial(n, count_free);
>   			else
>   				x = atomic_long_read(&n->nr_slabs);
>   			total += x;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
