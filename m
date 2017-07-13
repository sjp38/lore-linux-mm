Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id D4F31440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 20:16:56 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id p45so14629351qtg.11
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 17:16:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i3si3679773qtb.98.2017.07.12.17.16.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 17:16:56 -0700 (PDT)
Date: Thu, 13 Jul 2017 03:16:49 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v12 7/8] mm: export symbol of next_zone and
 first_online_pgdat
Message-ID: <20170713031526-mutt-send-email-mst@kernel.org>
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
 <1499863221-16206-8-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1499863221-16206-8-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Wed, Jul 12, 2017 at 08:40:20PM +0800, Wei Wang wrote:
> This patch enables for_each_zone()/for_each_populated_zone() to be
> invoked by a kernel module.

... for use by virtio balloon.

> Signed-off-by: Wei Wang <wei.w.wang@intel.com>

balloon seems to only use
+       for_each_populated_zone(zone)
+               for_each_migratetype_order(order, type)


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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
