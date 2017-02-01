Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C9B76B026C
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 18:38:07 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id w20so216203977qtb.3
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 15:38:07 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id t28si15548089qtc.337.2017.02.01.15.38.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 15:38:06 -0800 (PST)
From: "Tobin C. Harding" <me@tobin.cc>
Subject: [PATCH 4/4] mm: Fix checkpatch warning, extraneous braces
Date: Thu,  2 Feb 2017 10:37:20 +1100
Message-Id: <1485992240-10986-5-git-send-email-me@tobin.cc>
In-Reply-To: <1485992240-10986-1-git-send-email-me@tobin.cc>
References: <1485992240-10986-1-git-send-email-me@tobin.cc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Tobin C Harding <me@tobin.cc>

From: Tobin C Harding <me@tobin.cc>

Patch fixes checkpatch warning on use of braces around a single
statement.

Signed-off-by: Tobin C Harding <me@tobin.cc>
---
 mm/memory.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 35fb8b2..654e6f4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1128,9 +1128,8 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 	arch_enter_lazy_mmu_mode();
 	do {
 		pte_t ptent = *pte;
-		if (pte_none(ptent)) {
+		if (pte_none(ptent))
 			continue;
-		}
 
 		if (pte_present(ptent)) {
 			struct page *page;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
