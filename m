Date: Wed, 18 Jul 2001 13:15:07 -0500
From: Dave McCracken <dmc@austin.ibm.com>
Subject: Patch for swap usage of high memory
Message-ID: <12200000.995480107@baldur>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch fixes the problem where pages allocated for swap space reads 
will not be allocated from high memory.

Rik, could you please forward this to the kernel mailing list?  I am 
temporarily unable to reach it directly due to ECN problems.

Thanks,
Dave McCracken

--------

--- linux-2.4.6/mm/swap_state.c	Mon Jun 11 21:15:27 2001
+++ linux-2.4.6-mm/mm/swap_state.c	Wed Jul 18 12:56:01 2001
@@ -226,7 +226,7 @@
 	if (found_page)
 		goto out_free_swap;

-	new_page = alloc_page(GFP_USER);
+	new_page = alloc_page(GFP_HIGHUSER);
 	if (!new_page)
 		goto out_free_swap;	/* Out of memory */

--------

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmc@austin.ibm.com                                      T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
