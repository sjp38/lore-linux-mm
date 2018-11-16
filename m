Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 614B16B091D
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 05:47:20 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 190-v6so18495505pfd.7
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 02:47:20 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z18si27744382pgk.367.2018.11.16.02.47.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 02:47:19 -0800 (PST)
Message-ID: <1542365221.3020.9.camel@suse.de>
Subject: Re: [PATCH 5/5] mm, memory_hotplug: be more verbose for memory
 offline failures
From: osalvador <osalvador@suse.de>
Date: Fri, 16 Nov 2018 11:47:01 +0100
In-Reply-To: <20181116083020.20260-6-mhocko@kernel.org>
References: <20181116083020.20260-1-mhocko@kernel.org>
	 <20181116083020.20260-6-mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Baoquan He <bhe@redhat.com>, Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Fri, 2018-11-16 at 09:30 +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a919ba5cb3c8..ec2c7916dc2d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7845,6 +7845,7 @@ bool has_unmovable_pages(struct zone *zone,
> struct page *page, int count,
>  	return false;
>  unmovable:
>  	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
> +	dump_page(pfn_to_page(pfn+iter), "unmovable page");

Would not be enough to just do:

dump_page(page, "unmovable page".

Unless I am missing something, page should already have the
right pfn?

<---
unsigned long check = pfn + iter;
page = pfn_to_page(check);
--->

The rest looks good to me

Reviewed-by: Oscar Salvador <osalvador@suse.de>
