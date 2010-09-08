Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 109776B0085
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 21:29:57 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 10/10] page-types.c: fix name of unpoison interface
Date: Wed,  8 Sep 2010 10:19:41 +0900
Message-Id: <1283908781-13810-11-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1283908781-13810-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

debugfs:hwpoison/renew-pfn is the old interface.
This patch renames and fixes it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Wu Fengguang <fengguang.wu@intel.com>
---
 Documentation/vm/page-types.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git v2.6.36-rc2/Documentation/vm/page-types.c v2.6.36-rc2/Documentation/vm/page-types.c
index ccd951f..cc96ee2 100644
--- v2.6.36-rc2/Documentation/vm/page-types.c
+++ v2.6.36-rc2/Documentation/vm/page-types.c
@@ -478,7 +478,7 @@ static void prepare_hwpoison_fd(void)
 	}
 
 	if (opt_unpoison && !hwpoison_forget_fd) {
-		sprintf(buf, "%s/renew-pfn", hwpoison_debug_fs);
+		sprintf(buf, "%s/unpoison-pfn", hwpoison_debug_fs);
 		hwpoison_forget_fd = checked_open(buf, O_WRONLY);
 	}
 }
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
