Date: Wed, 29 Oct 2008 09:49:18 +0800
From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH/RESEND] include/linux/mca-legacy.h: Fix the warning of note
Message-ID: <20081029014918.GA9649@ubuntu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 include/linux/mca-legacy.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/mca-legacy.h b/include/linux/mca-legacy.h
index 7a3aea8..e349f2b 100644
--- a/include/linux/mca-legacy.h
+++ b/include/linux/mca-legacy.h
@@ -9,7 +9,7 @@
 
 #include <linux/mca.h>
 
-#warning "MCA legacy - please move your driver to the new sysfs api"
+/* warning "MCA legacy - please move your driver to the new sysfs api" */
 
 /* MCA_NOTFOUND is an error condition.  The other two indicate
  * motherboard POS registers contain the adapter.  They might be
-- 
1.5.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
