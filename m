Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1D2AC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:38:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5260D2192B
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:38:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SvKO/8Qu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5260D2192B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01A578E0003; Thu, 14 Feb 2019 21:38:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F33958E0001; Thu, 14 Feb 2019 21:38:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E239F8E0003; Thu, 14 Feb 2019 21:38:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A5CF48E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 21:38:23 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id y66so6383591pfg.16
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 18:38:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=QS3mWzK39q3lW8WqJHFL6wuRYacMcGaOmOmP8soCdrs=;
        b=hAc0IiZ5Hzb6Ahh/nnBBBrsOZQHU6iQhUhD80XgxLUwvSWYowizWZHhPuwTapjkPH6
         h+DWMQChDb/Xmn+T3iRcZX9skc6sp4d2ba9F0/rsvo5Jy2bkwL2lJJf2EjFvQWu9tFy8
         AqqOGVCmjex1WhJnLw+KZlPzKByP2lCkWB5jRJO+RRN8aGeKwZIrL64iwVIjNII1nv+n
         BN4iNWz7u614io7Kmy2yJdbTtzvB+WwvEMb59f2E3h+TpFH/tBSzcr0+GHeEjTVgoHOu
         eEGe70Fl6nRikXaHh0HltL+wD7Wxt0FH+OEVnmNNHoLDZ5lD5YGnkQ0TtMaV8rDklxj1
         KEDQ==
X-Gm-Message-State: AHQUAuYj/0OBkRJioplifFcAY5Zy0f+VE22qocUGnbgzMBRD5DdK7Puz
	CATN37AFRb0Ld/4iL3ci3jFWwf4kL1ElKfkOqnvLIhZvfihyfWRKNaqLxMxyBknmwf5xRFxvnOK
	CWiOe2JlZVbSopbvXiEdMvlMJOgzrJm9BxpnMA6LDx4LEdvZf1Iyml7p90rDjaGkz9AwhFgEpWo
	M+0wI0FEI1qzxlPqQ9/Ir+6aqWRWxRQ6TOUQZpUkQD05V2qW+curQDH14OYiQHcD0xbVYuS/pFz
	vsmcBRcIER3C4d0Us2AYQSaRRsIYEVwZFRWoic82m6lqTQLW+q7EKKAqMMATkktR3ABMFFmWk4p
	AVKuKopsxoCU4iPW2lRaeAx5yXgCBttUtAIoRs6ZrxD+6ZD3gC2yHMeft6Ylet6CocVZgMN/9Xi
	z
X-Received: by 2002:a63:5153:: with SMTP id r19mr3104610pgl.281.1550198303267;
        Thu, 14 Feb 2019 18:38:23 -0800 (PST)
X-Received: by 2002:a63:5153:: with SMTP id r19mr3104556pgl.281.1550198302309;
        Thu, 14 Feb 2019 18:38:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550198302; cv=none;
        d=google.com; s=arc-20160816;
        b=oeXZ8FSEaDw9e2DdRPNjg1F+rrZr3EL091vBQGX1tjQndeTLoGBYiUNj1Q5Nxbdb7S
         eEE7RZBa0QlfnaGN6jERQpgyQnppBGCXgFdimY3PjqqGrJwWIuUoydIaFq8pFVAf3N+b
         HBjnZH09muAxsjJky8u7oHpHyYEine9mljmFsYgEjo3czr0+mWUe9RdAVN1+1EZFs93Z
         fUDMx0rHv4kx4D7S/GdNZC99I4r2VkSpXhfszDks9LkOOjcDaq7S0ggIRsPxbKPWbAP6
         YVVsLsU9o8G6DAbstPtLHgG/nrEUcJnb7lNhzU48QxaYP34uXYWl/k7LBLCWUT4MY9ik
         LzCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=QS3mWzK39q3lW8WqJHFL6wuRYacMcGaOmOmP8soCdrs=;
        b=cNkVBT7mZR422bWaJvypcM9JmC5X/9gGeceDBiONKK91bTJM103kfTUEoWlQ6bu81G
         pgQw4H2zPq5Cs4TkBWwGh0p2D+UGmBdSB0ecvu76Y7b7IBea1dTyLIzaWbPuzqHX07jq
         RMr+Y7AUO1eKQ7XpESQbbIHxrNk4oGhBWNTjP4xCF/2k23h4UwQlnjrJgVvPnB+0k6Yw
         nQ8KWo/OzWsYl37nqFp7uy+/bcOzymG5NGEY/VRfTG4J4EG9wPmMVxu/E2ldzxzXmnFO
         57bfoj6FeoV9MW8QsxrtrMD5LQXCp/kJpfW7bUFEGyvxilFm9MHCUPakV1ibiq22bSg2
         +veQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="SvKO/8Qu";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b36sor6687186pgl.8.2019.02.14.18.38.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 18:38:22 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="SvKO/8Qu";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=QS3mWzK39q3lW8WqJHFL6wuRYacMcGaOmOmP8soCdrs=;
        b=SvKO/8Qua3oK4cc04JxBOABmX9Lcs7OlPSis//wxrWJYxpUEEW0AwWfwFg7XPPkM9+
         QADPLQsqmaC/p2ZufsCfS3Ge83uGWPUWE09/20bfO/mh4I0ezFUGT63uVWuoI3PWUc0b
         7tkcSKGPRr9Z/G3N+gPRFwa09FtMiLR/oAZZ6Nfw3V/23rM4gjawS+m+B/f2q95GXwF4
         DG85JqW8Awyst8kSFZ/+DNXV1GycMdMZkuYlI9X+lNzCnx33LVj20wM0JmDE1ZhBX9ye
         ahW788DDSK1er+310WveH4ER6u0KEwCb0tkfiCK/ym7po3kDquKXj0FnrzXnfMhf5v6s
         OI/A==
X-Google-Smtp-Source: AHgI3Iba0jcQFwegqG4NLDbZHaOWcAX7sXcmudyJYCZAfU2Rx3rH8jIxfvL/3yVO80UpTMBO9iuHZQ==
X-Received: by 2002:a62:e704:: with SMTP id s4mr7409860pfh.94.1550198301951;
        Thu, 14 Feb 2019 18:38:21 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.53.51])
        by smtp.gmail.com with ESMTPSA id d13sm5397358pfd.58.2019.02.14.18.38.20
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Feb 2019 18:38:21 -0800 (PST)
Date: Fri, 15 Feb 2019 08:12:41 +0530
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
Subject: [PATCH v4 1/9] mm: Introduce new vm_map_pages() and
 vm_map_pages_zero() API
Message-ID: <20190215024241.GA26350@jordon-HP-15-Notebook-PC>
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

