Date: Fri, 8 Oct 2004 13:53:27 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: [PATCH] remove redundant AND from swp_type
Message-ID: <20041008165327.GK16028@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, linux-mm@kvack.org
Cc: hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi, 

There is a useless AND in swp_type() function.

We just shifted right SWP_TYPE_SHIFT() bits the value from the swp_entry_t,
and then we AND it with "(1 << 5) - 1" (which is a mask corresponding to the
number of bits used by "type").  

Remove it since its redundant.

This is probably some leftover from old code.

--- linux-2.6.9-rc1-mm5.orig/include/linux/swapops.h	2004-09-13 17:34:33.000000000 -0300
+++ linux-2.6.9-rc1-mm5/include/linux/swapops.h	2004-10-08 15:53:39.248697816 -0300
@@ -30,8 +30,7 @@
  */
 static inline unsigned swp_type(swp_entry_t entry)
 {
-	return (entry.val >> SWP_TYPE_SHIFT(entry)) &
-			((1 << MAX_SWAPFILES_SHIFT) - 1);
+	return (entry.val >> SWP_TYPE_SHIFT(entry));
 }
 
 /*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
