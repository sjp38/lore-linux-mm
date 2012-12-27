Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 59BF96B002B
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 20:59:21 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so4111065dak.0
        for <linux-mm@kvack.org>; Wed, 26 Dec 2012 17:59:20 -0800 (PST)
Date: Wed, 26 Dec 2012 17:59:18 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] cma: use unsigned type for count argument
In-Reply-To: <xa1tip7u14tq.fsf@mina86.com>
Message-ID: <alpine.DEB.2.00.1212261755450.4150@chino.kir.corp.google.com>
References: <52fd3c7b677ff01f1cd6d54e38a567b463ec1294.1355938871.git.mina86@mina86.com> <20121220153525.97841100.akpm@linux-foundation.org> <alpine.DEB.2.00.1212201557270.13223@chino.kir.corp.google.com> <xa1tip7u14tq.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mpn@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 22 Dec 2012, Michal Nazarewicz wrote:

> So I think just adding the following, should be sufficient to make
> everyone happy:
> 
> diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> index e34e3e0..e91743b 100644
> --- a/drivers/base/dma-contiguous.c
> +++ b/drivers/base/dma-contiguous.c
> @@ -320,7 +320,7 @@ struct page *dma_alloc_from_contiguous(struct device *dev, unsigned int count,
>  	pr_debug("%s(cma %p, count %u, align %u)\n", __func__, (void *)cma,
>  		 count, align);
>  
> -	if (!count)
> +	if (!count || count > INT_MAX)
>  		return NULL;
>  
>  	mask = (1 << align) - 1;

How is this different than leaving the formal to have a signed type, i.e. 
drop your patch, and testing for count <= 0 instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
