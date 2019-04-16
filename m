Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B361C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:46:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11C5920821
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:46:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SMasld1u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11C5920821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B55F76B026B; Tue, 16 Apr 2019 07:46:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B378E6B026D; Tue, 16 Apr 2019 07:46:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F4056B026C; Tue, 16 Apr 2019 07:46:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 698BF6B026A
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:46:48 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u78so13891796pfa.12
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 04:46:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=QS3mWzK39q3lW8WqJHFL6wuRYacMcGaOmOmP8soCdrs=;
        b=DGJOe0akPzW4jcipg3BMv/fFpY0eN00qVbDQ4rT+e3bZjbQTT7p0RTZumzv83evECr
         Fd+yIGMRF3B/7+/+VlcbwoenCeP3MZbAI8juS4yLvbCXduFLRCzDcZROrugmxoMRhteR
         uEESxoMrbipTFyxafyZUZLVtEO/O8mT0GN79G08lrNdIjpL0bgh3M3FwmycPB/Na/nXD
         wFgjUF5SstziOAG3dSEH2iSIa4SUv1b7z948E/7Mk+cVBWzJcd7idnwbvHrbi3VjRNuO
         ZLNslD3qHVlQWBQvs6TLOsNDKeRMURddirwMa4ELZFfMnKFOhcCl/tB8w8/3Ld0ApLv5
         cM7g==
X-Gm-Message-State: APjAAAXo0x5YdxxVd3Kl4lm3e2wlEsM1VIxW3pLBXK30FO0wav4zbtCp
	CN+eOfuVjrUwEAWCud9DRWhQPP0I7zwj1N2sRQCNo+fRlKEjVb/G5Slq21EQf/lO40+dgsctMmw
	tbnWJ7+1fuekkb6IFVLTEQ9pYVItwJUiLAKT1OKaaOIhl7HgfoVVZn0LJ5dvwEcAgyw==
X-Received: by 2002:a63:6193:: with SMTP id v141mr76758579pgb.392.1555415208032;
        Tue, 16 Apr 2019 04:46:48 -0700 (PDT)
X-Received: by 2002:a63:6193:: with SMTP id v141mr76758504pgb.392.1555415207055;
        Tue, 16 Apr 2019 04:46:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555415207; cv=none;
        d=google.com; s=arc-20160816;
        b=hn6g0PD+cSrYqIDbCgoF/kKlwx+KsqYJZlu9ILkxo61e3PCRpJk5asGONIZFbfswHL
         jnfmU0H5wsCCshIYkK9Dm+cMuYEnTiGYfaaspbs9LF8ZeWsVrUci/2c6lBCdwwLnyvy6
         l0tRdDzpS2Fo8neMzuRRlGvsBJEaJohViSKnmwhtp1+5SZGBALGs9Yt4cTKSt64JZ2We
         dRUrChYRA//kNzY9r/Dgc7Mjd1iCLhlZ2Y+RehWaa4YHD4FNIrguAiQcxcrpEDJhx7Mw
         rq/XrW2hd3pjCLuAPumYDL3NQI3fOkJoxGwogMl8z2tOavBPkcLHqydohfgEDp/QMq/Z
         NECA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=QS3mWzK39q3lW8WqJHFL6wuRYacMcGaOmOmP8soCdrs=;
        b=ej8VipGikwpyrTU3WSdl/d/4Vq3MeNiGp8+qxvr2bR+xPQr/YvkoGUMDkg8lZbQa3L
         5/7XD7L8jip93P3521o5k52fUfdtj3fsz7ot7dLy0zStnXFNEjctmv2ie+dqh3HGcfvx
         Usa2vF6L8nVQfWVEtdePGn+zhcVews/x0bT3HZ6emqJQBcYQEFQf0bRbAGGDjo9Tgp+9
         D+bGOXXkhA4U6b0VpwDVtZrYboX4opQ9zM0G9aUymXDx+kc4CpJClH7/PpkZzIeVhfY0
         f+sneF/2plkCDs0P1SkweFHwu+ffoZAJhy1XHpDzZhgr9zVfklrCkUiJTfrom7Bo0hBK
         wNZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SMasld1u;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z191sor56857423pgz.21.2019.04.16.04.46.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 04:46:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SMasld1u;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :in-reply-to:references;
        bh=QS3mWzK39q3lW8WqJHFL6wuRYacMcGaOmOmP8soCdrs=;
        b=SMasld1uVZEpk4UEX00zTMKjN2cLUw5t5lk/rP875Zl7Ld1UD9ODxSW09epwDa4uQj
         /hdI4CMavMCQGR4K9F6jSPXx+sCJulN7Z3Go41fL6vV89zcZt9uSd+xfST5IB+cj8KDS
         N1FUTFkBWB5rZl1B8iO9lUoa5CwoWWg3XlUZF4TGl++UHbLkEEGzlcTHYHaa7qAqjmGs
         Ism4aa2dV2ii3Ies/ixc50ihwnCU0O24lH/WI2cBQJYq/0h3KtgkSQBUCdS/o35tPlHP
         ORrNYc50yRSTV62Pnj0+VVtPb4lUZiFBc7wcD/YX4cQ6ayuEO1ycd1Po5bAz9ZZbH912
         vXHw==
X-Google-Smtp-Source: APXvYqyWLI4xppoJaNwMmezhBEPAkitBrHOX4rZ8NY0KFqkqU3V5t5n8ALBmwioh0pUr6lOC+xC0Xg==
X-Received: by 2002:a65:6655:: with SMTP id z21mr40301407pgv.33.1555415205643;
        Tue, 16 Apr 2019 04:46:45 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC.domain.name ([49.207.50.11])
        by smtp.gmail.com with ESMTPSA id p6sm55942835pfd.122.2019.04.16.04.46.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 16 Apr 2019 04:46:44 -0700 (PDT)
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org,
	willy@infradead.org,
	mhocko@suse.com,
	kirill.shutemov@linux.intel.com,
	vbabka@suse.cz,
	riel@surriel.com,
	sfr@canb.auug.org.au,
	rppt@linux.vnet.ibm.com,
	peterz@infradead.org,
	linux@armlinux.org.uk,
	robin.murphy@arm.com,
	iamjoonsoo.kim@lge.com,
	treding@nvidia.com,
	keescook@chromium.org,
	m.szyprowski@samsung.com,
	stefanr@s5r6.in-berlin.de,
	hjc@rock-chips.com,
	heiko@sntech.de,
	airlied@linux.ie,
	oleksandr_andrushchenko@epam.com,
	joro@8bytes.org,
	pawel@osciak.com,
	kyungmin.park@samsung.com,
	mchehab@kernel.org,
	boris.ostrovsky@oracle.com,
	jgross@suse.com
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux1394-devel@lists.sourceforge.net,
	dri-devel@lists.freedesktop.org,
	linux-rockchip@lists.infradead.org,
	xen-devel@lists.xen.org,
	iommu@lists.linux-foundation.org,
	linux-media@vger.kernel.org,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: [REBASE PATCH v5 1/9] mm: Introduce new vm_map_pages() and vm_map_pages_zero() API
Date: Tue, 16 Apr 2019 17:19:42 +0530
Message-Id:
 <751cb8a0f4c3e67e95c58a3b072937617f338eea.1552921225.git.jrdr.linux@gmail.com>
X-Mailer: git-send-email 1.9.1
In-Reply-To: <cover.1552921225.git.jrdr.linux@gmail.com>
References: <cover.1552921225.git.jrdr.linux@gmail.com>
In-Reply-To: <cover.1552921225.git.jrdr.linux@gmail.com>
References: <cover.1552921225.git.jrdr.linux@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190416114942._5JcHKPihD7XkclmGJIRqU8HRKfQQlkrckjyJ94lllY@z>

Previouly drivers have their own way of mapping range of
kernel pages/memory into user vma and this was done by
invoking vm_insert_page() within a loop.

As this pattern is common across different drivers, it can
be generalized by creating new functions and use it across
the drivers.

vm_map_pages() is the API which could be used to mapped
kernel memory/pages in drivers which has considered vm_pgoff

vm_map_pages_zero() is the API which could be used to map
range of kernel memory/pages in drivers which has not considered
vm_pgoff. vm_pgoff is passed default as 0 for those drivers.

We _could_ then at a later "fix" these drivers which are using
vm_map_pages_zero() to behave according to the normal vm_pgoff
offsetting simply by removing the _zero suffix on the function
name and if that causes regressions, it gives us an easy way to revert.

Tested on Rockchip hardware and display is working, including talking
to Lima via prime.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Suggested-by: Russell King <linux@armlinux.org.uk>
Suggested-by: Matthew Wilcox <willy@infradead.org>
Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
Tested-by: Heiko Stuebner <heiko@sntech.de>
---
 include/linux/mm.h |  4 +++
 mm/memory.c        | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/nommu.c         | 14 ++++++++++
 3 files changed, 99 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb640..e0aaa73 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2565,6 +2565,10 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
+int vm_map_pages(struct vm_area_struct *vma, struct page **pages,
+				unsigned long num);
+int vm_map_pages_zero(struct vm_area_struct *vma, struct page **pages,
+				unsigned long num);
 vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
diff --git a/mm/memory.c b/mm/memory.c
index e11ca9d..cad3e27 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1520,6 +1520,87 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_page);
 
+/*
+ * __vm_map_pages - maps range of kernel pages into user vma
+ * @vma: user vma to map to
+ * @pages: pointer to array of source kernel pages
+ * @num: number of pages in page array
+ * @offset: user's requested vm_pgoff
+ *
+ * This allows drivers to map range of kernel pages into a user vma.
+ *
+ * Return: 0 on success and error code otherwise.
+ */
+static int __vm_map_pages(struct vm_area_struct *vma, struct page **pages,
+				unsigned long num, unsigned long offset)
+{
+	unsigned long count = vma_pages(vma);
+	unsigned long uaddr = vma->vm_start;
+	int ret, i;
+
+	/* Fail if the user requested offset is beyond the end of the object */
+	if (offset > num)
+		return -ENXIO;
+
+	/* Fail if the user requested size exceeds available object size */
+	if (count > num - offset)
+		return -ENXIO;
+
+	for (i = 0; i < count; i++) {
+		ret = vm_insert_page(vma, uaddr, pages[offset + i]);
+		if (ret < 0)
+			return ret;
+		uaddr += PAGE_SIZE;
+	}
+
+	return 0;
+}
+
+/**
+ * vm_map_pages - maps range of kernel pages starts with non zero offset
+ * @vma: user vma to map to
+ * @pages: pointer to array of source kernel pages
+ * @num: number of pages in page array
+ *
+ * Maps an object consisting of @num pages, catering for the user's
+ * requested vm_pgoff
+ *
+ * If we fail to insert any page into the vma, the function will return
+ * immediately leaving any previously inserted pages present.  Callers
+ * from the mmap handler may immediately return the error as their caller
+ * will destroy the vma, removing any successfully inserted pages. Other
+ * callers should make their own arrangements for calling unmap_region().
+ *
+ * Context: Process context. Called by mmap handlers.
+ * Return: 0 on success and error code otherwise.
+ */
+int vm_map_pages(struct vm_area_struct *vma, struct page **pages,
+				unsigned long num)
+{
+	return __vm_map_pages(vma, pages, num, vma->vm_pgoff);
+}
+EXPORT_SYMBOL(vm_map_pages);
+
+/**
+ * vm_map_pages_zero - map range of kernel pages starts with zero offset
+ * @vma: user vma to map to
+ * @pages: pointer to array of source kernel pages
+ * @num: number of pages in page array
+ *
+ * Similar to vm_map_pages(), except that it explicitly sets the offset
+ * to 0. This function is intended for the drivers that did not consider
+ * vm_pgoff.
+ *
+ * Context: Process context. Called by mmap handlers.
+ * Return: 0 on success and error code otherwise.
+ */
+int vm_map_pages_zero(struct vm_area_struct *vma, struct page **pages,
+				unsigned long num)
+{
+	return __vm_map_pages(vma, pages, num, 0);
+}
+EXPORT_SYMBOL(vm_map_pages_zero);
+
 static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn, pgprot_t prot, bool mkwrite)
 {
diff --git a/mm/nommu.c b/mm/nommu.c
index 749276b..b492fd1 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -473,6 +473,20 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_page);
 
+int vm_map_pages(struct vm_area_struct *vma, struct page **pages,
+			unsigned long num)
+{
+	return -EINVAL;
+}
+EXPORT_SYMBOL(vm_map_pages);
+
+int vm_map_pages_zero(struct vm_area_struct *vma, struct page **pages,
+				unsigned long num)
+{
+	return -EINVAL;
+}
+EXPORT_SYMBOL(vm_map_pages_zero);
+
 /*
  *  sys_brk() for the most part doesn't need the global kernel
  *  lock, except when an application is doing something nasty
-- 
1.9.1

