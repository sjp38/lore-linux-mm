Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7576B000A
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 02:28:37 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12-v6so1715449edi.12
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 23:28:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a24-v6si1154621edm.339.2018.07.03.23.28.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 23:28:36 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w646O9lu050981
	for <linux-mm@kvack.org>; Wed, 4 Jul 2018 02:28:34 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k0k43v2ky-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Jul 2018 02:28:33 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 4 Jul 2018 07:28:31 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 2/3] m68k/page_no.h: force __va argument to be unsigned long
Date: Wed,  4 Jul 2018 09:28:15 +0300
In-Reply-To: <1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1530685696-14672-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>
Cc: Michal Hocko <mhocko@kernel.org>, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Add explicit casting to unsigned long to the __va() parameter

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/m68k/include/asm/page_no.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/m68k/include/asm/page_no.h b/arch/m68k/include/asm/page_no.h
index e644c4d..6bbe520 100644
--- a/arch/m68k/include/asm/page_no.h
+++ b/arch/m68k/include/asm/page_no.h
@@ -18,7 +18,7 @@ extern unsigned long memory_end;
 #define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
 
 #define __pa(vaddr)		((unsigned long)(vaddr))
-#define __va(paddr)		((void *)(paddr))
+#define __va(paddr)		((void *)((unsigned long)(paddr)))
 
 #define virt_to_pfn(kaddr)	(__pa(kaddr) >> PAGE_SHIFT)
 #define pfn_to_virt(pfn)	__va((pfn) << PAGE_SHIFT)
-- 
2.7.4
