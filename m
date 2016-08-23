Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 20F686B0069
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 04:09:28 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u81so78754596wmu.3
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 01:09:28 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 201si2459216wmb.59.2016.08.23.01.09.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 01:09:27 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id o80so16951457wme.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 01:09:26 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm: clarify COMPACTION Kconfig text
Date: Tue, 23 Aug 2016 10:09:17 +0200
Message-Id: <1471939757-29789-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Markus Trippelsdorf <markus@trippelsdorf.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

The current wording of the COMPACTION Kconfig help text doesn't
emphasise that disabling COMPACTION might cripple the page allocator
which relies on the compaction quite heavily for high order requests and
an unexpected OOM can happen with the lack of compaction. Make sure
we are vocal about that.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/Kconfig | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 78a23c5c302d..0dff2f05b6d1 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -262,7 +262,14 @@ config COMPACTION
 	select MIGRATION
 	depends on MMU
 	help
-	  Allows the compaction of memory for the allocation of huge pages.
+          Compaction is the only memory management component to form
+          high order (larger physically contiguous) memory blocks
+          reliably. Page allocator relies on the compaction heavily and
+          the lack of the feature can lead to unexpected OOM killer
+          invocation for high order memory requests. You shouldnm't
+          disable this option unless there is really a strong reason for
+          it and then we are really interested to hear about that at
+          linux-mm@kvack.org.
 
 #
 # support for page migration
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
