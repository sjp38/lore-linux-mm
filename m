Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12FB7C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 08:00:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0EBF205C9
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 08:00:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="bM+YSebv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0EBF205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AED66B0269; Wed, 14 Aug 2019 04:00:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 636276B026A; Wed, 14 Aug 2019 04:00:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FD936B026B; Wed, 14 Aug 2019 04:00:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0210.hostedemail.com [216.40.44.210])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3946B0269
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 04:00:10 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D0E148248AA1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:00:09 +0000 (UTC)
X-FDA: 75820285338.27.frogs66_58b061658b962
X-HE-Tag: frogs66_58b061658b962
X-Filterd-Recvd-Size: 3846
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:00:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=aAnmSRph1c1Gu2+S0Bf5dmihLUaL6lE7+YQ+WyB/8Io=; b=bM+YSebvWYi9TWCoNWvznDU4rK
	PbGYSC1kDL4lM+HJPv/XKvL+1+89tZCp9zpByE9sGHwJjWDQjUUyETZEtrYJ2ZVWr+nImLnODGhGr
	Px7VZx/459JkWE+617Z320wbe59gs70dEAfTZFkf7gxjUpz+comcBvRsHIs/2/wp7d/28TxxQGeaC
	QnxdelxFLgpddzI4JUuX9iBWcEcI3jEaTh983n/LE0kJUerNxqxQekySl+oWl/1d+10zpd/blkhvt
	1FKMaw1LL9eaVdr02KhYgcBEOpEj61YaLSReU27GR2//wmzBVDoKxKWf4VXSE3L6wcQsGyle3EMmm
	WVu8ZTag==;
Received: from [2001:4bb8:180:1ec3:c70:4a89:bc61:2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hxoCP-0008Bl-UL; Wed, 14 Aug 2019 08:00:02 +0000
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
Subject: [PATCH 10/10] mm: remove CONFIG_MIGRATE_VMA_HELPER
Date: Wed, 14 Aug 2019 09:59:28 +0200
Message-Id: <20190814075928.23766-11-hch@lst.de>
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

CONFIG_MIGRATE_VMA_HELPER guards helpers that are required for proper
devic private memory support.  Remove the option and just check for
CONFIG_DEVICE_PRIVATE instead.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/Kconfig | 1 -
 mm/Kconfig                      | 3 ---
 mm/migrate.c                    | 4 ++--
 3 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/Kconfig b/drivers/gpu/drm/nouveau/Kc=
onfig
index df4352c279ba..3558df043592 100644
--- a/drivers/gpu/drm/nouveau/Kconfig
+++ b/drivers/gpu/drm/nouveau/Kconfig
@@ -89,7 +89,6 @@ config DRM_NOUVEAU_SVM
 	depends on MMU
 	depends on STAGING
 	select HMM_MIRROR
-	select MIGRATE_VMA_HELPER
 	select MMU_NOTIFIER
 	default n
 	help
diff --git a/mm/Kconfig b/mm/Kconfig
index 563436dc1f24..2fe4902ad755 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -669,9 +669,6 @@ config ZONE_DEVICE
=20
 	  If FS_DAX is enabled, then say Y.
=20
-config MIGRATE_VMA_HELPER
-	bool
-
 config DEV_PAGEMAP_OPS
 	bool
=20
diff --git a/mm/migrate.c b/mm/migrate.c
index 33e063c28c1b..993386cb5335 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2117,7 +2117,7 @@ int migrate_misplaced_transhuge_page(struct mm_stru=
ct *mm,
=20
 #endif /* CONFIG_NUMA */
=20
-#if defined(CONFIG_MIGRATE_VMA_HELPER)
+#ifdef CONFIG_DEVICE_PRIVATE
 static int migrate_vma_collect_hole(unsigned long start,
 				    unsigned long end,
 				    struct mm_walk *walk)
@@ -2942,4 +2942,4 @@ void migrate_vma_finalize(struct migrate_vma *migra=
te)
 	}
 }
 EXPORT_SYMBOL(migrate_vma_finalize);
-#endif /* defined(MIGRATE_VMA_HELPER) */
+#endif /* CONFIG_DEVICE_PRIVATE */
--=20
2.20.1


