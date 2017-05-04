Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2597328035A
	for <linux-mm@kvack.org>; Thu,  4 May 2017 04:56:05 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id i63so5893446pgd.15
        for <linux-mm@kvack.org>; Thu, 04 May 2017 01:56:05 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id t188si1518031pgt.331.2017.05.04.01.56.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 May 2017 01:56:04 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v10 5/6] mm: export symbol of next_zone and first_online_pgdat
Date: Thu,  4 May 2017 16:50:14 +0800
Message-Id: <1493887815-6070-6-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1493887815-6070-1-git-send-email-wei.w.wang@intel.com>
References: <1493887815-6070-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com

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
