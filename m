Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 821556B000D
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:45:10 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 15:45:09 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id C848FC90025
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:44:47 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SKilPd313414
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:44:47 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SKilI8032567
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 17:44:47 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 01/24] XXX: reduce MAX_PHYSADDR_BITS & MAX_PHYSMEM_BITS in PAE.
Date: Thu, 28 Feb 2013 12:44:09 -0800
Message-Id: <1362084272-11282-2-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <20130228024112.GA24970@negative>
 <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: David Hansen <dave@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

This is a hack I use to allow PAE to be enabled & still fit the node
into the pageflags (PAE is enabled as a workaround for a kvm bug).

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 arch/x86/include/asm/sparsemem.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/sparsemem.h b/arch/x86/include/asm/sparsemem.h
index 4517d6b..548e612 100644
--- a/arch/x86/include/asm/sparsemem.h
+++ b/arch/x86/include/asm/sparsemem.h
@@ -17,8 +17,8 @@
 #ifdef CONFIG_X86_32
 # ifdef CONFIG_X86_PAE
 #  define SECTION_SIZE_BITS	29
-#  define MAX_PHYSADDR_BITS	36
-#  define MAX_PHYSMEM_BITS	36
+#  define MAX_PHYSADDR_BITS	32
+#  define MAX_PHYSMEM_BITS	32
 # else
 #  define SECTION_SIZE_BITS	26
 #  define MAX_PHYSADDR_BITS	32
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
