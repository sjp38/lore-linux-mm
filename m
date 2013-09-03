Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id C3BE76B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 03:24:33 -0400 (EDT)
Message-ID: <52258E9C.6050601@cn.fujitsu.com>
Date: Tue, 03 Sep 2013 15:24:12 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 2/4] mm/vmalloc: revert "mm/vmalloc.c: emit the failure
 message before return"
References: <1378191706-29696-1-git-send-email-liwanp@linux.vnet.ibm.com> <1378191706-29696-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1378191706-29696-2-git-send-email-liwanp@linux.vnet.ibm.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/03/2013 03:01 PM, Wanpeng Li wrote:
> Changelog:
>  *v2 -> v3: revert commit 46c001a2 directly
> 
> Don't warning twice in __vmalloc_area_node and __vmalloc_node_range if
> __vmalloc_area_node allocation failure. This patch revert commit 46c001a2
> (mm/vmalloc.c: emit the failure message before return).
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> ---
>  mm/vmalloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index d78d117..e3ec8b4 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1635,7 +1635,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>  
>  	addr = __vmalloc_area_node(area, gfp_mask, prot, node, caller);
>  	if (!addr)
> -		goto fail;
> +		return NULL;
>  
>  	/*
>  	 * In this function, newly allocated vm_struct has VM_UNINITIALIZED
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
