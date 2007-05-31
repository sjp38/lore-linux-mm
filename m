Date: Thu, 31 May 2007 12:51:33 -0700
From: Zach Brown <zach.brown@oracle.com>
Subject: Re: [RFC 2/4] CONFIG_STABLE: Switch off kmalloc(0) tests in slab allocators
Message-ID: <20070531195133.GK5488@mami.zabbo.net>
References: <20070531002047.702473071@sgi.com> <20070531003012.532539202@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070531003012.532539202@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> +#ifndef CONFIG_STABLE
>  	/*
>  	 * We should return 0 if size == 0 (which would result in the
>  	 * kmalloc caller to get NULL) but we use the smallest object
> @@ -81,6 +82,7 @@ static inline int kmalloc_index(size_t s
>  	 * we can discover locations where we do 0 sized allocations.
>  	 */
>  	WARN_ON_ONCE(size == 0);
> +#endif

> +#ifndef CONFIG_STABLE
>  	WARN_ON_ONCE(size == 0);
> +#endif

I wonder if there wouldn't be value in making a WARN_*() variant that
contained the ifdef internally so we could lose these tedious
surrounding ifdefs in call sites.  WARN_DEVELOPER_WHEN(), or something.
I don't care what it's called.  

- z 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
