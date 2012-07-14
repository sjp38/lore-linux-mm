Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id C71116B005D
	for <linux-mm@kvack.org>; Sat, 14 Jul 2012 05:18:27 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so8297797pbb.14
        for <linux-mm@kvack.org>; Sat, 14 Jul 2012 02:18:27 -0700 (PDT)
Date: Sat, 14 Jul 2012 02:18:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
In-Reply-To: <1342221125.17464.8.camel@lorien2>
Message-ID: <alpine.DEB.2.00.1207140216040.20297@chino.kir.corp.google.com>
References: <1342221125.17464.8.camel@lorien2>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shuah Khan <shuah.khan@hp.com>
Cc: cl@linux.com, penberg@kernel.org, glommer@parallels.com, js1304@gmail.com, shuahkhan@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 13 Jul 2012, Shuah Khan wrote:

> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 12637ce..aa3ca5b 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -98,7 +98,9 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
>  
>  	s = __kmem_cache_create(name, size, align, flags, ctor);
>  
> +#ifdef CONFIG_DEBUG_VM
>  oops:
> +#endif
>  	mutex_unlock(&slab_mutex);
>  	put_online_cpus();
>  

Tip: gcc allows label attributes so you could actually do

oops: __maybe_unused

to silence the warning and do the same for the "out" label later in the 
function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
