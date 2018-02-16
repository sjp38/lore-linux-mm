Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FC106B000A
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:26:05 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id x13so2853084ywi.22
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 07:26:05 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g207si863028qke.137.2018.02.16.07.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 07:26:04 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1GFODdG078152
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:26:03 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2g61dm9etk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:26:02 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 16 Feb 2018 15:25:59 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v8 03/24] powerpc/mm: Define CONFIG_SPECULATIVE_PAGE_FAULT
Date: Fri, 16 Feb 2018 16:25:17 +0100
In-Reply-To: <1518794738-4186-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1518794738-4186-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1518794738-4186-4-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Define CONFIG_SPECULATIVE_PAGE_FAULT for BOOK3S_64 and SMP. This enables
the Speculative Page Fault handler.

Support is only provide for BOOK3S_64 currently because:
- require CONFIG_PPC_STD_MMU because checks done in
  set_access_flags_filter()
- require BOOK3S because we can't support for book3e_hugetlb_preload()
  called by update_mmu_cache()

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 arch/powerpc/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 73ce5dd07642..acf2696a6505 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -233,6 +233,7 @@ config PPC
 	select OLD_SIGACTION			if PPC32
 	select OLD_SIGSUSPEND
 	select SPARSE_IRQ
+	select SPECULATIVE_PAGE_FAULT		if PPC_BOOK3S_64 && SMP
 	select SYSCTL_EXCEPTION_TRACE
 	select VIRT_TO_BUS			if !PPC64
 	#
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
