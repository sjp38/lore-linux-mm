Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 119836B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 07:57:13 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id l2so6422695wgh.27
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 04:57:12 -0800 (PST)
Received: from cpsmtpb-ews08.kpnxchange.com (cpsmtpb-ews08.kpnxchange.com. [213.75.39.13])
        by mx.google.com with ESMTP id hx2si11954749wjb.18.2014.11.27.04.57.12
        for <linux-mm@kvack.org>;
        Thu, 27 Nov 2014 04:57:12 -0800 (PST)
Message-ID: <1417093031.29407.102.camel@x220>
Subject: [PATCH next-20141127] mm: Fix comment typo "CONFIG_TRANSPARNTE_HUGE"
From: Paul Bolle <pebolle@tiscali.nl>
Date: Thu, 27 Nov 2014 13:57:11 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Valentin Rothberg <valentinrothberg@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The commit "mm: don't split THP page when syscall is called" added a
reference to CONFIG_TRANSPARNTE_HUGE in a comment. Use
CONFIG_TRANSPARENT_HUGEPAGE instead, as was probably intended.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Compile tested.

If commit "mm: don't split THP page when syscall is called" is not yet
set in stone, I would prefer if this trivial fix would be squashed into
that commit.

 mm/rmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index d2a6e136b08d..95d394bbb6ab 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -708,7 +708,7 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		/*
 		 * Use pmd_freeable instead of raw pmd_dirty because in some
 		 * of architecture, pmd_dirty is not defined unless
-		 * CONFIG_TRANSPARNTE_HUGE is enabled
+		 * CONFIG_TRANSPARENT_HUGEPAGE is enabled
 		 */
 		if (!pmd_freeable(*pmd))
 			dirty++;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
