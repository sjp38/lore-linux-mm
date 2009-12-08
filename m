Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id ADFA060021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:22 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [1/31] HWPOISON: Add Andi Kleen as hwpoison maintainer to MAINTAINERS
Message-Id: <20091208211617.45C20B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:17 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 MAINTAINERS |    9 +++++++++
 1 file changed, 9 insertions(+)

Index: linux/MAINTAINERS
===================================================================
--- linux.orig/MAINTAINERS
+++ linux/MAINTAINERS
@@ -2322,6 +2322,15 @@ W:	http://www.kernel.org/pub/linux/kerne
 S:	Maintained
 F:	drivers/hwmon/hdaps.c
 
+HWPOISON MEMORY FAILURE HANDLING
+M:	Andi Kleen <andi@firstfloor.org>
+L:	linux-mm@kvack.org
+L:	linux-kernel@vger.kernel.org
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/ak/linux-mce-2.6.git hwpoison
+S:	Maintained
+F:	mm/memory-failure.c
+F:	mm/hwpoison-inject.c
+
 HYPERVISOR VIRTUAL CONSOLE DRIVER
 L:	linuxppc-dev@ozlabs.org
 S:	Odd Fixes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
