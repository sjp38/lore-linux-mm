Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id EDF876B0025
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 22:00:49 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 41so53327qtp.8
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 19:00:49 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l5si790301qti.164.2018.03.19.19.00.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 19:00:48 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 12/15] mm/hmm: move hmm_pfns_clear() closer to where it is use
Date: Mon, 19 Mar 2018 22:00:34 -0400
Message-Id: <20180320020038.3360-13-jglisse@redhat.com>
In-Reply-To: <20180320020038.3360-1-jglisse@redhat.com>
References: <20180320020038.3360-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Move hmm_pfns_clear() closer to where it is use to make it clear it
is not use by page table walkers.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
---
 mm/hmm.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index b4b8b89ee7bb..52cdceb35733 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -316,14 +316,6 @@ static int hmm_pfns_bad(unsigned long addr,
 	return 0;
 }
 
-static void hmm_pfns_clear(uint64_t *pfns,
-			   unsigned long addr,
-			   unsigned long end)
-{
-	for (; addr < end; addr += PAGE_SIZE, pfns++)
-		*pfns = 0;
-}
-
 /*
  * hmm_vma_walk_hole() - handle a range lacking valid pmd or pte(s)
  * @start: range virtual start address (inclusive)
@@ -482,6 +474,14 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 	return 0;
 }
 
+static void hmm_pfns_clear(uint64_t *pfns,
+			   unsigned long addr,
+			   unsigned long end)
+{
+	for (; addr < end; addr += PAGE_SIZE, pfns++)
+		*pfns = 0;
+}
+
 static void hmm_pfns_special(struct hmm_range *range)
 {
 	unsigned long addr = range->start, i = 0;
-- 
2.14.3
