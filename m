Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9D842440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 08:31:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b189so9008580wmb.12
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 05:31:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x73si2217529wma.0.2017.07.14.05.31.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 05:31:53 -0700 (PDT)
Date: Fri, 14 Jul 2017 14:31:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v12 7/8] mm: export symbol of next_zone and
 first_online_pgdat
Message-ID: <20170714123150.GB2624@dhcp22.suse.cz>
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
 <1499863221-16206-8-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1499863221-16206-8-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Wed 12-07-17 20:40:20, Wei Wang wrote:
> This patch enables for_each_zone()/for_each_populated_zone() to be
> invoked by a kernel module.

This needs much better justification with an example of who is going to
use these symbols and what for.
 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> ---
>  mm/mmzone.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/mmzone.c b/mm/mmzone.c
> index a51c0a6..08a2a3a 100644
> --- a/mm/mmzone.c
> +++ b/mm/mmzone.c
> @@ -13,6 +13,7 @@ struct pglist_data *first_online_pgdat(void)
>  {
>  	return NODE_DATA(first_online_node);
>  }
> +EXPORT_SYMBOL_GPL(first_online_pgdat);
>  
>  struct pglist_data *next_online_pgdat(struct pglist_data *pgdat)
>  {
> @@ -41,6 +42,7 @@ struct zone *next_zone(struct zone *zone)
>  	}
>  	return zone;
>  }
> +EXPORT_SYMBOL_GPL(next_zone);
>  
>  static inline int zref_in_nodemask(struct zoneref *zref, nodemask_t *nodes)
>  {
> -- 
> 2.7.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
