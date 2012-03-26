Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 47DEE6B004D
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:11:34 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 37/39] autonuma: add CONFIG_AUTONUMA and CONFIG_AUTONUMA_DEFAULT_ENABLED
Date: Mon, 26 Mar 2012 19:46:24 +0200
Message-Id: <1332783986-24195-38-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

Add the config options to allow building the kernel with AutoNUMA.

If CONFIG_AUTONUMA_DEFAULT_ENABLED is "=y", then
/sys/kernel/mm/autonuma/enabled will be equal to 1, and AutoNUMA will
be enabled automatically at boot.

CONFIG_AUTONUMA currently depends on X86, because no other arch
implements the pte/pmd_numa yet and selecting =y would result in a
failed build, but this shall be relaxed in the future. Porting
AutoNUMA to other archs should be pretty simple.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/Kconfig |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index e338407..cbfdb15 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -207,6 +207,19 @@ config MIGRATION
 	  pages as migration can relocate pages to satisfy a huge page
 	  allocation instead of reclaiming.
 
+config AUTONUMA
+	bool "Auto NUMA"
+	select MIGRATION
+	depends on NUMA && X86
+	help
+	  Automatic NUMA CPU scheduling and memory migration.
+
+config AUTONUMA_DEFAULT_ENABLED
+	bool "Auto NUMA default enabled"
+	depends on AUTONUMA
+	help
+	  Automatic NUMA CPU scheduling and memory migration enabled at boot.
+
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
