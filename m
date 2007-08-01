Subject: [PATCH] 2.6.23-rc1-mm1 - fix missing numa_zonelist_order sysctl
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Wed, 01 Aug 2007 15:02:51 -0400
Message-Id: <1185994972.5059.91.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Fix missing numa_zonelist_order sysctl config

Against 2.6.23-rc1-mm1.

Found this testing Mel Gorman's patch for the issue with
"policy_zone" and ZONE_MOVABLE.

Misplaced #endif is hiding the numa_zonelist_order sysctl
when !SECURITY.

[But, maybe reordering the zonelists is not such a good idea
when ZONE_MOVABLE is populated?]

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 kernel/sysctl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: Linux/kernel/sysctl.c
===================================================================
--- Linux.orig/kernel/sysctl.c	2007-07-25 09:29:50.000000000 -0400
+++ Linux/kernel/sysctl.c	2007-08-01 13:29:18.000000000 -0400
@@ -1068,6 +1068,7 @@ static ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_doulongvec_minmax,
 	},
+#endif
 #ifdef CONFIG_NUMA
 	{
 		.ctl_name	= CTL_UNNUMBERED,
@@ -1079,7 +1080,6 @@ static ctl_table vm_table[] = {
 		.strategy	= &sysctl_string,
 	},
 #endif
-#endif
 #if defined(CONFIG_X86_32) || \
    (defined(CONFIG_SUPERH) && defined(CONFIG_VSYSCALL))
 	{


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
