Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD76C6B000C
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 03:38:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o25-v6so609235wmh.1
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 00:38:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q12-v6sor235616wrs.3.2018.07.26.00.38.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Jul 2018 00:38:08 -0700 (PDT)
Date: Thu, 26 Jul 2018 09:38:07 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v3 5/5] mm/page_alloc: Introduce memhotplug version of
 free_area_init_core
Message-ID: <20180726073807.GA22028@techadventures.net>
References: <20180725220144.11531-1-osalvador@techadventures.net>
 <20180725220144.11531-6-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180725220144.11531-6-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, Oscar Salvador <osalvador@suse.de>

On Thu, Jul 26, 2018 at 12:01:44AM +0200, osalvador@techadventures.net wrote:
>  extern void free_initmem(void);
> +extern void free_area_init_core_hotplug(int nid);

The declaration should be wrapped with an #ifdef CONFIG_MEMORY_HOTPLUG.

> +void __paginginit free_area_init_core_hotplug(int nid)
> +{
> +	enum zone_type j;
> +	pg_data_t *pgdat = NODE_DATA(nid);
> +
> +	pgdat_init_internals(pgdat);
> +	for(j = 0; j < MAX_NR_ZONES; j++) {
> +		struct zone *zone = pgdat->node_zones + j;
> +		zone_init_internals(zone, j, nid, 0);
> +	}
> +}

The same applies here

-- 
Oscar Salvador
SUSE L3
