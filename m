Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 2CD776B0032
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 13:49:45 -0400 (EDT)
Date: Thu, 22 Aug 2013 17:49:43 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 02/16] slab: change return type of kmem_getpages() to
 struct page
In-Reply-To: <1377161065-30552-3-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000140a725706c-27ed3820-ef32-4388-825a-de582055d91d-000000@email.amazonses.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com> <1377161065-30552-3-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 22 Aug 2013, Joonsoo Kim wrote:

> @@ -2042,7 +2042,7 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep, struct slab *slab
>   */
>  static void slab_destroy(struct kmem_cache *cachep, struct slab *slabp)
>  {
> -	void *addr = slabp->s_mem - slabp->colouroff;
> +	struct page *page = virt_to_head_page(slabp->s_mem);
>
>  	slab_destroy_debugcheck(cachep, slabp);
>  	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU)) {

Ok so this removes slab offset management. The use of a struct page
pointer therefore results in coloring support to be not possible anymore.

I would suggest to have a separate patch for coloring removal before this
patch. It seems that the support is removed in two different patches now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
