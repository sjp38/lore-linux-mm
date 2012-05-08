Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id ABCFA6B00EB
	for <linux-mm@kvack.org>; Tue,  8 May 2012 10:11:09 -0400 (EDT)
Date: Tue, 8 May 2012 09:11:07 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Using judgement !!c to judge per cpu has obj in
 fucntion has_cpu_slab().
In-Reply-To: <CAOtvUMctgcCrB_kCoKZki45_2i9XKzp-XLyfmNTxYwdFWSKYNQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205080909490.25669@router.home>
References: <201205080931539844949@gmail.com> <CAOtvUMctgcCrB_kCoKZki45_2i9XKzp-XLyfmNTxYwdFWSKYNQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: majianpeng <majianpeng@gmail.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

On Tue, 8 May 2012, Gilad Ben-Yossef wrote:

> diff --git a/mm/slub.c b/mm/slub.c
> index ffe13fd..d66afc4 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2040,7 +2040,7 @@ static bool has_cpu_slab(int cpu, void *info)
>  	struct kmem_cache *s = info;
>  	struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
>
> -	return !!(c->page);
> +	return !!(c->page && c->partial);

&&? Should this not be || ? W#e can also drop the !! now I think.

	return c->page || c->partial


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
