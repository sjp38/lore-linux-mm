Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 5F14D6B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 01:35:17 -0400 (EDT)
Message-ID: <52257502.5010405@cn.fujitsu.com>
Date: Tue, 03 Sep 2013 13:34:58 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/3] mm/vmalloc: don't set area->caller twice
References: <1378177220-26218-1-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1378177220-26218-1-git-send-email-liwanp@linux.vnet.ibm.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/03/2013 11:00 AM, Wanpeng Li wrote:
> Changelog:
>  * rebase against mmotm tree
> 
> The caller address has already been set in set_vmalloc_vm(), there's no need
> to set it again in __vmalloc_area_node.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> ---
>  mm/vmalloc.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 1074543..d78d117 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1566,7 +1566,6 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  		pages = kmalloc_node(array_size, nested_gfp, node);
>  	}
>  	area->pages = pages;
> -	area->caller = caller;
>  	if (!area->pages) {
>  		remove_vm_area(area->addr);
>  		kfree(area);
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
