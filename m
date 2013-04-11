Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 7C3086B0027
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:50:51 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id DEB513EE0C5
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 08:50:48 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BCFD545DE52
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 08:50:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A359C45DDCF
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 08:50:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9584F1DB803F
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 08:50:48 +0900 (JST)
Received: from g01jpexchkw30.g01.fujitsu.local (g01jpexchkw30.g01.fujitsu.local [10.0.193.113])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D0D81DB803C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 08:50:48 +0900 (JST)
Message-ID: <51674C30.5060309@jp.fujitsu.com>
Date: Fri, 12 Apr 2013 08:50:08 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] resource: Update config option of release_mem_region_adjustable()
References: <1365719185-4799-1-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1365719185-4799-1-git-send-email-toshi.kani@hp.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, linuxram@us.ibm.com, guz.fnst@cn.fujitsu.com, tmac@hp.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

2013/04/12 7:26, Toshi Kani wrote:
> Changed the config option of release_mem_region_adjustable() from
> CONFIG_MEMORY_HOTPLUG to CONFIG_MEMORY_HOTREMOVE since this function
> is only used for memory hot-delete.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu


> ---
> 
> This patch applies on top of the two patches below:
> Re: [PATCH v3 2/3] resource: Add release_mem_region_adjustable()
> https://lkml.org/lkml/2013/4/11/381
> [patch] mm, hotplug: avoid compiling memory hotremove functions when disabled
> https://lkml.org/lkml/2013/4/10/37
> 
> ---
>   include/linux/ioport.h |    2 +-
>   kernel/resource.c      |    4 ++--
>   2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/ioport.h b/include/linux/ioport.h
> index 961d4dc..89b7c24 100644
> --- a/include/linux/ioport.h
> +++ b/include/linux/ioport.h
> @@ -192,7 +192,7 @@ extern struct resource * __request_region(struct resource *,
>   extern int __check_region(struct resource *, resource_size_t, resource_size_t);
>   extern void __release_region(struct resource *, resource_size_t,
>   				resource_size_t);
> -#ifdef CONFIG_MEMORY_HOTPLUG
> +#ifdef CONFIG_MEMORY_HOTREMOVE
>   extern int release_mem_region_adjustable(struct resource *, resource_size_t,
>   				resource_size_t);
>   #endif
> diff --git a/kernel/resource.c b/kernel/resource.c
> index 16bfd39..4aef886 100644
> --- a/kernel/resource.c
> +++ b/kernel/resource.c
> @@ -1021,7 +1021,7 @@ void __release_region(struct resource *parent, resource_size_t start,
>   }
>   EXPORT_SYMBOL(__release_region);
>   
> -#ifdef CONFIG_MEMORY_HOTPLUG
> +#ifdef CONFIG_MEMORY_HOTREMOVE
>   /**
>    * release_mem_region_adjustable - release a previously reserved memory region
>    * @parent: parent resource descriptor
> @@ -1122,7 +1122,7 @@ int release_mem_region_adjustable(struct resource *parent,
>   	kfree(new_res);
>   	return ret;
>   }
> -#endif	/* CONFIG_MEMORY_HOTPLUG */
> +#endif	/* CONFIG_MEMORY_HOTREMOVE */
>   
>   /*
>    * Managed region resource
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
