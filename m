Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 820B68296B
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 16:55:40 -0400 (EDT)
Received: by wghl18 with SMTP id l18so12012822wgh.5
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 13:55:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q3si458729wik.5.2015.03.11.13.55.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Mar 2015 13:55:39 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 2/2] mmotm: Enable small allocation to fail
Date: Wed, 11 Mar 2015 16:54:54 -0400
Message-Id: <1426107294-21551-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
References: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

Let's break the universe... for those who are willing and brave enough to
run mmotm (and ideally linux-next) tree. OOM situations will lead to
bugs which were hidden for years most probably but it is time we eat our
own dog food and fix them up finally.

The patch itself is trivial. Simply allow only one allocation retry
after OOM killer has been triggered.

THIS IS NOT a patch to be merged to LINUS TREE. At least not now.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7ae07a5d08df..583f0f27c97e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -132,7 +132,7 @@ gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
  * environments are encouraged to lower the value to catch potential
  * issues which should be fixed.
  */
-unsigned long sysctl_nr_alloc_retry = ULONG_MAX;
+unsigned long sysctl_nr_alloc_retry = 1;
 
 #ifdef CONFIG_PM_SLEEP
 /*
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
