Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B18B26B0012
	for <linux-mm@kvack.org>; Fri, 27 May 2011 17:35:48 -0400 (EDT)
Date: Fri, 27 May 2011 14:34:12 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] lib: fix bitmap.c kernel-doc notation
Message-Id: <20110527143412.397da46e.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkml <linux-kernel@vger.kernel.org>
Cc: akpm <akpm@linux-foundation.org>, linux-mm@kvack.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix new kernel-doc warnings in lib/bitmap.c:

Warning(lib/bitmap.c:596): No description found for parameter 'buf'
Warning(lib/bitmap.c:596): Excess function parameter 'bp' description in '__bitmap_parselist'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 lib/bitmap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.39-git14.orig/lib/bitmap.c
+++ linux-2.6.39-git14/lib/bitmap.c
@@ -572,7 +572,7 @@ EXPORT_SYMBOL(bitmap_scnlistprintf);
 
 /**
  * __bitmap_parselist - convert list format ASCII string to bitmap
- * @bp: read nul-terminated user string from this buffer
+ * @buf: read nul-terminated user string from this buffer
  * @buflen: buffer size in bytes.  If string is smaller than this
  *    then it must be terminated with a \0.
  * @is_user: location of buffer, 0 indicates kernel space

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
