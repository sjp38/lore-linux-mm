Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id D33C76B0005
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:44:52 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 15:44:51 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id F253338C8045
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:44:48 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SKim3v294016
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:44:48 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SKimrK023806
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:44:48 -0500
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 02/24] XXX: x86/Kconfig: simplify NUMA config for NUMA_EMU on X86_32.
Date: Thu, 28 Feb 2013 12:44:10 -0800
Message-Id: <1362084272-11282-3-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <20130228024112.GA24970@negative>
 <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: David Hansen <dave@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

NUMA_EMU depends on NUMA.
NUMA depends on (X86_64 || (X86_32 && ( list of extended platforms))).

This forced enabling an extended platform when using numa emulation on
x86_32, which is silly.

Remoing the list of extended platforms (plus EXPERIMENTAL) results in
NUMA depending on X86_64 || X86_32, so simply remove all dependencies
from (except SMP) from NUMA.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 arch/x86/Kconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 6a93833..58cd8fb 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1228,7 +1228,6 @@ config DIRECT_GBPAGES
 config NUMA
 	bool "Numa Memory Allocation and Scheduler Support"
 	depends on SMP
-	depends on X86_64 || (X86_32 && HIGHMEM64G && (X86_NUMAQ || X86_BIGSMP || X86_SUMMIT && ACPI))
 	default y if (X86_NUMAQ || X86_SUMMIT || X86_BIGSMP)
 	---help---
 	  Enable NUMA (Non Uniform Memory Access) support.
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
