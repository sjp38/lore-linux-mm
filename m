Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48656C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00BB421473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="k97Dd7pL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00BB421473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A39F56B027A; Thu, 13 Jun 2019 05:44:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 923C06B027B; Thu, 13 Jun 2019 05:44:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 777096B027C; Thu, 13 Jun 2019 05:44:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3BAF16B027A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:44:35 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j21so14099692pff.12
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:44:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kZ4qxfaugsPBAzNnf2F5+YBv7IsxX/EWqM6pYodKjkw=;
        b=VfNg2BxPVTaA1LA87swKE/5FEMZPBAVYb04p09+c/b77T3lrxNnoi4JM9NXVgUXlVt
         oDYBE+z59IS47+pcCIo0PsZzngXeEfxDDpxjN6RAqhIcz3NoRjKCFhqGzEmSCWWNAQp2
         bE2AnnW4FylUXtUg/Yx5FElAm/vQdsTfgiG3KWeSU6slL64wT+v70KXYEFU4iRRDEBdE
         9r+bM9kioj1A3ioLxMnTqcKgVFpNw8gBdxJXlvrMjjLaHW2O2hIXHIdKPa7njleM7vmv
         TeYOICmwjUrASlqG95q2p0yvwwfGEpcw0VFuDOan+z2tvJMMVfrG/J+GG1I0UEv18wOw
         ezrw==
X-Gm-Message-State: APjAAAWfF2se7irafRZfj+jbygGA7GlXgyPa02l3BWYH4W3NgXcRAFA8
	0Var9ODxfD4KSCPXXKoOmf0gjgub1CvP630wd3X4KftCLilxpkUUDuw2HwenIfAol7wm3TysUTv
	fh9ioDi7EWGTdpRLS0HLlxQaoK8giAgJoLcYYA5L3D34BxoqvDhPQKTi8PxxBtsc=
X-Received: by 2002:a17:90a:206a:: with SMTP id n97mr4399593pjc.10.1560419074455;
        Thu, 13 Jun 2019 02:44:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQZPnpD8JewElVz/BKcbdkOJXY2vbrUMqQNDcwvJX17gAdie/f/+39qVnCwyd63LCbP4uD
X-Received: by 2002:a17:90a:206a:: with SMTP id n97mr4399472pjc.10.1560419073383;
        Thu, 13 Jun 2019 02:44:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419073; cv=none;
        d=google.com; s=arc-20160816;
        b=UlMg5YiKhryREaPeUDaqEfg3xSnhCmhcHat3Q8R1g+pif1VzGBKBXW6VELPmv0hi0U
         HOPWY5uqjt0AwY9u0vtS4KhcwIr+oPsat8/02heZPlBpDswVU5aEgFWPf7eXplCkIzGO
         A5YAOtPCvyBYI9JYOstHnPBW16BYplnbwqSFV4WN23gPI1Fp8OBfujatVkfUr6cdGZgW
         CSBpT4cBU2Grbk7OpAmvOJ9UnbL7ew1322FU9uFHnHaNUv/GbwewQfyobzcP2sT8r6Gl
         m0ehBx2M2ejuNhCx+el5ymKaZ5bnPGoAI4cyU/foMiMPpENHWsKwx4fw/Cmh5EyS+yVA
         OTLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=kZ4qxfaugsPBAzNnf2F5+YBv7IsxX/EWqM6pYodKjkw=;
        b=0jEVCcmclcyBkXRseD8oMgd7/cvsPvZhXdvFJ6O+o0B1Ug7hw5DJsHgD1qgPh1Mrb5
         V0WMwHSXFwscEn8CvIB7gxI+HuUeCsHLLImZGE7+wOjyik2qQf2xf9FaQJzdDtf2D20S
         DNHyU+r4d8rjXO99LkIM9W/bzh0ilGyTWwaeOuJBhIPn4a5GfPp0YrCiDHGyAQ0a5vTi
         Fc5O8gpYjUncwodexT4vubKThRI+Jt+QzeLTSpaucTLDK7EAnySB4KWevtzmT63UQUmz
         KxSU7ALPft9+07OGhn0Z2cSOMb15Qp41FpeTKteuNbz+8YBo2PTUqXKD7R0G53Q5ZwPN
         RWxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=k97Dd7pL;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s1si2468618plp.66.2019.06.13.02.44.33
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:44:33 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=k97Dd7pL;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=kZ4qxfaugsPBAzNnf2F5+YBv7IsxX/EWqM6pYodKjkw=; b=k97Dd7pLGeOpmCNCf65fhjYJNc
	ImDu+Xfy6FCJV49fGpZqtY6ITY20Ga5rfbF1ZP8/+kIAUOmCJaXe/qfHjuLsqZDKoqXq4TdEj5Vp0
	jtQNy4yxzFvw8d8X2ge3Dw8edBPvJTaL6od2e2JrfH7Xxbknm4G8HBU9oSnr3E1JnwunI7X3nvPkT
	gG7E9aumHhR8ixTiSTA9r3AzufEbuqKR9dAa8/cqyW4WBVN++uRv1Vx9WTUDrrW59jnByDhykg/ZP
	Vn1lViZhnwx6LLeJpNkx+m+iBmbD0cfZ+ta1tZifhaEB9tvPlXBZQ5SA/zqi/MaVwZjAenHCd3+pW
	jVf38HmA==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMHW-0001xS-3I; Thu, 13 Jun 2019 09:44:30 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 21/22] mm: remove the HMM config option
Date: Thu, 13 Jun 2019 11:43:24 +0200
Message-Id: <20190613094326.24093-22-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190613094326.24093-1-hch@lst.de>
References: <20190613094326.24093-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

All the mm/hmm.c code is better keyed off HMM_MIRROR.  Also let nouveau
depend on it instead of the mix of a dummy dependency symbol plus the
actually selected one.  Drop various odd dependencies, as the code is
pretty portable.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/Kconfig |  3 +--
 include/linux/hmm.h             | 14 +++-----------
 include/linux/mm_types.h        |  2 +-
 mm/Kconfig                      | 27 +++------------------------
 mm/Makefile                     |  2 +-
 mm/hmm.c                        |  2 --
 6 files changed, 9 insertions(+), 41 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/Kconfig b/drivers/gpu/drm/nouveau/Kconfig
index 6303d203ab1d..66c839d8e9d1 100644
--- a/drivers/gpu/drm/nouveau/Kconfig
+++ b/drivers/gpu/drm/nouveau/Kconfig
@@ -84,11 +84,10 @@ config DRM_NOUVEAU_BACKLIGHT
 
 config DRM_NOUVEAU_SVM
 	bool "(EXPERIMENTAL) Enable SVM (Shared Virtual Memory) support"
-	depends on ARCH_HAS_HMM
 	depends on DEVICE_PRIVATE
 	depends on DRM_NOUVEAU
+	depends on HMM_MIRROR
 	depends on STAGING
-	select HMM_MIRROR
 	default n
 	help
 	  Say Y here if you want to enable experimental support for
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index e095a8b55dfa..64ea2fa00872 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -62,7 +62,7 @@
 #include <linux/kconfig.h>
 #include <asm/pgtable.h>
 
-#if IS_ENABLED(CONFIG_HMM)
+#ifdef CONFIG_HMM_MIRROR
 
 #include <linux/device.h>
 #include <linux/migrate.h>
@@ -324,9 +324,6 @@ static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
 	return hmm_device_entry_from_pfn(range, pfn);
 }
 
-
-
-#if IS_ENABLED(CONFIG_HMM_MIRROR)
 /*
  * Mirroring: how to synchronize device page table with CPU page table.
  *
@@ -546,13 +543,8 @@ static inline void hmm_mm_init(struct mm_struct *mm)
 {
 	mm->hmm = NULL;
 }
-#else /* IS_ENABLED(CONFIG_HMM_MIRROR) */
-static inline void hmm_mm_init(struct mm_struct *mm) {}
-#endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
-
-#else /* IS_ENABLED(CONFIG_HMM) */
-static inline void hmm_mm_destroy(struct mm_struct *mm) {}
+#else /* CONFIG_HMM_MIRROR */
 static inline void hmm_mm_init(struct mm_struct *mm) {}
-#endif /* IS_ENABLED(CONFIG_HMM) */
+#endif /* CONFIG_HMM_MIRROR */
 
 #endif /* LINUX_HMM_H */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index f33a1289c101..8d37182f8dbe 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -501,7 +501,7 @@ struct mm_struct {
 #endif
 		struct work_struct async_put_work;
 
-#if IS_ENABLED(CONFIG_HMM)
+#ifdef CONFIG_HMM_MIRROR
 		/* HMM needs to track a few things per mm */
 		struct hmm *hmm;
 #endif
diff --git a/mm/Kconfig b/mm/Kconfig
index 4dbd718c8cf4..73676cb4693f 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -669,37 +669,17 @@ config ZONE_DEVICE
 
 	  If FS_DAX is enabled, then say Y.
 
-config ARCH_HAS_HMM_MIRROR
-	bool
-	default y
-	depends on (X86_64 || PPC64)
-	depends on MMU && 64BIT
-
-config ARCH_HAS_HMM
-	bool
-	depends on (X86_64 || PPC64)
-	depends on ZONE_DEVICE
-	depends on MMU && 64BIT
-	depends on MEMORY_HOTPLUG
-	depends on MEMORY_HOTREMOVE
-	depends on SPARSEMEM_VMEMMAP
-	default y
-
 config MIGRATE_VMA_HELPER
 	bool
 
 config DEV_PAGEMAP_OPS
 	bool
 
-config HMM
-	bool
-	select MMU_NOTIFIER
-	select MIGRATE_VMA_HELPER
-
 config HMM_MIRROR
 	bool "HMM mirror CPU page table into a device page table"
-	depends on ARCH_HAS_HMM
-	select HMM
+	depends on MMU
+	select MMU_NOTIFIER
+	select MIGRATE_VMA_HELPER
 	help
 	  Select HMM_MIRROR if you want to mirror range of the CPU page table of a
 	  process into a device page table. Here, mirror means "keep synchronized".
@@ -721,7 +701,6 @@ config DEVICE_PUBLIC
 	bool "Addressable device memory (like GPU memory)"
 	depends on ARCH_HAS_HMM
 	depends on BROKEN
-	select HMM
 	select DEV_PAGEMAP_OPS
 
 	help
diff --git a/mm/Makefile b/mm/Makefile
index ac5e5ba78874..91c99040065c 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -102,5 +102,5 @@ obj-$(CONFIG_FRAME_VECTOR) += frame_vector.o
 obj-$(CONFIG_DEBUG_PAGE_REF) += debug_page_ref.o
 obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
 obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
-obj-$(CONFIG_HMM) += hmm.o
+obj-$(CONFIG_HMM_MIRROR) += hmm.o
 obj-$(CONFIG_MEMFD_CREATE) += memfd.o
diff --git a/mm/hmm.c b/mm/hmm.c
index 5b2e9bb6063a..8d50c482469c 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -26,7 +26,6 @@
 #include <linux/mmu_notifier.h>
 #include <linux/memory_hotplug.h>
 
-#if IS_ENABLED(CONFIG_HMM_MIRROR)
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
 /**
@@ -1289,4 +1288,3 @@ long hmm_range_dma_unmap(struct hmm_range *range,
 	return cpages;
 }
 EXPORT_SYMBOL(hmm_range_dma_unmap);
-#endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
-- 
2.20.1

