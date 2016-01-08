Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 15099828ED
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:29:46 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id u188so154495443wmu.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:29:46 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id w184si2302706wmg.5.2016.01.08.15.29.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 15:29:45 -0800 (PST)
Received: by mail-wm0-x22a.google.com with SMTP id l65so152047472wmf.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:29:44 -0800 (PST)
Date: Sat, 9 Jan 2016 01:29:42 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/page_alloc: remove unused struct zone *z variable
Message-ID: <20160108232942.GB13046@node.shutemov.name>
References: <1452239948-1012-1-git-send-email-kuleshovmail@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452239948-1012-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Kuleshov <kuleshovmail@gmail.com>, Robin Holt <holt@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Yaowei Bai <bywxiaobai@163.com>, Xishi Qiu <qiuxishi@huawei.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 08, 2016 at 01:59:08PM +0600, Alexander Kuleshov wrote:
> This patch removes unused struct zone *z variable which is
> appeared in 86051ca5eaf5 (mm: fix usemap initialization)

I guess it's a fix for 1e8ce83cd17f (mm: meminit: move page initialization
into a separate function).
> 
> Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

> ---
>  mm/page_alloc.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9d666df..9bde098 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4471,13 +4471,11 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  	pg_data_t *pgdat = NODE_DATA(nid);
>  	unsigned long end_pfn = start_pfn + size;
>  	unsigned long pfn;
> -	struct zone *z;
>  	unsigned long nr_initialised = 0;
>  
>  	if (highest_memmap_pfn < end_pfn - 1)
>  		highest_memmap_pfn = end_pfn - 1;
>  
> -	z = &pgdat->node_zones[zone];
>  	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
>  		/*
>  		 * There can be holes in boot-time mem_map[]s
> -- 
> 2.6.2.485.g1bc8fea
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
