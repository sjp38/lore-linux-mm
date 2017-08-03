Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5887F6B0611
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 09:36:33 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p3so6147464qtg.4
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 06:36:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r88si19547953qki.329.2017.08.03.06.36.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 06:36:32 -0700 (PDT)
Date: Thu, 3 Aug 2017 09:36:22 -0400
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] MAINTAINERS: copy virtio on balloon_compaction.c
Message-ID: <20170803133622.GD26205@xps>
References: <1501764010-24456-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1501764010-24456-1-git-send-email-mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, Wei Wang <wei.w.wang@intel.com>, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, mhocko@kernel.org, zhenwei.pi@youruncloud.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, mawilcox@microsoft.com

On Thu, Aug 03, 2017 at 03:42:52PM +0300, Michael S. Tsirkin wrote:
> Changes to mm/balloon_compaction.c can easily break virtio, and virtio
> is the only user of that interface.  Add a line to MAINTAINERS so
> whoever changes that file remembers to copy us.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  MAINTAINERS | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index f66488d..6b1d60e 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -13996,6 +13996,7 @@ F:	drivers/block/virtio_blk.c
>  F:	include/linux/virtio*.h
>  F:	include/uapi/linux/virtio_*.h
>  F:	drivers/crypto/virtio/
> +F:	mm/balloon_compaction.c
>  
>  VIRTIO CRYPTO DRIVER
>  M:	Gonglei <arei.gonglei@huawei.com>
> -- 
> MST

Acked-by: Rafael Aquini <aquini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
