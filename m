Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id E48C46B0032
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 11:56:32 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id u10so4990969pdi.36
        for <linux-mm@kvack.org>; Fri, 07 Jun 2013 08:56:32 -0700 (PDT)
Message-ID: <51B202A4.6090903@gmail.com>
Date: Fri, 07 Jun 2013 23:56:20 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch -mm] mm, vmalloc: unbreak __vunmap()
References: <20130607120738.GA13851@debian>
In-Reply-To: <20130607120738.GA13851@debian>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On 06/07/2013 08:07 PM, Dan Carpenter wrote:
> There is an extra semi-colon so the function always returns.

Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

This is imported by using the macro PAGE_ALIGNED.

> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 91a1047..96b77a9 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1453,7 +1453,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
>  		return;
>  
>  	if (WARN(!PAGE_ALIGNED(addr), "Trying to vfree() bad address (%p)\n",
> -			addr));
> +			addr))
>  		return;
>  
>  	area = remove_vm_area(addr);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
