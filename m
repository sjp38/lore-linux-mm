Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id D85536B0044
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 05:59:51 -0400 (EDT)
Message-ID: <50238A10.1000606@parallels.com>
Date: Thu, 9 Aug 2012 13:59:44 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common11 [06/20] Extract a common function for kmem_cache_destroy
References: <20120808210129.987345284@linux.com> <20120808210210.088838748@linux.com>
In-Reply-To: <20120808210210.088838748@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 08/09/2012 01:01 AM, Christoph Lameter wrote:
> -void kmem_cache_destroy(struct kmem_cache *c)
> +void __kmem_cache_destroy(struct kmem_cache *c)
>  {
> -	mutex_lock(&slab_mutex);
> -	list_del(&c->list);
> -	mutex_unlock(&slab_mutex);
>  	kmemleak_free(c);
> -	if (c->flags & SLAB_DESTROY_BY_RCU)

which tree are you based on?

These lines you are removing doesn't seem to exist on Pekka's, and are
certainly not added in the previous patches. The patch fails to apply
because of that.

As a matter of fact, this removal was not present in your earlier series.

For now I'll manually edit it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
