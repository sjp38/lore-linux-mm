Message-ID: <3F3A9E46.6010803@sgi.com>
Date: Wed, 13 Aug 2003 13:23:34 -0700
From: Jay Lan <jlan@sgi.com>
MIME-Version: 1.0
Subject: [patch] Add support for more than 256 zones
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is to support more than 256 zones for large systems.
The changes is to add #ifdef CONFIG_IA64 to mm.h to give different
#define to ZONE_SHIFT.

Thanks,
  - jay lan


diff -urN a-2.5.75/include/linux/mm.h b-2.5.75/include/linux/mm.h
--- a-2.5.75/include/linux/mm.h     Thu Jul 10 13:04:45 2003
+++ b-2.5.75/include/linux/mm.h     Tue Aug 12 17:20:22 2003
@@ -323,7 +323,11 @@
   * sets it, so none of the operations on it need to be atomic.
   */
  #define NODE_SHIFT 4
+#ifdef CONFIG_IA64
+#define ZONE_SHIFT (BITS_PER_LONG - 10)
+#else
  #define ZONE_SHIFT (BITS_PER_LONG - 8)
+#endif

  struct zone;
  extern struct zone *zone_table[];



For patch to 2.4.21:

diff -urN a-2.4.21/include/linux/mm.h b-2.4.21/include/linux/mm.h
--- a-2.4.21/include/linux/mm.h     Fri Jun 13 07:51:38 2003
+++ b-2.4.21/include/linux/mm.h     Tue Aug 12 17:19:27 2003
@@ -321,7 +321,11 @@
   * sets it, so none of the operations on it need to be atomic.
   */
  #define NODE_SHIFT 4
+#ifdef CONFIG_IA64
+#define ZONE_SHIFT (BITS_PER_LONG - 10)
+#else
  #define ZONE_SHIFT (BITS_PER_LONG - 8)
+#endif

  struct zone_struct;
  extern struct zone_struct *zone_table[];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
