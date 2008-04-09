Message-ID: <47FC95AD.1070907@tiscali.nl>
Date: Wed, 09 Apr 2008 12:08:45 +0200
From: Roel Kluin <12o3l@tiscali.nl>
MIME-Version: 1.0
Subject: [PATCH] pagewalk: don't pte_unmap(NULL) in walk_pte_range()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is right isn't it?
---
Don't pte_unmap a NULL pointer, but the previous.

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 1cf1417..6615f0b 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -15,7 +15,7 @@ static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 		       break;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 
-	pte_unmap(pte);
+	pte_unmap(pte - 1);
 	return err;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
