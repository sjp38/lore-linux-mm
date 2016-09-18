Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 839E26B0069
	for <linux-mm@kvack.org>; Sun, 18 Sep 2016 10:42:54 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id s64so105510025lfs.1
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 07:42:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a139si3499112wme.30.2016.09.18.07.42.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 18 Sep 2016 07:42:53 -0700 (PDT)
Date: Sun, 18 Sep 2016 16:42:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: fix oom work when memory is under pressure
Message-ID: <20160918144248.GA28476@dhcp22.suse.cz>
References: <20160912111327.GG14524@dhcp22.suse.cz>
 <57D6B0C4.6040400@huawei.com>
 <20160912174445.GC14997@dhcp22.suse.cz>
 <57D7FB71.9090102@huawei.com>
 <20160913132854.GB6592@dhcp22.suse.cz>
 <57D8F8AE.1090404@huawei.com>
 <20160914084219.GA1612@dhcp22.suse.cz>
 <20160914085227.GB1612@dhcp22.suse.cz>
 <alpine.LSU.2.11.1609161440280.5127@eggly.anvils>
 <57DE125F.7030508@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57DE125F.7030508@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Hugh Dickins <hughd@google.com>, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On Sun 18-09-16 12:04:47, zhong jiang wrote:
[...]
>  index 5048083..72dc475 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -299,7 +299,7 @@ static inline void free_rmap_item(struct rmap_item *rmap_item)
> 
>  static inline struct stable_node *alloc_stable_node(void)
>  {
> -       return kmem_cache_alloc(stable_node_cache, GFP_KERNEL);
> +       return kmem_cache_alloc(stable_node_cache, __GFP_HIGH);
>  }

I do not want to speak for Hugh but I believe he meant something
different. The above will grant access to memory reserves but it doesn't
wake kswapd nor the direct reclaim. I guess he meant GFP_KERNEL | __GFP_HIGH

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
