Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id E6F9F6B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 01:38:29 -0400 (EDT)
Message-ID: <522575C5.7050108@cn.fujitsu.com>
Date: Tue, 03 Sep 2013 13:38:13 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/3] mm/vmalloc: don't warning vmalloc allocation failure
 twice
References: <1378177220-26218-1-git-send-email-liwanp@linux.vnet.ibm.com> <1378177220-26218-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1378177220-26218-2-git-send-email-liwanp@linux.vnet.ibm.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/03/2013 11:00 AM, Wanpeng Li wrote:
> Don't warning twice in __vmalloc_area_node and __vmalloc_node_range if
> __vmalloc_area_node allocation failure.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

OK, I missed the warning in __vmalloc_area_node(), so you are right.
You can just revert the commit 46c001a2753f47ffa621131baa3409e636515347.

> ---
>  mm/vmalloc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
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
