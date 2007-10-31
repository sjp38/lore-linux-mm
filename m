Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l9VEisfI003919
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 10:44:54 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9VFjBfb032574
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 09:45:12 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9VFjAjT023983
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 09:45:11 -0600
Subject: [PATCH 2/3] Enable hotplug memory remove for ppc64
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Wed, 31 Oct 2007 08:48:39 -0800
Message-Id: <1193849319.17412.32.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linuxppc-dev@ozlabs.org, anton@au1.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Enable hotplug memory remove for ppc64.

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
---
 arch/powerpc/Kconfig |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6.23/arch/powerpc/Kconfig
===================================================================
--- linux-2.6.23.orig/arch/powerpc/Kconfig	2007-10-23 09:39:29.000000000 -0700
+++ linux-2.6.23/arch/powerpc/Kconfig	2007-10-25 11:44:57.000000000 -0700
@@ -234,6 +234,9 @@ config HOTPLUG_CPU
 config ARCH_ENABLE_MEMORY_HOTPLUG
 	def_bool y
 
+config ARCH_ENABLE_MEMORY_HOTREMOVE
+	def_bool y
+
 config KEXEC
 	bool "kexec system call (EXPERIMENTAL)"
 	depends on (PPC_PRPMC2800 || PPC_MULTIPLATFORM) && EXPERIMENTAL


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
