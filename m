Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 92F936B0003
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 04:35:52 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o42so3544956edc.13
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 01:35:52 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 2-v6si6621183eju.12.2018.11.05.01.35.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 01:35:51 -0800 (PST)
Date: Mon, 5 Nov 2018 10:35:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memory_hotplug: teach has_unmovable_pages about of
 LRU migrateable pages
Message-ID: <20181105093550.GE4361@dhcp22.suse.cz>
References: <20181101091055.GA15166@MiWiFi-R3L-srv>
 <20181102155528.20358-1-mhocko@kernel.org>
 <20181105002009.GF27491@MiWiFi-R3L-srv>
 <20181105091407.GB4361@dhcp22.suse.cz>
 <20181105092618.GI27491@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105092618.GI27491@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Mon 05-11-18 17:26:18, Baoquan He wrote:
[...]
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a919ba5..021e39d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7824,7 +7824,8 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>                 if (__PageMovable(page))
>                         continue;
> 
> -               if (!PageLRU(page))
> +               if (!PageLRU(page) &&
> +                       (get_pageblock_migratetype(page) != MIGRATE_MOVABLE))
>                         found++;
>                 /*
>                  * If there are RECLAIMABLE pages, we need to check

As explained during the private conversion I am not really thrilled by
this check. AFAIU this will be the case for basically all pages in the
zone_movable. As we have seen already some unexpected ones can lurk in
easily.

-- 
Michal Hocko
SUSE Labs
