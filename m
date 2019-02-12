Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B82D9C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:00:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F58E20823
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:00:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F58E20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE2F28E0003; Tue, 12 Feb 2019 09:00:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E921C8E0001; Tue, 12 Feb 2019 09:00:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D80EE8E0003; Tue, 12 Feb 2019 09:00:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id AEAE38E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:00:04 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id p5so2822826qtp.3
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 06:00:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=LRU1q5dgVuCMjeCBG2gh4rpe3Jy20ONg0to0d1bil0k=;
        b=kfuXh1JrT0gA/cfV97hNKHpcNjl57Sl2tZaKEFz47I3GGNP67/7bkA9ktrtpG0PQd+
         76GMCmB2CdTZ6Al/QDewFdrNdboJlQ7ZlhznID4nk8qKc3Dkxw4TG9BL/3JuaaXGeQ9l
         rs9S4lbEcJiLxwjJMl8g1ijETGoA2902zKJaDXxRGbxVGXC2Cr2d4Fo0X5tN4OTw9lkk
         zKuoBErDAaUTuHPayVIePLGFYHoW/SnHgoKcxI3usCd0qrPpz/5e9aHd4lSzyfoZKvmt
         Mez0t2U15VqhruyjT/mjqYRKYrcePvd5eLh4y+Uqa9HC0vTXXo8R/8wHwJXXZE8zFe8G
         FiZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuaJa05BuTBW2qn1drzvFA3MeqVAKY/PdWtQh3g/Yb/MxBuyrrDI
	u8ymURp4lkRnywIXGmjWrSkkFwG4Hxucu49VNauMfq65Vx6odJ+vdN9ZnR9/F3X6Kj/4siisUus
	einyYkP1sio67iRavx/5ujFXVHhWDsP2kpRfPJzmZAJRNObA2Oo4ducPd425bG184+w==
X-Received: by 2002:a37:6bc1:: with SMTP id g184mr2664803qkc.236.1549980004472;
        Tue, 12 Feb 2019 06:00:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZh5Y/zoJJGFVlsEwGsPTF6zDe5ujdGS1O05r0IdavyDexB3FaLajvldiUhv90MVilx6zfX
X-Received: by 2002:a37:6bc1:: with SMTP id g184mr2664727qkc.236.1549980003502;
        Tue, 12 Feb 2019 06:00:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549980003; cv=none;
        d=google.com; s=arc-20160816;
        b=zvRrYmo+l7vCDulfsHi7QNLm5Ssox5L7Bu+RIv2DjGejTVSad5uJ/hn83kP1JXzYhu
         u9QmHgtBCIspLnIeOSQisUnposzxQUwDjReOiYT4bQnef7oVeXfmqFVFYd64TLIlcy5f
         ZfwPupoH7DzKUREarC6rTK0mwmma/1vKo/yV7vbwkIGNFSy91TYEH4hDBanjRh6Vy7Hw
         VV+vM7o8uxnR9QPasgftdZJBOSyK3waaPwMSzdpJMiNV3MMD+FZmzSzGA2hHMfNk5RqJ
         TpvVmL1mVYTU+dGBPWlan/Z1AmzR7vY7v7ry9MEkXECuUAJBL/+xkJmsKGDKv1fAOVGm
         dg7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=LRU1q5dgVuCMjeCBG2gh4rpe3Jy20ONg0to0d1bil0k=;
        b=MCSG9l7rPjx73h2VyeZClmKUSBgXbOfZp6UXRoJFXDIc6ZfVt+NWvjQSPD/TvqL30p
         pH4+GPnYvWfUuNnqypE5b3c+qALMwozqK9VnoM2vOYAbgjaOYDtraSRe2di/7tsPdwSG
         BaHU0VAiLXydVAr697+nhnBTHl7nj8X9MPGn6r5lQGEp8aIv1eeo2bX/eHYqMtZ22iiD
         J4coEkTbe3GzofEFYzwi19qwtrYwVuoiipOmF6pKijGbnQMvRJiW1zPtUhaVoctfI6I0
         P2groi946JHI6axam0z9TfpmdvsTzFy7Dq202U+V08Tj1siNI/LTLPxZPGbW5Qef3yLU
         z1ew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w65si938379qka.212.2019.02.12.06.00.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 06:00:03 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1CDs895107992
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:00:02 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qkwjewm8k-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:00:01 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 12 Feb 2019 13:59:57 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 12 Feb 2019 13:59:54 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1CDxrWA44826686
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 12 Feb 2019 13:59:53 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B3B2EA404D;
	Tue, 12 Feb 2019 13:59:53 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3C4DCA4040;
	Tue, 12 Feb 2019 13:59:52 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.59.139])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 12 Feb 2019 13:59:52 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Tue, 12 Feb 2019 15:59:51 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
        Helge Deller <deller@gmx.de>
Cc: linux-parisc@vger.kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] parisc: use memblock_alloc() instead of custom get_memblock()
Date: Tue, 12 Feb 2019 15:59:50 +0200
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19021213-0028-0000-0000-00000347ABD2
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021213-0029-0000-0000-00002405CBB7
Message-Id: <1549979990-6642-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-12_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 lowpriorityscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902120101
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
 arch/parisc/mm/init.c | 52 +++++++++++++++++++--------------------------------
 1 file changed, 19 insertions(+), 33 deletions(-)

diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 059187a..38b928e 100644
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
+					     SMP_CACHE_BYTES);
+			if (!pmd)
+				panic("pmd allocation failed.\n");
 			pmd = (pmd_t *) __pa(pmd);
 		}
 
@@ -461,7 +441,10 @@ static void __init map_pages(unsigned long start_vaddr,
 
 			pg_table = (pte_t *)pmd_address(*pmd);
 			if (!pg_table) {
-				pg_table = (pte_t *) get_memblock(PAGE_SIZE);
+				pg_table = memblock_alloc(PAGE_SIZE,
+							  SMP_CACHE_BYTES);
+				if (!pg_table)
+					panic("page table allocation failed\n");
 				pg_table = (pte_t *) __pa(pg_table);
 			}
 
@@ -700,7 +683,10 @@ static void __init pagetable_init(void)
 	}
 #endif
 
-	empty_zero_page = get_memblock(PAGE_SIZE);
+	empty_zero_page = memblock_alloc(PAGE_SIZE, SMP_CACHE_BYTES);
+	if (!empty_zero_page)
+		panic("zero page allocation failed.\n");
+
 }
 
 static void __init gateway_init(void)
-- 
2.7.4

