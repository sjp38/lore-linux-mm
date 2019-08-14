Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23F21C0650F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 08:00:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD136208C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 08:00:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="nf8lz2mg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD136208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CF6F6B0266; Wed, 14 Aug 2019 04:00:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 880FE6B0269; Wed, 14 Aug 2019 04:00:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7963A6B026A; Wed, 14 Aug 2019 04:00:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0103.hostedemail.com [216.40.44.103])
	by kanga.kvack.org (Postfix) with ESMTP id 543026B0266
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 04:00:06 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 0009B4845
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:00:05 +0000 (UTC)
X-FDA: 75820285212.13.word41_5821f11d4000c
X-HE-Tag: word41_5821f11d4000c
X-Filterd-Recvd-Size: 4218
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:00:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=c9/dDlAXPO06tbe3ckotGuM+bx2Vb/b5R5VZWgHXwpY=; b=nf8lz2mgXmnA2oryUrD6fnKf2X
	xiHMCSb3cDtMbseNxzyfcl/hqgv50oDb8TJFF1n3Jeba40bB7brQ0snqszdFOoo6xpY4qjWC/KAqW
	fPYiVRAJp6FWN/x4ifylJotiwpvQ98SZoLgXS7xYVyk6ba5KZTLnhJjgObAFwRtgrwQ5x8zrs2dIx
	mWGL7nB4Syz8HdmVmf65naaiEyAGcA4O9DFXCYdqJo2p6pVY7NLksUkVFe+PZ54/yfWlLZtHF5yir
	m4iPSZ9xqFFZ1WY72+Yz6mveFrLFdPrsseV6zjiDNT004lqYjDiFr2MFdgRyw0QzX1OlHh5seHZt3
	d22/HEqg==;
Received: from [2001:4bb8:180:1ec3:c70:4a89:bc61:2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hxoCN-000897-03; Wed, 14 Aug 2019 07:59:59 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 09/10] mm: remove the unused MIGRATE_PFN_DEVICE flag
Date: Wed, 14 Aug 2019 09:59:27 +0200
Message-Id: <20190814075928.23766-10-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190814075928.23766-1-hch@lst.de>
References: <20190814075928.23766-1-hch@lst.de>
MIME-Version: 1.0
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

No one ever checks this flag, and we could easily get that information
from the page if needed.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 3 +--
 include/linux/migrate.h                | 1 -
 mm/migrate.c                           | 4 ++--
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nou=
veau/nouveau_dmem.c
index d96b987b9982..fa1439941596 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -580,8 +580,7 @@ static unsigned long nouveau_dmem_migrate_copy_one(st=
ruct nouveau_drm *drm,
 			*dma_addr))
 		goto out_dma_unmap;
=20
-	return migrate_pfn(page_to_pfn(dpage)) |
-		MIGRATE_PFN_LOCKED | MIGRATE_PFN_DEVICE;
+	return migrate_pfn(page_to_pfn(dpage)) | MIGRATE_PFN_LOCKED;
=20
 out_dma_unmap:
 	dma_unmap_page(dev, *dma_addr, PAGE_SIZE, DMA_BIDIRECTIONAL);
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 1e67dcfd318f..72120061b7d4 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -166,7 +166,6 @@ static inline int migrate_misplaced_transhuge_page(st=
ruct mm_struct *mm,
 #define MIGRATE_PFN_MIGRATE	(1UL << 1)
 #define MIGRATE_PFN_LOCKED	(1UL << 2)
 #define MIGRATE_PFN_WRITE	(1UL << 3)
-#define MIGRATE_PFN_DEVICE	(1UL << 4)
 #define MIGRATE_PFN_SHIFT	6
=20
 static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
diff --git a/mm/migrate.c b/mm/migrate.c
index e2565374d330..33e063c28c1b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2237,8 +2237,8 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 				goto next;
=20
 			page =3D device_private_entry_to_page(entry);
-			mpfn =3D migrate_pfn(page_to_pfn(page))|
-				MIGRATE_PFN_DEVICE | MIGRATE_PFN_MIGRATE;
+			mpfn =3D migrate_pfn(page_to_pfn(page)) |
+					MIGRATE_PFN_MIGRATE;
 			if (is_write_device_private_entry(entry))
 				mpfn |=3D MIGRATE_PFN_WRITE;
 		} else {
--=20
2.20.1


