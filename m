Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 278036B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 16:18:07 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so106531152pdb.1
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 13:18:06 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id lx6si4172171pdb.209.2015.03.27.13.18.06
        for <linux-mm@kvack.org>;
        Fri, 27 Mar 2015 13:18:06 -0700 (PDT)
Message-ID: <5515BAF7.6070604@intel.com>
Date: Fri, 27 Mar 2015 13:17:59 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: vmscan: do not throttle based on pfmemalloc reserves
 if node has no reclaimable zones
References: <20150327192850.GA18701@linux.vnet.ibm.com>
In-Reply-To: <20150327192850.GA18701@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>
Cc: anton@sambar.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Dan Streetman <ddstreet@ieee.org>

On 03/27/2015 12:28 PM, Nishanth Aravamudan wrote:
> @@ -2585,7 +2585,7 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
>  
>         for (i = 0; i <= ZONE_NORMAL; i++) {
>                 zone = &pgdat->node_zones[i];
> -               if (!populated_zone(zone))
> +               if (!populated_zone(zone) || !zone_reclaimable(zone))
>                         continue;
>  
>                 pfmemalloc_reserve += min_wmark_pages(zone);

Do you really want zone_reclaimable()?  Or do you want something more
direct like "zone_reclaimable_pages(zone) == 0"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
