Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9EA6B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 07:45:03 -0500 (EST)
Received: by wmvv187 with SMTP id v187so174348162wmv.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 04:45:03 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id q20si43353156wjw.68.2015.11.16.04.45.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 04:45:02 -0800 (PST)
Received: by wmuu63 with SMTP id u63so25655501wmu.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 04:45:02 -0800 (PST)
Date: Mon, 16 Nov 2015 13:45:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 7/7] mm/mmzone: refactor memmap_valid_within
Message-ID: <20151116124501.GF14116@dhcp22.suse.cz>
References: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
 <1447656686-4851-8-git-send-email-baiyaowei@cmss.chinamobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447656686-4851-8-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: akpm@linux-foundation.org, bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, rientjes@google.com, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 16-11-15 14:51:26, Yaowei Bai wrote:
[...]
> @@ -72,16 +72,10 @@ struct zoneref *next_zones_zonelist(struct zoneref *z,
>  }
>  
>  #ifdef CONFIG_ARCH_HAS_HOLES_MEMORYMODEL
> -int memmap_valid_within(unsigned long pfn,
> +bool memmap_valid_within(unsigned long pfn,
>  					struct page *page, struct zone *zone)
>  {
> -	if (page_to_pfn(page) != pfn)
> -		return 0;
> -
> -	if (page_zone(page) != zone)
> -		return 0;
> -
> -	return 1;
> +	return page_to_pfn(page) == pfn && page_zone(page) == zone;

I do not think this is easier to read. Quite contrary

>  }
>  #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
>  
> -- 
> 1.9.1
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
