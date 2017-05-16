Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DA6666B0374
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:24:12 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u187so131034669pgb.0
        for <linux-mm@kvack.org>; Tue, 16 May 2017 02:24:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o6si8579801pfk.340.2017.05.16.02.24.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 02:24:12 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4G9Nv4r023278
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:24:11 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2afxk1rg1p-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:24:11 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 16 May 2017 03:24:10 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH v2 9/9] powerpc/hugetlb: Enable hugetlb migration for ppc64
Date: Tue, 16 May 2017 14:53:32 +0530
In-Reply-To: <1494926612-23928-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1494926612-23928-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <1494926612-23928-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/platforms/Kconfig.cputype | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index 80175000042d..8acc4f27d101 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -351,6 +351,11 @@ config PPC_RADIX_MMU
 	  is only implemented by IBM Power9 CPUs, if you don't have one of them
 	  you can probably disable this.
 
+config ARCH_ENABLE_HUGEPAGE_MIGRATION
+	def_bool y
+	depends on PPC_BOOK3S_64 && HUGETLB_PAGE && MIGRATION
+
+
 config PPC_MMU_NOHASH
 	def_bool y
 	depends on !PPC_STD_MMU
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
