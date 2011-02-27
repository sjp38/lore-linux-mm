Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 466BC8D0039
	for <linux-mm@kvack.org>; Sat, 26 Feb 2011 23:34:59 -0500 (EST)
Received: by iwl42 with SMTP id 42so2925095iwl.14
        for <linux-mm@kvack.org>; Sat, 26 Feb 2011 20:34:54 -0800 (PST)
From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH 15/17]mm:mempolicy.c Remove one to many n's in a word.
Date: Sat, 26 Feb 2011 20:34:08 -0800
Message-Id: <1298781250-2718-16-git-send-email-justinmattock@gmail.com>
In-Reply-To: <1298781250-2718-1-git-send-email-justinmattock@gmail.com>
References: <1298781250-2718-1-git-send-email-justinmattock@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org
Cc: linux-kernel@vger.kernel.org, "Justin P. Mattock" <justinmattock@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

The Patch below removes one to many "n's" in a word..

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: linux-mm@kvack.org
---
 mm/mempolicy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 368fc9d..a5d7995 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -993,7 +993,7 @@ int do_migrate_pages(struct mm_struct *mm,
 	 * most recent <s, d> pair that moved (s != d).  If we find a pair
 	 * that not only moved, but what's better, moved to an empty slot
 	 * (d is not set in tmp), then we break out then, with that pair.
-	 * Otherwise when we finish scannng from_tmp, we at least have the
+	 * Otherwise when we finish scanning from_tmp, we at least have the
 	 * most recent <s, d> pair that moved.  If we get all the way through
 	 * the scan of tmp without finding any node that moved, much less
 	 * moved to an empty node, then there is nothing left worth migrating.
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
