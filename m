Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 86E1F6B0260
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 16:07:10 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 1so22345804wmz.2
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 13:07:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m133si4361494wmf.95.2016.09.14.13.07.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 13:07:09 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8EK4tj8108278
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 16:07:08 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25eyhba7rt-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 16:07:07 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 14 Sep 2016 14:07:06 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH v2 3/3] mm: enable CONFIG_MOVABLE_NODE on powerpc
Date: Wed, 14 Sep 2016 15:06:58 -0500
In-Reply-To: <1473883618-14998-1-git-send-email-arbab@linux.vnet.ibm.com>
References: <1473883618-14998-1-git-send-email-arbab@linux.vnet.ibm.com>
Message-Id: <1473883618-14998-4-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org

Onlining memory into ZONE_MOVABLE requires CONFIG_MOVABLE_NODE. Enable
the use of this config option on PPC64 platforms.

Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---
 Documentation/kernel-parameters.txt | 2 +-
 mm/Kconfig                          | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index a4f4d69..3d8460d 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2344,7 +2344,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			that the amount of memory usable for all allocations
 			is not too small.
 
-	movable_node	[KNL,X86] Boot-time switch to enable the effects
+	movable_node	[KNL,X86,PPC] Boot-time switch to enable the effects
 			of CONFIG_MOVABLE_NODE=y. See mm/Kconfig for details.
 
 	MTD_Partition=	[MTD]
diff --git a/mm/Kconfig b/mm/Kconfig
index be0ee11..4b19cd3 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -153,7 +153,7 @@ config MOVABLE_NODE
 	bool "Enable to assign a node which has only movable memory"
 	depends on HAVE_MEMBLOCK
 	depends on NO_BOOTMEM
-	depends on X86_64
+	depends on X86_64 || PPC64
 	depends on NUMA
 	default n
 	help
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
