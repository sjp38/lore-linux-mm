Message-ID: <39D13F5F.9C7F28D6@sgi.com>
Date: Tue, 26 Sep 2000 17:29:19 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: [PATCH] A code cleanup change
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

A simple change to get rid of a few magic numbers.
Not included in the patch, one could also use a simple array
for the triplet page_{min,low,high} with the same PAGE_{MIN,LOW,HIGH} index
definitions. The switch in __alloc_pages_limit will be
gone; other places will have to be modified, but
won't incur any extra cost.

Patch against test9-pre7:

==================
--- ./mm/page_alloc.c.orig      Tue Sep 26 13:55:48 2000
+++ ./mm/page_alloc.c   Tue Sep 26 13:56:41 2000
@@ -258,13 +258,13 @@
                 */
                switch (limit) {
                        default:
-                       case 0:
+                       case PAGES_MIN:
                                water_mark = z->pages_min;
                                break;
-                       case 1:
+                       case PAGES_LOW:
                                water_mark = z->pages_low;
                                break;
-                       case 2:
+                       case PAGES_HIGH:
                                water_mark = z->pages_high;
                }
 
=====================
-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
