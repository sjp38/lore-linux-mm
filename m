Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17uRPp-0002jE-00
	for <linux-mm@kvack.org>; Wed, 25 Sep 2002 22:42:21 -0700
Date: Wed, 25 Sep 2002 22:42:20 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: [1/13] add __GFP_NOKILL
Message-ID: <20020926054220.GH22942@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

__GFP_NOKILL has the semantics that OOM killing should never result
from the given allocation. Instead, the allocation should be failed,
as it's not indicative of the system being truly out of memory, only
that the given call cannot be serviced.

The series of patches using this flag to prevent spurious OOM killing
were all done in response to specific OOM's observed during testing.


diff -urN linux-2.5.33/include/linux/gfp.h linux-2.5.33-mm5/include/linux/gfp.h
--- linux-2.5.33/include/linux/gfp.h	2002-08-31 15:04:53.000000000 -0700
+++ linux-2.5.33-mm5/include/linux/gfp.h	2002-09-08 19:52:51.000000000 -0700
@@ -17,6 +17,7 @@
 #define __GFP_IO	0x40	/* Can start low memory physical IO? */
 #define __GFP_HIGHIO	0x80	/* Can start high mem physical IO? */
 #define __GFP_FS	0x100	/* Can call down to low-level FS? */
+#define __GFP_NOKILL	0x200	/* Should not OOM kill */
 
 #define GFP_NOHIGHIO	(             __GFP_WAIT | __GFP_IO)
 #define GFP_NOIO	(             __GFP_WAIT)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
