Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6D96B005A
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 17:52:29 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/2] mm: make swap token dummies static inlines
Date: Tue, 16 Jun 2009 23:50:36 +0200
Message-Id: <1245189037-22961-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <Pine.LNX.4.64.0906162152250.12770@sister.anvils>
References: <Pine.LNX.4.64.0906162152250.12770@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Make use of the compiler's typechecking on !CONFIG_SWAP as well.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/swap.h |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index d476aad..3c6e856 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -426,10 +426,22 @@ static inline swp_entry_t get_swap_page(void)
 }
 
 /* linux/mm/thrash.c */
-#define put_swap_token(x) do { } while(0)
-#define grab_swap_token()  do { } while(0)
-#define has_swap_token(x) 0
-#define disable_swap_token() do { } while(0)
+static inline void put_swap_token(struct mm_struct *mm)
+{
+}
+
+static inline void grab_swap_token(void)
+{
+}
+
+static inline int has_swap_token(struct mm_struct *mm)
+{
+	return 0;
+}
+
+static inline void disable_swap_token(struct mm_struct *mm)
+{
+}
 
 static inline int mem_cgroup_cache_charge_swapin(struct page *page,
 			struct mm_struct *mm, gfp_t mask, bool locked)
-- 
1.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
