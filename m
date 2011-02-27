Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E7DF98D0039
	for <linux-mm@kvack.org>; Sat, 26 Feb 2011 23:34:57 -0500 (EST)
Received: by iyf13 with SMTP id 13so2683962iyf.14
        for <linux-mm@kvack.org>; Sat, 26 Feb 2011 20:34:56 -0800 (PST)
From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH 16/17]mm:shmem.c Remove one to many n's in a word.
Date: Sat, 26 Feb 2011 20:34:09 -0800
Message-Id: <1298781250-2718-17-git-send-email-justinmattock@gmail.com>
In-Reply-To: <1298781250-2718-1-git-send-email-justinmattock@gmail.com>
References: <1298781250-2718-1-git-send-email-justinmattock@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org
Cc: linux-kernel@vger.kernel.org, "Justin P. Mattock" <justinmattock@gmail.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

The Patch below removes one to many "n's" in a word..

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>
CC: Hugh Dickins <hughd@google.com>
CC: linux-mm@kvack.org
---
 mm/shmem.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 5ee67c9..3cdb243 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -779,7 +779,7 @@ static int shmem_notify_change(struct dentry *dentry, struct iattr *attr)
 			 * If truncating down to a partial page, then
 			 * if that page is already allocated, hold it
 			 * in memory until the truncation is over, so
-			 * truncate_partial_page cannnot miss it were
+			 * truncate_partial_page cannot miss it were
 			 * it assigned to swap.
 			 */
 			if (newsize & (PAGE_CACHE_SIZE-1)) {
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
