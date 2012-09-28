Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 0893C6B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 04:40:02 -0400 (EDT)
Message-ID: <50656196.2000101@parallels.com>
Date: Fri, 28 Sep 2012 12:36:38 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK1 [07/13] slab: Use common kmalloc_index/kmalloc_size functions
References: <20120926200005.911809821@linux.com> <0000013a043aca15-00293133-8d9b-469d-afa7-b00ac0bf1015-000000@email.amazonses.com>
In-Reply-To: <0000013a043aca15-00293133-8d9b-469d-afa7-b00ac0bf1015-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 09/27/2012 12:18 AM, Christoph Lameter wrote:
> Make slab use the common functions. We can get rid of a lot
> of old ugly stuff as a results. Among them the sizes
> array and the weird include/linux/kmalloc_sizes file and
> some pretty bad #include statements in slab_def.h.
> 
> The one thing that is different in slab is that the 32 byte
> cache will also be created for arches that have page sizes
> larger than 4K. There are numerous smaller allocations that
> SLOB and SLUB can handle better because of their support for
> smaller allocation sizes so lets keep the 32 byte slab also
> for arches with > 4K pages.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 

I believe this makes sense, and the code looks better now.

Reviewed-by: Glauber Costa <glommer@parallels.com>

One nitpick:

>  
> @@ -185,26 +169,19 @@ static __always_inline void *kmalloc_nod
>  	struct kmem_cache *cachep;
>  
>  	if (__builtin_constant_p(size)) {
> -		int i = 0;
> +		int i;
>  

Although this is technically correct, the former is correct as well, and
this end up only adding churn to the patch.

Should you decide to remove it, there is another instance of this a bit
more down.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
