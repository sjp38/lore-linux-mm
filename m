Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8AB686B0279
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:46:26 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f13-v6so2249053edr.10
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:46:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z14-v6si5057710edd.127.2018.07.19.06.46.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 06:46:25 -0700 (PDT)
Date: Thu, 19 Jul 2018 15:46:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 5/5] mm/page_alloc: Only call pgdat_set_deferred_range
 when the system boots
Message-ID: <20180719134622.GE7193@dhcp22.suse.cz>
References: <20180719132740.32743-1-osalvador@techadventures.net>
 <20180719132740.32743-6-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719132740.32743-6-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Thu 19-07-18 15:27:40, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> We should only care about deferred initialization when booting.

Again why is this worth doing?
 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  mm/page_alloc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d77bc2a7ec2c..5911b64a88ab 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6419,7 +6419,8 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
>  				  zones_size, zholes_size);
>  
>  	alloc_node_mem_map(pgdat);
> -	pgdat_set_deferred_range(pgdat);
> +	if (system_state == SYSTEM_BOOTING)
> +		pgdat_set_deferred_range(pgdat);
>  
>  	free_area_init_core(pgdat);
>  }
> -- 
> 2.13.6
> 

-- 
Michal Hocko
SUSE Labs
