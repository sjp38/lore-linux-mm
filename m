Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 782966B008C
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 07:45:04 -0400 (EDT)
Received: from localhost.localdomain ([127.0.0.1]:36169 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S6823037Ab2JOLpDCbtei (ORCPT <rfc822;linux-mm@kvack.org>);
        Mon, 15 Oct 2012 13:45:03 +0200
Date: Mon, 15 Oct 2012 13:44:56 +0200
From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] mm: huge_memory: Fix build error.
Message-ID: <20121015114456.GA30314@linux-mips.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, David Daney <david.daney@cavium.com>

Certain configurations won't implicitly pull in <linux/pagemap.h> resulting
in the following build error:

mm/huge_memory.c: In function 'release_pte_page':
mm/huge_memory.c:1697:2: error: implicit declaration of function 'unlock_page' [-Werror=implicit-function-declaration]
mm/huge_memory.c: In function '__collapse_huge_page_isolate':
mm/huge_memory.c:1757:3: error: implicit declaration of function 'trylock_page' [-Werror=implicit-function-declaration]
cc1: some warnings being treated as errors

Reported-by: David Daney <david.daney@cavium.com>
Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
---
 mm/huge_memory.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f0e5306..b5d4eb8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -17,6 +17,7 @@
 #include <linux/khugepaged.h>
 #include <linux/freezer.h>
 #include <linux/mman.h>
+#include <linux/pagemap.h>
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
 #include "internal.h"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
