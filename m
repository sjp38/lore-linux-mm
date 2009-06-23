Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 478196B0055
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 08:40:24 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] asm-generic: add dummy pgprot_noncached()
Date: Tue, 23 Jun 2009 14:41:36 +0200
References: <20090614132845.17543.11882.sendpatchset@rx1.opensource.se> <20090615033240.GC31902@linux-sh.org> <20090622151537.2f8009f7.akpm@linux-foundation.org>
In-Reply-To: <20090622151537.2f8009f7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200906231441.37158.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mundt <lethal@linux-sh.org>, magnus.damm@gmail.com, linux-mm@kvack.org, jayakumar.lkml@gmail.com, Jesper Nilsson <jesper.nilsson@axis.com>, Chris Zankel <chris@zankel.net>
List-ID: <linux-mm.kvack.org>

From: Paul Mundt <lethal@linux-sh.org>

Most architectures now provide a pgprot_noncached(), the
remaining ones can simply use an dummy default implementation,
except for cris and xtensa, which should override the
default appropriately.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Jesper Nilsson <jesper.nilsson@axis.com>
Cc: Chris Zankel <chris@zankel.net>
Cc: Magnus Damm <magnus.damm@gmail.com>
---
 include/asm-generic/pgtable.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index e410f60..e2bd73e 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -129,6 +129,10 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addres
 #define move_pte(pte, prot, old_addr, new_addr)	(pte)
 #endif
 
+#ifndef pgprot_noncached
+#define pgprot_noncached(prot)	(prot)
+#endif
+
 #ifndef pgprot_writecombine
 #define pgprot_writecombine pgprot_noncached
 #endif
-- 
1.6.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
