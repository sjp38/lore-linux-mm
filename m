Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2D91C282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:16:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8ACCD217D9
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:16:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8ACCD217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1894E8E0006; Tue, 12 Feb 2019 10:16:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13A0A8E0001; Tue, 12 Feb 2019 10:16:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0021C8E0006; Tue, 12 Feb 2019 10:16:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C799B8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:16:24 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id q81so16059030qkl.20
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:16:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=z2Tr3mqfbDIR0O1VvTG+kv+1uGI8ns9GQkl7idfPgow=;
        b=dKLhrlAEob3EsNdL930hQs4RQb+53YADlm7IkjAa3bx+W3g4tNdlzR51L+O0KCc3uA
         cdpVA4i/WVTukep3OGc1dq0oTc7oecs6jLE1YyViZdbt5AxMBLIKssQOKfgorIn9uv8Z
         WUxWrC6qf+KTdC5SlPXdt6MhIR+eqHldYXYFf5iVyRvjR0ciolRwdXmaN2lKi7s3Bg3o
         nv6F8b/QAk/jXeKyiWgOMYAfSxfi/iHffmMPnX3b+5bqFy7wx9O0zcpn4NwBPh/4ZNBP
         rK4KJOE71xuL/7ubjuucsHmdQSMiO6HxqSrtUbCohe/zaOij56J6O1ICtwDt8iUYcCGb
         E/pg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZjzNmZQnNKoExoDwfEYjekEuSghN+2dY4M6bZPVcebM6dNZnUR
	ayH8tGnbu7CdGniZEYc+/Ir1H1rgfoSmwgP0opUYasbThEN1wIcEQ7nKOCalTF+McX5myuDOz3P
	2aVSltkhCdIv9aaXEwSSeKM6HmRbMQndPHm1eZvz/034QQdEmt7cl2k60t5+KpbGV4g==
X-Received: by 2002:ac8:1e84:: with SMTP id c4mr3195292qtm.181.1549984584572;
        Tue, 12 Feb 2019 07:16:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZnX37YrXJwbd7wBgRKFdGHCbwuTIObgULYY0FGIA99jumGUqId56XnC+W/a621HFQ8NMnR
X-Received: by 2002:ac8:1e84:: with SMTP id c4mr3195248qtm.181.1549984583847;
        Tue, 12 Feb 2019 07:16:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549984583; cv=none;
        d=google.com; s=arc-20160816;
        b=yhOZHqfPNWBNs/2d0uFyru63g7eM7F9nZnhxn4ZNmvU0p0m+kq8O7li/wscxWPgBzP
         E7CDs6YvdLWmteDwzfeCrmrXQ1ph5VZeFkmGvBzaZK4dH7Ef1tjaNsX1LcCkHi7jIkMr
         cVgc02ewsuFRd2YgADBqnnvxxlNnRf0QEmRQxEKzGxjUFlk2CZ+ZMG9ggRVN0L/wfiQp
         2+9VoO6RxGGrbbuC+vF3SD7OImoKmVz5is4TcvYnvanraUCXsob9eFIpqLLU0oHbYy5t
         abrTomMCTxXSYbuTU4/nxvb/8sYDy9C0TbtOpNpfw0OWGxtFamr7cEjHAHq/24TwrAXJ
         0l+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=z2Tr3mqfbDIR0O1VvTG+kv+1uGI8ns9GQkl7idfPgow=;
        b=jAS4a7jPOiwey9b6VLM3qZPuSPXiY1T6ed5wkL0hnzlTbaQzY6S1ngnF5hveesyMO8
         Ec4OUO/9RFYf+tyQ4erqCmxo6jTqRx2YfEOWtJo+YjGtRIU6NXkzfab+ESJw+6Hmh1qk
         +q2SoNNURyKebuBtmvb0R29J4qhEoaC1lqWEowZyeVySzAIS86kNGnxQHAe8FGA0aZVP
         gPop0iIsD42Sienag1+1H8JzGJ1X8TvnlO6TeU4HWfexn7vW7HTSdwfP1uNoJZjPSfPK
         yWA/skfMrjwiWasyoi8VonModbZEq5fOaLcAhgWGVRgKUcwn4WVsKM4lLz+eefUYFZrT
         TCDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c35si76285qve.212.2019.02.12.07.16.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 07:16:23 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1CFCJuF095753
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:16:23 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qkym0uc7t-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:16:22 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 12 Feb 2019 15:16:20 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 12 Feb 2019 15:16:17 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1CFGGs59175332
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 12 Feb 2019 15:16:16 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0F389A405B;
	Tue, 12 Feb 2019 15:16:16 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7DCA7A4062;
	Tue, 12 Feb 2019 15:16:14 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.59.139])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 12 Feb 2019 15:16:14 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Tue, 12 Feb 2019 17:16:13 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
        Helge Deller <deller@gmx.de>
Cc: Matthew Wilcox <willy@infradead.org>, linux-parisc@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2] parisc: use memblock_alloc() instead of custom get_memblock()
Date: Tue, 12 Feb 2019 17:16:12 +0200
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19021215-0016-0000-0000-000002559364
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021215-0017-0000-0000-000032AFB5C7
Message-Id: <1549984572-10867-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-12_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902120108
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The get_memblock() function implements custom bottom-up memblock allocator.
Setting 'memblock_bottom_up = true' before any memblock allocation is done
allows replacing get_memblock() calls with memblock_alloc().

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
v2: fix allocation alignment

 arch/parisc/mm/init.c | 52 +++++++++++++++++++--------------------------------
 1 file changed, 19 insertions(+), 33 deletions(-)

diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 059187a..d0b1662 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -79,36 +79,6 @@ static struct resource sysram_resources[MAX_PHYSMEM_RANGES] __read_mostly;
 physmem_range_t pmem_ranges[MAX_PHYSMEM_RANGES] __read_mostly;
 int npmem_ranges __read_mostly;
 
-/*
- * get_memblock() allocates pages via memblock.
- * We can't use memblock_find_in_range(0, KERNEL_INITIAL_SIZE) here since it
- * doesn't allocate from bottom to top which is needed because we only created
- * the initial mapping up to KERNEL_INITIAL_SIZE in the assembly bootup code.
- */
-static void * __init get_memblock(unsigned long size)
-{
-	static phys_addr_t search_addr __initdata;
-	phys_addr_t phys;
-
-	if (!search_addr)
-		search_addr = PAGE_ALIGN(__pa((unsigned long) &_end));
-	search_addr = ALIGN(search_addr, size);
-	while (!memblock_is_region_memory(search_addr, size) ||
-		memblock_is_region_reserved(search_addr, size)) {
-		search_addr += size;
-	}
-	phys = search_addr;
-
-	if (phys)
-		memblock_reserve(phys, size);
-	else
-		panic("get_memblock() failed.\n");
-
-	memset(__va(phys), 0, size);
-
-	return __va(phys);
-}
-
 #ifdef CONFIG_64BIT
 #define MAX_MEM         (~0UL)
 #else /* !CONFIG_64BIT */
@@ -321,6 +291,13 @@ static void __init setup_bootmem(void)
 			max_pfn = start_pfn + npages;
 	}
 
+	/*
+	 * We can't use memblock top-down allocations because we only
+	 * created the initial mapping up to KERNEL_INITIAL_SIZE in
+	 * the assembly bootup code.
+	 */
+	memblock_set_bottom_up(true);
+
 	/* IOMMU is always used to access "high mem" on those boxes
 	 * that can support enough mem that a PCI device couldn't
 	 * directly DMA to any physical addresses.
@@ -442,7 +419,10 @@ static void __init map_pages(unsigned long start_vaddr,
 		 */
 
 		if (!pmd) {
-			pmd = (pmd_t *) get_memblock(PAGE_SIZE << PMD_ORDER);
+			pmd = memblock_alloc(PAGE_SIZE << PMD_ORDER,
+					     PAGE_SIZE << PMD_ORDER);
+			if (!pmd)
+				panic("pmd allocation failed.\n");
 			pmd = (pmd_t *) __pa(pmd);
 		}
 
@@ -461,7 +441,10 @@ static void __init map_pages(unsigned long start_vaddr,
 
 			pg_table = (pte_t *)pmd_address(*pmd);
 			if (!pg_table) {
-				pg_table = (pte_t *) get_memblock(PAGE_SIZE);
+				pg_table = memblock_alloc(PAGE_SIZE,
+							  PAGE_SIZE);
+				if (!pg_table)
+					panic("page table allocation failed\n");
 				pg_table = (pte_t *) __pa(pg_table);
 			}
 
@@ -700,7 +683,10 @@ static void __init pagetable_init(void)
 	}
 #endif
 
-	empty_zero_page = get_memblock(PAGE_SIZE);
+	empty_zero_page = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+	if (!empty_zero_page)
+		panic("zero page allocation failed.\n");
+
 }
 
 static void __init gateway_init(void)
-- 
2.7.4

