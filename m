Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 78F156B0256
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 11:51:37 -0500 (EST)
Received: by wmec201 with SMTP id c201so81958590wme.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:51:36 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id t8si5187963wjf.46.2015.11.18.08.51.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 08:51:36 -0800 (PST)
Received: by wmww144 with SMTP id w144so80754955wmw.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:51:36 -0800 (PST)
Date: Wed, 18 Nov 2015 17:51:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memory-hotplug: use PFN_DOWN in should_add_memory_movable
Message-ID: <20151118165134.GB19150@dhcp22.suse.cz>
References: <a8c9ad77b0a3bebb49110b70e1aecb79e54ad49d.1447853330.git.geliangtang@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a8c9ad77b0a3bebb49110b70e1aecb79e54ad49d.1447853330.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 18-11-15 21:31:32, Geliang Tang wrote:
> Use PFN_DOWN() in should_add_memory_movable() to keep the consistency
> of this file.

I really detest this patch and c8e861a531b0 ("mm/memory_hotplug.c: use
PFN_DOWN()") which has started to use PFN_DOWN in that file likewise.
It obfuscates a perfectly understandable construct of addr->pfn
conversion by a macro which I have to really check what it does because
the name suggests I am rounding an existing pfn down.

This really doesn't help the readability.

> 
> Signed-off-by: Geliang Tang <geliangtang@163.com>
> ---
>  mm/memory_hotplug.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 67d488a..7c44ff7 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1205,7 +1205,7 @@ static int check_hotplug_memory_range(u64 start, u64 size)
>   */
>  static int should_add_memory_movable(int nid, u64 start, u64 size)
>  {
> -	unsigned long start_pfn = start >> PAGE_SHIFT;
> +	unsigned long start_pfn = PFN_DOWN(start);
>  	pg_data_t *pgdat = NODE_DATA(nid);
>  	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
>  
> -- 
> 2.5.0
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
