Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id AB9FC6B13F1
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 03:15:57 -0500 (EST)
Date: Sun, 5 Feb 2012 16:15:50 +0800
From: Dave Young <dyoung@redhat.com>
Subject: [PATCH 2/3] move slabinfo.c to tools/vm
Message-ID: <20120205081550.GA2247@darkstar.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, xiyou.wangcong@gmail.com, penberg@kernel.org, fengguang.wu@intel.com, cl@linux.com

We have tools/vm/ folder for vm tools, so move slabinfo.c
from tools/slub/ to tools/vm/

Signed-off-by: Dave Young <dyoung@redhat.com>
---
 tools/vm/Makefile             |    4 ++--
 tools/{slub => vm}/slabinfo.c |    0
 2 files changed, 2 insertions(+), 2 deletions(-)
 rename tools/{slub => vm}/slabinfo.c (100%)

diff --git a/tools/vm/Makefile b/tools/vm/Makefile
index 3823d4b..8e30e5c 100644
--- a/tools/vm/Makefile
+++ b/tools/vm/Makefile
@@ -3,9 +3,9 @@
 CC = $(CROSS_COMPILE)gcc
 CFLAGS = -Wall -Wextra
 
-all: page-types
+all: page-types slabinfo
 %: %.c
 	$(CC) $(CFLAGS) -o $@ $^
 
 clean:
-	$(RM) page-types
+	$(RM) page-types slabinfo
diff --git a/tools/slub/slabinfo.c b/tools/vm/slabinfo.c
similarity index 100%
rename from tools/slub/slabinfo.c
rename to tools/vm/slabinfo.c
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
