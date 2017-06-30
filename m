Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 152122802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 11:44:20 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x23so38711604wrb.6
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 08:44:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j198si11187038wmg.14.2017.06.30.08.44.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 08:44:19 -0700 (PDT)
Date: Fri, 30 Jun 2017 17:44:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: "mm: use early_pfn_to_nid in page_ext_init" broken on some
 configurations?
Message-ID: <20170630154416.GB9714@dhcp22.suse.cz>
References: <20170630141847.GN22917@dhcp22.suse.cz>
 <20170630154224.GA9714@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170630154224.GA9714@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 30-06-17 17:42:24, Michal Hocko wrote:
[...]
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 16532fa0bb64..894697c1e6f5 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1055,6 +1055,7 @@ static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
>  	!defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
>  static inline unsigned long early_pfn_to_nid(unsigned long pfn)
>  {
> +	BUILD_BUG_ON(!IS_ENABLED(CONFIG_NUMA));

Err, this should read BUILD_BUG_ON(IS_ENABLED(CONFIG_NUMA)) of course

>  	return 0;
>  }
>  #endif

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
