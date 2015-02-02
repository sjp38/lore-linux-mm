Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5409D6B0073
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 18:50:41 -0500 (EST)
Received: by mail-la0-f43.google.com with SMTP id pn19so343497lab.2
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 15:50:40 -0800 (PST)
Received: from mail-la0-x22b.google.com (mail-la0-x22b.google.com. [2a00:1450:4010:c03::22b])
        by mx.google.com with ESMTPS id o4si18049320lbc.57.2015.02.02.15.50.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 15:50:39 -0800 (PST)
Received: by mail-la0-f43.google.com with SMTP id pn19so343363lab.2
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 15:50:39 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 3/5] mm/mm_init.c: Mark mminit_verify_zonelist as __init
Date: Tue,  3 Feb 2015 00:50:14 +0100
Message-Id: <1422921016-27618-4-git-send-email-linux@rasmusvillemoes.dk>
In-Reply-To: <1422921016-27618-1-git-send-email-linux@rasmusvillemoes.dk>
References: <1422921016-27618-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The only caller of mminit_verify_zonelist is build_all_zonelists_init,
which is annotated with __init, so it should be safe to also mark the
former as __init, saving ~400 bytes of .text.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 mm/mm_init.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mm_init.c b/mm/mm_init.c
index 4074caf9936b..e17c758b27bf 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -21,7 +21,7 @@ int mminit_loglevel;
 #endif
 
 /* The zonelists are simply reported, validation is manual. */
-void mminit_verify_zonelist(void)
+void __init mminit_verify_zonelist(void)
 {
 	int nid;
 
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
