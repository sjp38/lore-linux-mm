Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D07C66B0003
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 01:57:09 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h48-v6so633804edh.22
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 22:57:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v17-v6si4048977ejd.97.2018.10.01.22.57.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 22:57:08 -0700 (PDT)
Date: Tue, 2 Oct 2018 07:57:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm:slab: Adjust the print format for the slabinfo
Message-ID: <20181002055704.GM18290@dhcp22.suse.cz>
References: <20181002025939.115804-1-hangdianqj@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181002025939.115804-1-hangdianqj@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jun qian <hangdianqj@163.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Barry song <21cnbao@gmail.com>

On Mon 01-10-18 19:59:39, jun qian wrote:
> Header and the corresponding information is not aligned,
> adjust the printing format helps us to understand the slabinfo better.

What prevents you from formating the output when printint the file? In
other words why do we want to do special formating in the kernel?
 
> Signed-off-by: jun qian <hangdianqj@163.com>
> Cc: Barry song <21cnbao@gmail.com>
> ---
>  mm/slab_common.c | 16 ++++++++++------
>  1 file changed, 10 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index fea3376f9816..07a324cbbfb6 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1263,9 +1263,13 @@ static void print_slabinfo_header(struct seq_file *m)
>  #else
>  	seq_puts(m, "slabinfo - version: 2.1\n");
>  #endif
> -	seq_puts(m, "# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab>");
> -	seq_puts(m, " : tunables <limit> <batchcount> <sharedfactor>");
> -	seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail>");
> +	seq_printf(m, "%-22s %-14s %-11s %-10s %-13s %-14s",
> +		  "# name", "<active_objs>", "<num_objs>", "<objsize>",
> +		  "<objperslab>", "<pagesperslab>");
> +	seq_printf(m, " : %-9s %-8s %-13s %-14s",
> +		  "tunables", "<limit>", "<batchcount>", "<sharedfactor>");
> +	seq_printf(m, " : %-9s %-15s %-12s %-16s",
> +		  "slabdata", "<active_slabs>", "<num_slabs>", "<sharedavail>");
>  #ifdef CONFIG_DEBUG_SLAB
>  	seq_puts(m, " : globalstat <listallocs> <maxobjs> <grown> <reaped> <error> <maxfreeable> <nodeallocs> <remotefrees> <alienoverflow>");
>  	seq_puts(m, " : cpustat <allochit> <allocmiss> <freehit> <freemiss>");
> @@ -1319,13 +1323,13 @@ static void cache_show(struct kmem_cache *s, struct seq_file *m)
>  
>  	memcg_accumulate_slabinfo(s, &sinfo);
>  
> -	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d",
> +	seq_printf(m, "%-22s %-14lu %-11lu %-10u %-13u %-14d",
>  		   cache_name(s), sinfo.active_objs, sinfo.num_objs, s->size,
>  		   sinfo.objects_per_slab, (1 << sinfo.cache_order));
>  
> -	seq_printf(m, " : tunables %4u %4u %4u",
> +	seq_printf(m, " : %-9s %-8u %-13u %-14u", "tunables",
>  		   sinfo.limit, sinfo.batchcount, sinfo.shared);
> -	seq_printf(m, " : slabdata %6lu %6lu %6lu",
> +	seq_printf(m, " : %-9s %-15lu %-12lu %-16lu", "slabdata",
>  		   sinfo.active_slabs, sinfo.num_slabs, sinfo.shared_avail);
>  	slabinfo_show_stats(m, s);
>  	seq_putc(m, '\n');
> -- 
> 2.17.1
> 
> 

-- 
Michal Hocko
SUSE Labs
