Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C55266B005D
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 08:58:42 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: xtensa: add pgprot_noncached
Date: Tue, 23 Jun 2009 15:00:31 +0200
References: <20090614132845.17543.11882.sendpatchset@rx1.opensource.se> <20090622151537.2f8009f7.akpm@linux-foundation.org> <200906231441.37158.arnd@arndb.de>
In-Reply-To: <200906231441.37158.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200906231500.32385.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Chris Zankel <chris@zankel.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Mundt <lethal@linux-sh.org>, magnus.damm@gmail.com, linux-mm@kvack.org, jayakumar.lkml@gmail.com, Jesper Nilsson <jesper.nilsson@axis.com>
List-ID: <linux-mm.kvack.org>

This adds a straightforward pgprot_noncached() macro for
xtensa, so we can use it in architecture independent code
in the future.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

--- a/arch/xtensa/include/asm/pgtable.h
+++ b/arch/xtensa/include/asm/pgtable.h
@@ -251,6 +251,9 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 	return __pte((pte_val(pte) & _PAGE_CHG_MASK) | pgprot_val(newprot));
 }
 
+#define pgprot_noncached(prot) \
+	__pgprot((pgprot_val(prot) & ~_PAGE_CA_MASK) | _PAGE_CA_BYPASS)
+
 /*
  * Certain architectures need to do special things when pte's
  * within a page table are directly modified.  Thus, the following

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
