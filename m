Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2616B026C
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 06:52:53 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v4-v6so11664954oix.2
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 03:52:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d40-v6si8827615oic.337.2018.08.06.03.52.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 03:52:52 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w76An522088590
	for <linux-mm@kvack.org>; Mon, 6 Aug 2018 06:52:51 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kpm989kes-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 06 Aug 2018 06:52:51 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 6 Aug 2018 11:52:49 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 1/3] sparc: mm/init_32: kill trailing whitespace
Date: Mon,  6 Aug 2018 13:52:33 +0300
In-Reply-To: <1533552755-16679-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1533552755-16679-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1533552755-16679-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: Sam Ravnborg <sam@ravnborg.org>, Michal Hocko <mhocko@kernel.org>, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/sparc/mm/init_32.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index 95fe4f0..3ec10b2 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -133,7 +133,7 @@ unsigned long __init bootmem_init(unsigned long *pages_avail)
 	}
 
 	/* Start with page aligned address of last symbol in kernel
-	 * image.  
+	 * image.
 	 */
 	start_pfn  = (unsigned long)__pa(PAGE_ALIGN((unsigned long) &_end));
 
@@ -214,7 +214,7 @@ unsigned long __init bootmem_init(unsigned long *pages_avail)
 		*pages_avail -= PAGE_ALIGN(size) >> PAGE_SHIFT;
 
 		initrd_start = (initrd_start - phys_base) + PAGE_OFFSET;
-		initrd_end = (initrd_end - phys_base) + PAGE_OFFSET;		
+		initrd_end = (initrd_end - phys_base) + PAGE_OFFSET;
 	}
 #endif
 	/* Reserve the kernel text/data/bss. */
@@ -322,7 +322,7 @@ void __init mem_init(void)
 
 		map_high_region(start_pfn, end_pfn);
 	}
-	
+
 	mem_init_print_info(NULL);
 }
 
-- 
2.7.4
