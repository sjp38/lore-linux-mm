Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 042796B0260
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 21:31:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w128so16240882pfd.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 18:31:04 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id u66si3411387pfa.108.2016.07.26.18.31.04
        for <linux-mm@kvack.org>;
        Tue, 26 Jul 2016 18:31:04 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH v2 repost 3/7] mm: add a function to get the max pfn
Date: Wed, 27 Jul 2016 09:23:32 +0800
Message-Id: <1469582616-5729-4-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, dgilbert@redhat.com, quintela@redhat.com, Liang Li <liang.z.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, "Michael S. Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

Expose the function to get the max pfn, so it can be used in the
virtio-balloon device driver.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Amit Shah <amit.shah@redhat.com>
---
 mm/page_alloc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8b3e134..7da61ad 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4517,6 +4517,12 @@ void show_free_areas(unsigned int filter)
 	show_swap_cache_info();
 }
 
+unsigned long get_max_pfn(void)
+{
+	return max_pfn;
+}
+EXPORT_SYMBOL(get_max_pfn);
+
 static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
 {
 	zoneref->zone = zone;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
