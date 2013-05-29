Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id C529D6B00A4
	for <linux-mm@kvack.org>; Wed, 29 May 2013 04:50:04 -0400 (EDT)
Message-ID: <51A5C126.9030105@synopsys.com>
Date: Wed, 29 May 2013 14:19:42 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7, part3 14/16] mm: concentrate modification of totalram_pages
 into the mm core
References: <1368805518-2634-1-git-send-email-jiang.liu@huawei.com> <1368805518-2634-15-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1368805518-2634-15-git-send-email-jiang.liu@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/17/2013 09:15 PM, Jiang Liu wrote:
> Concentrate code to modify totalram_pages into the mm core, so the arch
> memory initialized code doesn't need to take care of it. With these
> changes applied, only following functions from mm core modify global
> variable totalram_pages:
> free_bootmem_late(), free_all_bootmem(), free_all_bootmem_node(),
> adjust_managed_page_count().
> 
> With this patch applied, it will be much more easier for us to keep
> totalram_pages and zone->managed_pages in consistence.
> 
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Acked-by: David Howells <dhowells@redhat.com>
> ---
>  arch/alpha/mm/init.c             | 2 +-
>  arch/alpha/mm/numa.c             | 2 +-
>  arch/arc/mm/init.c               | 2 +-

...

> diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
> index f9c7077..c668a60 100644
> --- a/arch/arc/mm/init.c
> +++ b/arch/arc/mm/init.c
> @@ -111,7 +111,7 @@ void __init mem_init(void)
>  
>  	high_memory = (void *)(CONFIG_LINUX_LINK_BASE + arc_mem_sz);
>  
> -	totalram_pages = free_all_bootmem();
> +	free_all_bootmem();
>  
>  	/* count all reserved pages [kernel code/data/mem_map..] */
>  	reserved_pages = 0;

Acked-by: Vineet Gupta <vgupta@synopsys.com>	for arch/arc bits

Thx,
-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
