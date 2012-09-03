Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id AB8B86B005D
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 11:15:49 -0400 (EDT)
Message-ID: <5044C8E7.4000001@parallels.com>
Date: Mon, 3 Sep 2012 19:12:39 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C13 [14/14] Move kmem_cache refcounting to common code
References: <20120824160903.168122683@linux.com> <00000139596cab0a-61fcd4d7-52b5-4e16-89de-57c8df4dc8a4-000000@email.amazonses.com>
In-Reply-To: <00000139596cab0a-61fcd4d7-52b5-4e16-89de-57c8df4dc8a4-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 08/24/2012 08:17 PM, Christoph Lameter wrote:
> Index: linux/mm/slob.c
> ===================================================================
> --- linux.orig/mm/slob.c	2012-08-22 10:27:54.846388442 -0500
> +++ linux/mm/slob.c	2012-08-22 10:28:31.658969127 -0500
> @@ -524,8 +524,6 @@ int __kmem_cache_create(struct kmem_cach
>  	if (c->align < align)
>  		c->align = align;
>  
> -	kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
> -	c->refcount = 1;
>  	return 0;
>  }
>  
Is the removal of kmemleak_alloc intended ?
Nothing about that is mentioned in the changelog.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
