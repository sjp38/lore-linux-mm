Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8556B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 14:07:03 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id z1-v6so133558qki.10
        for <linux-mm@kvack.org>; Mon, 21 May 2018 11:07:03 -0700 (PDT)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.198])
        by mx.google.com with ESMTPS id b52-v6si4155259qta.108.2018.05.21.11.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 11:07:02 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: [RFC PATCH v2 09/12] mm/vmpressure: update usage of address zone
 modifiers
Date: Mon, 21 May 2018 18:06:48 +0000
Message-ID: <HK2PR03MB16849EA4D9CE5C230EB9966492950@HK2PR03MB1684.apcprd03.prod.outlook.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@infradead.org" <willy@infradead.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, "hch@lst.de" <hch@lst.de>, "zhongjiang@huawei.com" <zhongjiang@huawei.com>, "minchan@kernel.org" <minchan@kernel.org>, "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>, "rientjes@google.com" <rientjes@google.com>

Use __GFP_ZONE_MOVABLE to replace (__GFP_HIGHMEM | __GFP_MOVABLE).

___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 have been deleted from GFP=20
bitmasks, the bottom three bits of GFP mask is reserved for storing
encoded zone number.

__GFP_ZONE_MOVABLE contains encoded ZONE_MOVABLE and __GFP_MOVABLE flag.

With GFP_ZONE_TABLE, __GFP_HIGHMEM ORing __GFP_MOVABLE means gfp_zone
should return ZONE_MOVABLE. In order to keep that compatible with
GFP_ZONE_TABLE, replace (__GFP_HIGHMEM | __GFP_MOVABLE) with
__GFP_ZONE_MOVABLE.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: zhongjiang <zhongjiang@huawei.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/vmpressure.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 85350ce..30a40e2 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -256,7 +256,7 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg, bo=
ol tree,
         * Indirect reclaim (kswapd) sets sc->gfp_mask to GFP_KERNEL, so
         * we account it too.
         */
-       if (!(gfp & (__GFP_HIGHMEM | __GFP_MOVABLE | __GFP_IO | __GFP_FS)))
+       if (!(gfp & (__GFP_ZONE_MOVABLE | __GFP_IO | __GFP_FS)))
                return;
=20
        /*
--=20
1.8.3.1
