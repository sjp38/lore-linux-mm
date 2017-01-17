Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D7AB26B026E
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 04:30:50 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id z128so282785930pfb.4
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:30:50 -0800 (PST)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id s23si7671046pfg.121.2017.01.17.01.30.48
        for <linux-mm@kvack.org>;
        Tue, 17 Jan 2017 01:30:50 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170117091543.25850-1-mhocko@kernel.org> <20170117091543.25850-2-mhocko@kernel.org>
In-Reply-To: <20170117091543.25850-2-mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm, page_alloc: do not report all nodes in show_mem
Date: Tue, 17 Jan 2017 17:30:32 +0800
Message-ID: <034b01d270a4$5a0aa440$0e1fecc0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'Vlastimil Babka' <vbabka@suse.cz>, 'David Rientjes' <rientjes@google.com>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>


On Tuesday, January 17, 2017 5:16 PM Michal Hocko wrote: 
> 
> From: Michal Hocko <mhocko@suse.com>
> 
> 599d0c954f91 ("mm, vmscan: move LRU lists to node") has added per numa
> node statistics to show_mem but it forgot to add skip_free_areas_node
> to fileter out nodes which are outside of the allocating task numa
> policy. Add this check to not pollute the output with the pointless
> information.
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/page_alloc.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8ff25883c172..8f4f306d804c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4345,6 +4345,9 @@ void show_free_areas(unsigned int filter)
>  		global_page_state(NR_FREE_CMA_PAGES));
> 
>  	for_each_online_pgdat(pgdat) {
> +		if (skip_free_areas_node(filter, pgdat->node_id))
> +			continue;
> +
>  		printk("Node %d"
>  			" active_anon:%lukB"
>  			" inactive_anon:%lukB"
> --
> 2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
