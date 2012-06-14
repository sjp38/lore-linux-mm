Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 9A6D66B0069
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 10:46:18 -0400 (EDT)
Date: Thu, 14 Jun 2012 09:46:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [08/20] Extract common code for kmem_cache_create()
In-Reply-To: <4FD9F347.2020409@parallels.com>
Message-ID: <alpine.DEB.2.00.1206140945130.32075@router.home>
References: <20120613152451.465596612@linux.com> <20120613152519.255119144@linux.com> <4FD99D9B.6060000@parallels.com> <alpine.DEB.2.00.1206140912250.32075@router.home> <4FD9F347.2020409@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On Thu, 14 Jun 2012, Glauber Costa wrote:

> That's how my code reads:
>
> #ifdef CONFIG_DEBUG_VM
> if (!name || in_interrupt() || size < sizeof(void *) ||
>     size    KMALLOC_MAX_SIZE) {
>
>     if ((flags & SLAB_PANIC))
>         panic("kmem_cache_create(%s) integrity check failed\n", name);
>     printk(KERN_ERR "kmem_cache_create(%s) integrity check failed\n",
>            name);
>     return NULL;
> }
> #endif
>
> How can it put any patch later than this in trouble ?

Well this is duplicating the exit handling which I would like to avoid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
