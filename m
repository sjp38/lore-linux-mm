Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 069DF6B0088
	for <linux-mm@kvack.org>; Fri, 24 Dec 2010 12:54:15 -0500 (EST)
Date: Fri, 24 Dec 2010 09:52:26 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -mmotm] kptr_restrict: fix build when PRINTK not enabled
Message-Id: <20101224095226.2129fa9c.randy.dunlap@oracle.com>
In-Reply-To: <201012240132.oBO1W8Ub022207@imap1.linux-foundation.org>
References: <201012240132.oBO1W8Ub022207@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, Dan Rosenberg <drosenberg@vsecurity.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

#include <linux/printk.h> since that is where kptr_restrict is externed.

Put kptr_restrict inside #ifdef CONFIG_PRINTK block to fix build error
when CONFIG_PRINTK is not enabled:

kernel/sysctl.c:712: error: 'kptr_restrict' undeclared here (not in a function)

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Dan Rosenberg <drosenberg@vsecurity.com>
---
 kernel/sysctl.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- mmotm-2010-1223-1658.orig/kernel/sysctl.c
+++ mmotm-2010-1223-1658/kernel/sysctl.c
@@ -24,6 +24,7 @@
 #include <linux/slab.h>
 #include <linux/sysctl.h>
 #include <linux/signal.h>
+#include <linux/printk.h>
 #include <linux/proc_fs.h>
 #include <linux/security.h>
 #include <linux/ctype.h>
@@ -706,7 +707,6 @@ static struct ctl_table kern_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one,
 	},
-#endif
 	{
 		.procname	= "kptr_restrict",
 		.data		= &kptr_restrict,
@@ -716,6 +716,7 @@ static struct ctl_table kern_table[] = {
 		.extra1		= &zero,
 		.extra2		= &two,
 	},
+#endif
 	{
 		.procname	= "ngroups_max",
 		.data		= &ngroups_max,



---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
desserts:  http://www.xenotime.net/linux/recipes/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
