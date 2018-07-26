Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 27A746B0003
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:02:27 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id a9-v6so922915wrw.20
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 05:02:27 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g16-v6sor506908wrq.40.2018.07.26.05.02.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Jul 2018 05:02:25 -0700 (PDT)
Date: Thu, 26 Jul 2018 14:02:24 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v3 5/5] mm/page_alloc: Introduce memhotplug version of
 free_area_init_core
Message-ID: <20180726120224.GA8302@techadventures.net>
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
> -	 */
> +         * When memory is hot-added, all the memory is in offline state. So
> +         * clear all zones' present_pages because they will be updated in
> +         * online_pages() and offline_pages().
> +         */

Sigh..., I should have run checkpatch. Tabs are missing there


> +void __paginginit free_area_init_core_hotplug(int nid)
> +{
> +	enum zone_type j;
> +	pg_data_t *pgdat = NODE_DATA(nid);
> +
> +	pgdat_init_internals(pgdat);
> +	for(j = 0; j < MAX_NR_ZONES; j++) {

And missing a space here.

Sorry, I will fix all this up in the next re-submission once I got feedback. 

Thanks
-- 
Oscar Salvador
SUSE L3
