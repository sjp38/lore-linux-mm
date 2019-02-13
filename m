Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB5D4C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:57:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5852F207E0
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:57:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UHbAr6Vj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5852F207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0728D8E0002; Wed, 13 Feb 2019 08:57:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0236B8E0001; Wed, 13 Feb 2019 08:57:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E55708E0002; Wed, 13 Feb 2019 08:57:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B6B08E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:57:57 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id e68so1772069plb.3
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:57:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=QS3mWzK39q3lW8WqJHFL6wuRYacMcGaOmOmP8soCdrs=;
        b=lDjUsjpnxdo34ar7wdqAjGGKY/BqX8o7GXWoFIgFnZxid32b/55NZ6GmYCh3Fn0qIV
         XTnkoHfWBpulhTk1BiNjv4GDtSzCzhnzI2415i3tc7pI2wFuRm1Zdc9eGrPKOGbsoK+F
         Q1MHb9aXxSXc2oc3+b7BGqB2eBhH+1pTtJPxKK5jy1uUVDZiY7+kSQpjY+4MGJ41j3Kh
         gtFlRaPtHzSVPI/tMn+0/FxFNrKx54JPFWxfKiP8UBC5OHV57k37vamMEhtBux/OefrS
         ud0y9ETT084dsgEe16We4amNH7Qytj9ORvmabiwT46v3oauLOeHqkRW8eQP5zZSC3AUC
         DEQg==
X-Gm-Message-State: AHQUAuZjHzM/5E8BvN1kRz4pTgugzUF+g1Lfe2JiTUp+xeu6ABF5Op5l
	Pr4127V52dPRBz7e9E44F/UaDxmjZ0e2UTbxxg/YHeyBtWsc6Q1vV3bRQOBC+VLsSG4+3fJFGGL
	BxgZ0W8HBhEwjD7c0XLrYJupqf2v259IQM2aRKYKcMR5UIX9q/63q79UZ5qTODVGPfiY40ECqon
	88oeazDhsDwLB7+TCiaqOud4EJqz+0fKyn/NRPwoqme+Ua7hbEmJnWaBgwTODrz/zKHMpBfekE0
	4v36g1dE4XfTK4eotuuB0FAIvwPmAZ+klRiDorNOb/PrHGgGyk0KWfmJVHT/nR0AvVjxfQADaIy
	hFcGcVWCghBotmWQOGRJKXV3LH8HCpY2sZb9sGJNI5Brxj4ok01YWuB81J2lg3sWdXLA2KpVkIp
	9
X-Received: by 2002:a63:96:: with SMTP id 144mr568489pga.315.1550066277193;
        Wed, 13 Feb 2019 05:57:57 -0800 (PST)
X-Received: by 2002:a63:96:: with SMTP id 144mr568440pga.315.1550066276327;
        Wed, 13 Feb 2019 05:57:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550066276; cv=none;
        d=google.com; s=arc-20160816;
        b=bxCSj5/W4NyA1QpbaEfrHzCuryofAAdJO2VCbxsherLs2zXXLaan7O+JnXqP+sOPlF
         HCkXntiTN7byxrjsyudvWF+dsKfbVgpeEQuA7U9u0fU4A3TaP0G1bML7ohcKTF2b4BoQ
         8yJ3KVTBsM/gVFZaHfGcMVSR2oB+E8RGH0DObVdW2ZxjxGe8/0uA6C+igcqzIpnw2S2e
         5xDYGQTlMQ4W0Unb8jldp2/F9V8xJejsGQtXqqPO9sKCn5zQuDa9hFJB+j96IhKK0M33
         bWnAtx/rHytlz9xeemTTQijaWGgIoKRih6WRyhM8Zf7IuaX7AvfKRsxZ3S7+ZtmxnFEk
         uo0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=QS3mWzK39q3lW8WqJHFL6wuRYacMcGaOmOmP8soCdrs=;
        b=jC+84bVqdEBYT7duqRJnHhS1Hc1CK0L3ox1jFIry3nZd/L0OA5EiQ16Ff7Z6K4eWTr
         Sdj+M9mGymUeeKAF4dEmX14w7kSxkli5S7vDedun+IjOxnE2hKJTum+FBDus9Aow0zQG
         es7xpm7/jQxb3ld9cjbNk6fCn20jYoIVCmN62qzyvlPmEDUqZM+3bGrAX54GuM0B45mp
         sUG+Mwj8GXUAxh8F2FTnebOoWXnv7jbc6aME0GRZohSKrtSB2MPMoeb+toxc/4ye5ISf
         dvLFKA24eqZhL7b+Lgb2Ns7vZtuKDWp1StwPY3qb2iCWSOSUW/O3aM53z0RgzdRP0p4/
         UW/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UHbAr6Vj;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v15sor25251415pfa.0.2019.02.13.05.57.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 05:57:56 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UHbAr6Vj;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=QS3mWzK39q3lW8WqJHFL6wuRYacMcGaOmOmP8soCdrs=;
        b=UHbAr6VjHIA6sKDIJjq+403Y2d7WPguSXt3rzmIl6IBY6SSfTp0rLgonfEf6lGHpCs
         CrqhOWcnJqtDs+YhZFN5PrBEiC74DnXBT4v+K/jsCvtxEA8T8Scf5lmzpX7lohjU+xvl
         A2rPHRTJZmYRrO65TcR9WlQZvULjczqLPmErv17xJYk9d75MdbexEIZI5clY7YNBgJ49
         Zp9HE2xqWl71SvZmGVzA+KbEUvV+xrOI14XqbKjbaXYpQXQawuxYvX7APazz3N9/jRar
         pL73Tp4ZQMXOJ3AmD52pjLwG6s9XYcngHbZ5fEeW1hxuJ4Tzz1denDq6BM6ddw761yqb
         zHSw==
X-Google-Smtp-Source: AHgI3IbsRbeaAyePsoPA34qPEwK9ju+Mwor/j+wcsqcPpuYwN399ocFJJNJYAe7AZfgfl6MyXeqd2Q==
X-Received: by 2002:aa7:838b:: with SMTP id u11mr644881pfm.254.1550066275977;
        Wed, 13 Feb 2019 05:57:55 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.48.54])
        by smtp.gmail.com with ESMTPSA id g14sm33624506pfg.27.2019.02.13.05.57.54
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Feb 2019 05:57:55 -0800 (PST)
Date: Wed, 13 Feb 2019 19:32:14 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	kirill.shutemov@linux.intel.com, vbabka@suse.cz, riel@surriel.com,
	sfr@canb.auug.org.au, rppt@linux.vnet.ibm.com, peterz@infradead.org,
	linux@armlinux.org.uk, robin.murphy@arm.com, iamjoonsoo.kim@lge.com,
	treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com,
	stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, heiko@sntech.de,
	airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org,
	pawel@osciak.com, kyungmin.park@samsung.com, mchehab@kernel.org,
	boris.ostrovsky@oracle.com, jgross@suse.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux1394-devel@lists.sourceforge.net,
	dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org,
	xen-devel@lists.xen.org, iommu@lists.linux-foundation.org,
	linux-media@vger.kernel.org
Subject: [PATCH v3 1/9] mm: Introduce new vm_map_pages() and
 vm_map_pages_zero() API
Message-ID: <20190213140214.GA21954@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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

