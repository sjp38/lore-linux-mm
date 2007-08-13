Date: Sun, 12 Aug 2007 23:31:52 -0700
From: joe@perches.com
Subject: [PATCH] [314/2many] MAINTAINERS - MEMORY MANAGEMENT
Message-ID: <46bffad8.MhCbm7OlOxTaqjoh%joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 2bb7a99..2c60699 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3024,6 +3024,8 @@ L:	linux-mm@kvack.org
 L:	linux-kernel@vger.kernel.org
 W:	http://www.linux-mm.org
 S:	Maintained
+F:	include/linux/mm.h
+F:	mm/
 
 MEMORY TECHNOLOGY DEVICES (MTD)
 P:	David Woodhouse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
