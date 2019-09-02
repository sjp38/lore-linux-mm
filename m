Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B25FC3A5A5
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 14:11:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A8A221744
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 14:11:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A8A221744
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F166C6B0006; Mon,  2 Sep 2019 10:10:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4FD66B000C; Mon,  2 Sep 2019 10:10:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD2416B0008; Mon,  2 Sep 2019 10:10:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0088.hostedemail.com [216.40.44.88])
	by kanga.kvack.org (Postfix) with ESMTP id 778856B0007
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 10:10:56 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 0E490180AD7C3
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 14:10:56 +0000 (UTC)
X-FDA: 75890166912.29.basin80_424a036a5491e
X-HE-Tag: basin80_424a036a5491e
X-Filterd-Recvd-Size: 5107
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 14:10:55 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 18AAFAD05;
	Mon,  2 Sep 2019 14:10:54 +0000 (UTC)
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: catalin.marinas@arm.com,
	hch@lst.de,
	wahrenst@gmx.net,
	marc.zyngier@arm.com,
	robh+dt@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	linux-riscv@lists.infradead.org,
	linux-kernel@vger.kernel.org
Cc: f.fainelli@gmail.com,
	will@kernel.org,
	robin.murphy@arm.com,
	nsaenzjulienne@suse.de,
	mbrugger@suse.com,
	linux-rpi-kernel@lists.infradead.org,
	phill@raspberrypi.org,
	m.szyprowski@samsung.com
Subject: [PATCH v3 2/4] arm64: rename variables used to calculate ZONE_DMA32's size
Date: Mon,  2 Sep 2019 16:10:40 +0200
Message-Id: <20190902141043.27210-3-nsaenzjulienne@suse.de>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190902141043.27210-1-nsaenzjulienne@suse.de>
References: <20190902141043.27210-1-nsaenzjulienne@suse.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let the name indicate that they are used to calculate ZONE_DMA32's size
as opposed to ZONE_DMA.

Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
---

Changes in v3: None
Changes in v2: None

 arch/arm64/mm/init.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 6112d6c90fa8..8956c22634dd 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -50,7 +50,7 @@
 s64 memstart_addr __ro_after_init =3D -1;
 EXPORT_SYMBOL(memstart_addr);
=20
-phys_addr_t arm64_dma_phys_limit __ro_after_init;
+phys_addr_t arm64_dma32_phys_limit __ro_after_init;
=20
 #ifdef CONFIG_KEXEC_CORE
 /*
@@ -168,7 +168,7 @@ static void __init reserve_elfcorehdr(void)
  * currently assumes that for memory starting above 4G, 32-bit devices w=
ill
  * use a DMA offset.
  */
-static phys_addr_t __init max_zone_dma_phys(void)
+static phys_addr_t __init max_zone_dma32_phys(void)
 {
 	phys_addr_t offset =3D memblock_start_of_DRAM() & GENMASK_ULL(63, 32);
 	return min(offset + (1ULL << 32), memblock_end_of_DRAM());
@@ -181,7 +181,7 @@ static void __init zone_sizes_init(unsigned long min,=
 unsigned long max)
 	unsigned long max_zone_pfns[MAX_NR_ZONES]  =3D {0};
=20
 #ifdef CONFIG_ZONE_DMA32
-	max_zone_pfns[ZONE_DMA32] =3D PFN_DOWN(arm64_dma_phys_limit);
+	max_zone_pfns[ZONE_DMA32] =3D PFN_DOWN(arm64_dma32_phys_limit);
 #endif
 	max_zone_pfns[ZONE_NORMAL] =3D max;
=20
@@ -194,16 +194,16 @@ static void __init zone_sizes_init(unsigned long mi=
n, unsigned long max)
 {
 	struct memblock_region *reg;
 	unsigned long zone_size[MAX_NR_ZONES], zhole_size[MAX_NR_ZONES];
-	unsigned long max_dma =3D min;
+	unsigned long max_dma32 =3D min;
=20
 	memset(zone_size, 0, sizeof(zone_size));
=20
 	/* 4GB maximum for 32-bit only capable devices */
 #ifdef CONFIG_ZONE_DMA32
-	max_dma =3D PFN_DOWN(arm64_dma_phys_limit);
-	zone_size[ZONE_DMA32] =3D max_dma - min;
+	max_dma32 =3D PFN_DOWN(arm64_dma32_phys_limit);
+	zone_size[ZONE_DMA32] =3D max_dma32 - min;
 #endif
-	zone_size[ZONE_NORMAL] =3D max - max_dma;
+	zone_size[ZONE_NORMAL] =3D max - max_dma32;
=20
 	memcpy(zhole_size, zone_size, sizeof(zhole_size));
=20
@@ -215,14 +215,14 @@ static void __init zone_sizes_init(unsigned long mi=
n, unsigned long max)
 			continue;
=20
 #ifdef CONFIG_ZONE_DMA32
-		if (start < max_dma) {
-			unsigned long dma_end =3D min(end, max_dma);
+		if (start < max_dma32) {
+			unsigned long dma_end =3D min(end, max_dma32);
 			zhole_size[ZONE_DMA32] -=3D dma_end - start;
 		}
 #endif
-		if (end > max_dma) {
+		if (end > max_dma32) {
 			unsigned long normal_end =3D min(end, max);
-			unsigned long normal_start =3D max(start, max_dma);
+			unsigned long normal_start =3D max(start, max_dma32);
 			zhole_size[ZONE_NORMAL] -=3D normal_end - normal_start;
 		}
 	}
@@ -407,9 +407,9 @@ void __init arm64_memblock_init(void)
=20
 	/* 4GB maximum for 32-bit only capable devices */
 	if (IS_ENABLED(CONFIG_ZONE_DMA32))
-		arm64_dma_phys_limit =3D max_zone_dma_phys();
+		arm64_dma32_phys_limit =3D max_zone_dma32_phys();
 	else
-		arm64_dma_phys_limit =3D PHYS_MASK + 1;
+		arm64_dma32_phys_limit =3D PHYS_MASK + 1;
=20
 	reserve_crashkernel();
=20
@@ -417,7 +417,7 @@ void __init arm64_memblock_init(void)
=20
 	high_memory =3D __va(memblock_end_of_DRAM() - 1) + 1;
=20
-	dma_contiguous_reserve(arm64_dma_phys_limit);
+	dma_contiguous_reserve(arm64_dma32_phys_limit);
 }
=20
 void __init bootmem_init(void)
@@ -521,7 +521,7 @@ static void __init free_unused_memmap(void)
 void __init mem_init(void)
 {
 	if (swiotlb_force =3D=3D SWIOTLB_FORCE ||
-	    max_pfn > (arm64_dma_phys_limit >> PAGE_SHIFT))
+	    max_pfn > (arm64_dma32_phys_limit >> PAGE_SHIFT))
 		swiotlb_init(1);
 	else
 		swiotlb_force =3D SWIOTLB_NO_FORCE;
--=20
2.23.0


