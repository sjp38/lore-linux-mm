Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 57ADE6B7415
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 12:00:47 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id c18-v6so9166061oiy.3
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 09:00:47 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 62-v6si1589529oid.374.2018.09.05.09.00.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 09:00:46 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w85FtXUQ022691
	for <linux-mm@kvack.org>; Wed, 5 Sep 2018 12:00:46 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2maj548jva-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Sep 2018 12:00:20 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 5 Sep 2018 17:00:18 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 09/29] memblock: replace alloc_bootmem_low with memblock_alloc_low
Date: Wed,  5 Sep 2018 18:59:24 +0300
In-Reply-To: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536163184-26356-10-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The functions are equivalent, just the later does not require nobootmem
translation layer.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/x86/kernel/tce_64.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kernel/tce_64.c b/arch/x86/kernel/tce_64.c
index f386bad..54c9b5a 100644
--- a/arch/x86/kernel/tce_64.c
+++ b/arch/x86/kernel/tce_64.c
@@ -173,7 +173,7 @@ void * __init alloc_tce_table(void)
 	size = table_size_to_number_of_entries(specified_table_size);
 	size *= TCE_ENTRY_SIZE;
 
-	return __alloc_bootmem_low(size, size, 0);
+	return memblock_alloc_low(size, size);
 }
 
 void __init free_tce_table(void *tbl)
-- 
2.7.4
