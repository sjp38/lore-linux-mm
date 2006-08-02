Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k72Ktao9014664
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 2 Aug 2006 16:55:36 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k72KtZO6211912
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Wed, 2 Aug 2006 14:55:35 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k72KtZX5022675
	for <linux-mm@kvack.org>; Wed, 2 Aug 2006 14:55:35 -0600
Subject: [RFC][PATCH] enable VMSPLIT for highmem kernels
From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 02 Aug 2006 13:55:33 -0700
Message-Id: <20060802205533.CBD06E21@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>


---

 lxc-dave/arch/i386/Kconfig |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff -puN arch/i386/Kconfig~split-for-pae arch/i386/Kconfig
--- lxc/arch/i386/Kconfig~split-for-pae	2006-08-02 12:58:55.000000000 -0700
+++ lxc-dave/arch/i386/Kconfig	2006-08-02 13:02:55.000000000 -0700
@@ -497,7 +497,7 @@ config HIGHMEM64G
 endchoice
 
 choice
-	depends on EXPERIMENTAL && !X86_PAE
+	depends on EXPERIMENTAL
 	prompt "Memory split" if EMBEDDED
 	default VMSPLIT_3G
 	help
@@ -519,6 +519,7 @@ choice
 	config VMSPLIT_3G
 		bool "3G/1G user/kernel split"
 	config VMSPLIT_3G_OPT
+		depends on !HIGHMEM
 		bool "3G/1G user/kernel split (for full 1G low memory)"
 	config VMSPLIT_2G
 		bool "2G/2G user/kernel split"
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
