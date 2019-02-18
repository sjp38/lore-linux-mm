Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CE53C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:41:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A36721773
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:41:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A36721773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3E468E0005; Mon, 18 Feb 2019 13:41:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF7288E0002; Mon, 18 Feb 2019 13:41:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8F598E0005; Mon, 18 Feb 2019 13:41:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6DAC28E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:41:51 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id y66so14357707pfg.16
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 10:41:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=arYk/LA4o53pKMejYH43OPCN77EYbT06XyUWDqgGc6g=;
        b=SoxUUu39QQebl1o5wrmJAV9CbU3KDvW9ePXdTFkAOogzSju101k3nsaUNWpeyKaRB7
         A8TtoQi49KwjIAv2piMXSgap9BJROpW6+esGtfoeTDbGgMrbABrCKaq9A5PqS1WLMS+D
         L5m1tYlHErOX/c0U6sLopxbWnbzysuHcJ53AkNgKrsBzBLBk/vU0IJ39adkbyUqGXfRw
         TJIztXxTV2wwL9Y8SsV8Eix6qY07vBIjraOESdcnbjhofX16WwzCVHYlJ+ImXY8SUl4u
         64MZHpZg5AmGfSNx+1RjXQY0OY6U1QiT7tJO25i/TOaJAWw6VttxoUVR9bkCG0lxPUhc
         9J4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubLxHPSqH08+dELEOlZe5Sv39Ka4nP3XMx4uijYFZVo2AvnwX4n
	YWgiqteP9z/q/7ZB6k+PFvdiJClsUR/iAQBRrwqggSONCgRYT98aVdqaW5LHHVspcZ4X0CEwoB7
	6DvZXWmMOYZt1pGG/SNl6tRMUp2rTQGiyrI6zsddVlTfJrQida2xLR9AZWCGvY/uJbQ==
X-Received: by 2002:a62:6702:: with SMTP id b2mr25170385pfc.244.1550515311081;
        Mon, 18 Feb 2019 10:41:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbIEZ41kq+cfK2p7/VHziM0SlZ/3LDQiX/ip5gKSbKHXbG/PrUua1z9WZiDXLNmEATo4Lb+
X-Received: by 2002:a62:6702:: with SMTP id b2mr25170315pfc.244.1550515310037;
        Mon, 18 Feb 2019 10:41:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550515310; cv=none;
        d=google.com; s=arc-20160816;
        b=UE2QxMxWIhPzCA4HYLCDZuLoNuUt57ZHCMP0/rCLHSatuRhswNmziUpHoxcN+KtUNx
         w6Vh0HQPNXw2LOLd1yWgXnfWpLHXZSxzJ0S57Hk7UXSOzucwc/f4psHlOileO4T9NGF8
         gLkwQbEM/lRng3BQDXtmOC6Bar2tBN7/AKW998LyKvhrpKFzaQkh4CyX9adRiUosA6VA
         qdbGKnL359j7UrH3EacyHY9n7LGBXPBuIGRaPRaSlgHie49JUhlxdrrZX4tIpYzWQHK9
         zjY+G6m6AfnGwB+vF5GF7+E0AffHlPTDcgRS+0+EgXfdXNwF2Rbt8JVAdE/6WFf16i8u
         ZbSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=arYk/LA4o53pKMejYH43OPCN77EYbT06XyUWDqgGc6g=;
        b=R7pi7eHGbNu0xc5nAIDv14PgmSmN3aKE60N3vGZy9dEru4OzWnFTnGrxPouDilsic8
         bp8nbq5eO4A/gQ34EOPjdkp18xhnv8SIfg4jjH1tpuuZL0iEkXFRj4dftjWQny7Nzu7W
         Qm/h7o71hqtl75MG/sFQKbgfT9niqls5XrlkF+csJiyrYyN6BZFFUN+Bau/vO4aCPpgL
         H7xeJbL3o0DjT1PirQtWFyUDTq7J6EeMFeh39ckKKyLskf8IUTeZ4lHx0aZe+LDzg7Sp
         xiQvs01E/CYEVjWZnXx0+D3AklHQV20eNhgkE7ms4F1DFg28yfc+c0GlkbKIU3IscGyw
         gMHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f24si13663381pgb.398.2019.02.18.10.41.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 10:41:50 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1IIcqs1057659
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:41:49 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qr151b2n0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:41:49 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 18 Feb 2019 18:41:46 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 18 Feb 2019 18:41:42 -0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1IIffDH19857480
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 18 Feb 2019 18:41:41 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 960314C04A;
	Mon, 18 Feb 2019 18:41:41 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C5DC54C04E;
	Mon, 18 Feb 2019 18:41:37 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.207.239])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 18 Feb 2019 18:41:37 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Mon, 18 Feb 2019 20:41:36 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
        Richard Kuo <rkuo@codeaurora.org>, linux-arch@vger.kernel.org,
        linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-riscv@lists.infradead.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2 1/4] init: provide a generic free_initmem implementation
Date: Mon, 18 Feb 2019 20:41:22 +0200
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1550515285-17446-1-git-send-email-rppt@linux.ibm.com>
References: <1550515285-17446-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19021818-0028-0000-0000-0000034A033B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021818-0029-0000-0000-000024083C64
Message-Id: <1550515285-17446-2-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-18_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=850 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902180138
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For most architectures free_initmem just a wrapper for the same
free_initmem_default(-1) call.
Provide that as a generic implementation marked __weak.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/alpha/mm/init.c      | 6 ------
 arch/arc/mm/init.c        | 8 --------
 arch/c6x/mm/init.c        | 5 -----
 arch/h8300/mm/init.c      | 6 ------
 arch/microblaze/mm/init.c | 5 -----
 arch/nds32/mm/init.c      | 5 -----
 arch/nios2/mm/init.c      | 5 -----
 arch/openrisc/mm/init.c   | 5 -----
 arch/sh/mm/init.c         | 5 -----
 arch/unicore32/mm/init.c  | 5 -----
 arch/xtensa/mm/init.c     | 5 -----
 init/main.c               | 5 +++++
 12 files changed, 5 insertions(+), 60 deletions(-)

diff --git a/arch/alpha/mm/init.c b/arch/alpha/mm/init.c
index 97f4940..e2cbec3 100644
--- a/arch/alpha/mm/init.c
+++ b/arch/alpha/mm/init.c
@@ -285,9 +285,3 @@ mem_init(void)
 	memblock_free_all();
 	mem_init_print_info(NULL);
 }
-
-void
-free_initmem(void)
-{
-	free_initmem_default(-1);
-}
diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
index c357a3b..02b7a3b 100644
--- a/arch/arc/mm/init.c
+++ b/arch/arc/mm/init.c
@@ -206,11 +206,3 @@ void __init mem_init(void)
 	memblock_free_all();
 	mem_init_print_info(NULL);
 }
-
-/*
- * free_initmem: Free all the __init memory.
- */
-void __ref free_initmem(void)
-{
-	free_initmem_default(-1);
-}
diff --git a/arch/c6x/mm/init.c b/arch/c6x/mm/init.c
index 5504b71..3257c53 100644
--- a/arch/c6x/mm/init.c
+++ b/arch/c6x/mm/init.c
@@ -66,8 +66,3 @@ void __init mem_init(void)
 
 	mem_init_print_info(NULL);
 }
-
-void __init free_initmem(void)
-{
-	free_initmem_default(-1);
-}
diff --git a/arch/h8300/mm/init.c b/arch/h8300/mm/init.c
index 2eff00d..73671d0 100644
--- a/arch/h8300/mm/init.c
+++ b/arch/h8300/mm/init.c
@@ -100,9 +100,3 @@ void __init mem_init(void)
 
 	mem_init_print_info(NULL);
 }
-
-void
-free_initmem(void)
-{
-	free_initmem_default(-1);
-}
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index 3bd32de..cf29692 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -186,11 +186,6 @@ void __init setup_memory(void)
 	paging_init();
 }
 
-void free_initmem(void)
-{
-	free_initmem_default(-1);
-}
-
 void __init mem_init(void)
 {
 	high_memory = (void *)__va(memory_start + lowmem_size - 1);
diff --git a/arch/nds32/mm/init.c b/arch/nds32/mm/init.c
index c02e10a..0003187 100644
--- a/arch/nds32/mm/init.c
+++ b/arch/nds32/mm/init.c
@@ -244,11 +244,6 @@ void __init mem_init(void)
 	return;
 }
 
-void free_initmem(void)
-{
-	free_initmem_default(-1);
-}
-
 void __set_fixmap(enum fixed_addresses idx,
 			       phys_addr_t phys, pgprot_t flags)
 {
diff --git a/arch/nios2/mm/init.c b/arch/nios2/mm/init.c
index 60736a7..2c609c2 100644
--- a/arch/nios2/mm/init.c
+++ b/arch/nios2/mm/init.c
@@ -82,11 +82,6 @@ void __init mmu_init(void)
 	flush_tlb_all();
 }
 
-void __ref free_initmem(void)
-{
-	free_initmem_default(-1);
-}
-
 #define __page_aligned(order) __aligned(PAGE_SIZE << (order))
 pgd_t swapper_pg_dir[PTRS_PER_PGD] __page_aligned(PGD_ORDER);
 pte_t invalid_pte_table[PTRS_PER_PTE] __page_aligned(PTE_ORDER);
diff --git a/arch/openrisc/mm/init.c b/arch/openrisc/mm/init.c
index d0d94a4..aa83f7d 100644
--- a/arch/openrisc/mm/init.c
+++ b/arch/openrisc/mm/init.c
@@ -220,8 +220,3 @@ void __init mem_init(void)
 	mem_init_done = 1;
 	return;
 }
-
-void free_initmem(void)
-{
-	free_initmem_default(-1);
-}
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 2fa824336..ca9761b 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -405,11 +405,6 @@ void __init mem_init(void)
 	mem_init_done = 1;
 }
 
-void free_initmem(void)
-{
-	free_initmem_default(-1);
-}
-
 #ifdef CONFIG_MEMORY_HOTPLUG
 int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 		bool want_memblock)
diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
index 01271ce..2c52d9b 100644
--- a/arch/unicore32/mm/init.c
+++ b/arch/unicore32/mm/init.c
@@ -311,8 +311,3 @@ void __init mem_init(void)
 		sysctl_overcommit_memory = OVERCOMMIT_ALWAYS;
 	}
 }
-
-void free_initmem(void)
-{
-	free_initmem_default(-1);
-}
diff --git a/arch/xtensa/mm/init.c b/arch/xtensa/mm/init.c
index d498610..b51746f 100644
--- a/arch/xtensa/mm/init.c
+++ b/arch/xtensa/mm/init.c
@@ -216,11 +216,6 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 }
 #endif
 
-void free_initmem(void)
-{
-	free_initmem_default(-1);
-}
-
 static void __init parse_memmap_one(char *p)
 {
 	char *oldp;
diff --git a/init/main.c b/init/main.c
index c86a1c8..38d69e0 100644
--- a/init/main.c
+++ b/init/main.c
@@ -1047,6 +1047,11 @@ static inline void mark_readonly(void)
 }
 #endif
 
+void __weak free_initmem(void)
+{
+	free_initmem_default(-1);
+}
+
 static int __ref kernel_init(void *unused)
 {
 	int ret;
-- 
2.7.4

