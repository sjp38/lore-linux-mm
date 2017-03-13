Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE7226B0441
	for <linux-mm@kvack.org>; Sun, 12 Mar 2017 23:58:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j5so281502914pfb.3
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 20:58:50 -0700 (PDT)
Received: from gate2.alliedtelesis.co.nz (gate2.alliedtelesis.co.nz. [2001:df5:b000:5::4])
        by mx.google.com with ESMTPS id u80si10259785pgb.312.2017.03.12.20.58.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Mar 2017 20:58:49 -0700 (PDT)
From: Chris Packham <chris.packham@alliedtelesis.co.nz>
Subject: [PATCH] mm: mark gup_pud_range as unused
Date: Mon, 13 Mar 2017 16:58:37 +1300
Message-Id: <20170313035837.29719-1-chris.packham@alliedtelesis.co.nz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mhocko@suse.com
Cc: Chris Packham <chris.packham@alliedtelesis.co.nz>, linux-kernel@vger.kernel.org

The last caller to gup_pud_range was removed in commit c2febafc6773
("mm: convert generic code to 5-level paging"). Mark it as unused to
silence a warning from gcc.

Signed-off-by: Chris Packham <chris.packham@alliedtelesis.co.nz>
---
I saw this warning when compiling 4.11-rc2 with -Werror. An equally valid fix
would be to remove the function entirely but I went for the less invasive
approach.

 mm/gup.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index c74bad1bf6e8..10f5c582273c 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1409,8 +1409,9 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 	return 1;
 }
 
-static int gup_pud_range(p4d_t p4d, unsigned long addr, unsigned long end,
-			 int write, struct page **pages, int *nr)
+static int __maybe_unused gup_pud_range(p4d_t p4d, unsigned long addr,
+					unsigned long end, int write,
+					struct page **pages, int *nr)
 {
 	unsigned long next;
 	pud_t *pudp;
-- 
2.11.0.24.ge6920cf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
