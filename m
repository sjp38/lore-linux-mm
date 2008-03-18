From: Andi Kleen <andi@firstfloor.org>
References: <20080318209.039112899@firstfloor.org>
In-Reply-To: <20080318209.039112899@firstfloor.org>
Subject: [PATCH prototype] [7/8] Add the sysctls to control pbitmaps
Message-Id: <20080318010941.602271B41E1@basil.firstfloor.org>
Date: Tue, 18 Mar 2008 02:09:41 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

- pbitmap_enabled: Master switch for pbitmap
- pbitmap_early_fault: Control whether pbitmap should do
early page faults or not. Default on.
- pbitmap_update_interval: How often the pbitmap should
be updated on disk.

Signed-off-by: Andi Kleen <andi@firstfloor.org>

---
 kernel/sysctl.c |   30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

Index: linux/kernel/sysctl.c
===================================================================
--- linux.orig/kernel/sysctl.c
+++ linux/kernel/sysctl.c
@@ -1044,6 +1044,36 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 	},
 	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "pbitmap_enabled",
+		.data		= &pbitmap_enabled,
+		.maxlen 	= sizeof(pbitmap_enabled),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec,
+		.extra1 	= &zero,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "pbitmap_early_fault",
+		.data		= &pbitmap_early_fault,
+		.maxlen 	= sizeof(pbitmap_early_fault),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec,
+		.extra1 	= &zero,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "pbitmap_update_interval",
+		.data		= &pbitmap_update_interval,
+		.maxlen 	= sizeof(pbitmap_update_interval),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec,
+		.extra1 	= &zero,
+	},
+	{
 		.ctl_name	= VM_VFS_CACHE_PRESSURE,
 		.procname	= "vfs_cache_pressure",
 		.data		= &sysctl_vfs_cache_pressure,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
