Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0366B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:31:16 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l3so31492362wrc.12
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:31:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k11si9935294wrk.226.2017.07.26.04.31.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 04:31:15 -0700 (PDT)
Date: Wed, 26 Jul 2017 13:31:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: take memory hotplug lock within
 numa_zonelist_order_handler()
Message-ID: <20170726113112.GJ2981@dhcp22.suse.cz>
References: <20170726111738.38768-1-heiko.carstens@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726111738.38768-1-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, Andre Wild <wild@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>

On Wed 26-07-17 13:17:38, Heiko Carstens wrote:
[...]
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6d30e914afb6..fc32aa81f359 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4891,9 +4891,11 @@ int numa_zonelist_order_handler(struct ctl_table *table, int write,
>  				NUMA_ZONELIST_ORDER_LEN);
>  			user_zonelist_order = oldval;
>  		} else if (oldval != user_zonelist_order) {
> +			mem_hotplug_begin();
>  			mutex_lock(&zonelists_mutex);
>  			build_all_zonelists(NULL, NULL);
>  			mutex_unlock(&zonelists_mutex);
> +			mem_hotplug_done();
>  		}
>  	}
>  out:

Please note that this code has been removed by
http://lkml.kernel.org/r/20170721143915.14161-2-mhocko@kernel.org. It
will get to linux-next as soon as Andrew releases a new version mmotm
tree.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
