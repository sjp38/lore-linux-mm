Date: Sun, 12 Aug 2007 23:35:53 -0700
From: joe@perches.com
Subject: [PATCH] [438/2many] MAINTAINERS - SLAB ALLOCATOR
Message-ID: <46bffbc9.9Jtz7kOTKn1mqlkq%joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org, clameter@sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index b2dd6f5..a3c6123 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4168,6 +4168,8 @@ P:	Pekka Enberg
 M:	penberg@cs.helsinki.fi
 L:	linux-mm@kvack.org
 S:	Maintained
+F:	include/linux/slab*
+F:	mm/slab.c
 
 SMC91x ETHERNET DRIVER
 P:	Nicolas Pitre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
