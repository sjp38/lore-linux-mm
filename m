Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 017B66B0531
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 08:47:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c12so22202915pfj.12
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 05:47:49 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id e8si1858352pfb.183.2017.07.12.05.47.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 05:47:49 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v12 7/8] mm: export symbol of next_zone and first_online_pgdat
Date: Wed, 12 Jul 2017 20:40:20 +0800
Message-Id: <1499863221-16206-8-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com
Cc: virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

This patch enables for_each_zone()/for_each_populated_zone() to be
invoked by a kernel module.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
---
 mm/mmzone.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/mmzone.c b/mm/mmzone.c
index a51c0a6..08a2a3a 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -13,6 +13,7 @@ struct pglist_data *first_online_pgdat(void)
 {
 	return NODE_DATA(first_online_node);
 }
+EXPORT_SYMBOL_GPL(first_online_pgdat);
 
 struct pglist_data *next_online_pgdat(struct pglist_data *pgdat)
 {
@@ -41,6 +42,7 @@ struct zone *next_zone(struct zone *zone)
 	}
 	return zone;
 }
+EXPORT_SYMBOL_GPL(next_zone);
 
 static inline int zref_in_nodemask(struct zoneref *zref, nodemask_t *nodes)
 {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
