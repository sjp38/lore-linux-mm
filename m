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
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF9EAC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:39:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E87D2192B
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:39:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="C8J8YEaP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E87D2192B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 328008E0002; Thu, 14 Feb 2019 21:39:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FE0C8E0001; Thu, 14 Feb 2019 21:39:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EF6C8E0002; Thu, 14 Feb 2019 21:39:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D0D0A8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 21:39:10 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id a5so3104821pfn.2
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 18:39:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=cNyFM0J2DfW9voxw9FzV7E7Y/LrzsWkGDKLqwe0d5pk=;
        b=r6vAt/2/gQNPea/HeVCbVzHkeKAxssXtmW+6owRf+rf1lewSrxA4YksfwMX2S1fDJA
         xIPDZpgom4U8vME6yMOCk3kLt+zLc7h0u1k+a/KZX2QFanA3utWy9Ru27s+fFwTn2mOV
         MiGW9J8WegSm+Nn75aLBLni3sMOir55ZMZ9Wju4dptwKri0KJ73beFbbag/3VoiURm+0
         CyqKgYMFXFOg3vEbgmYz7NSPOnpZ/0FdRhxc5+nJCtJfU60PrNBokR2hUc2RdVEAFySF
         LfZ7h7xCVpHh1AsolhKb9W+J0D6mpXI6umJU7g7abKpf73a2RFAoynDOo1Y7r8jClgeK
         cnqw==
X-Gm-Message-State: AHQUAuYjK/93SGlk5xnD2E0aKiuuKONDEuib4Xcd1ZCr5tzHfjh/k4Us
	X98DcaF+zjCUfKS+eX9H2MxJ/lftwDchewV3hRImqEvGNMiDnHG4Mxm2H1i92ERArN+eR5bl6PU
	3sDRyUgvmjH7jfJXAyMIHnhE8I1T/k7uXezGQ3fd1b1YrUkfM0WpekL+cO0iJxtGf+UNEtL+NER
	hUKBlC8ZFMVCBdbENfaV8+sMO83pPbg7QBxwH4RWYWW2d9YwAkJ9WGGHU3fFInflD/ok7DrRq9L
	mcfY6iArIu/JHODl0aIuEwXRNHeVF6aROHs/CsB/EU68TJeD2lNnHSgIoL2HxWISMKfaabEHww6
	y9pnydV08d0nyyfqyblpI+PUd3MJ9zG2/yhYcKm0DbR5HILUnJ78aODQidexNUOYuwJKqmuvTWY
	F
X-Received: by 2002:a63:d50f:: with SMTP id c15mr6968408pgg.287.1550198350536;
        Thu, 14 Feb 2019 18:39:10 -0800 (PST)
X-Received: by 2002:a63:d50f:: with SMTP id c15mr6968360pgg.287.1550198349777;
        Thu, 14 Feb 2019 18:39:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550198349; cv=none;
        d=google.com; s=arc-20160816;
        b=JJPdc8rov9qGRAgR/YKbKZVWa7A2lkcxTEgULMykWx0OMcG5sWbJevVhG0txr+4zmZ
         2a40xIMKFFNY4NHPeUHadcL457WXAkLQe5AFMhCtTuX7RNijaAQ58FLKrMu5c7/8u01/
         Bn0lsFxkAbmDDSD+BeviNeIk3RlORftPYvhqnmuLTST1jUsYFubRhFjHC27vZG4nz4f0
         tDlt0IzwD6kidM114tkbaAY48RsuuCrFtp5w5S6l8799Ee1ZbPlDJ6fnENeB/iNtJLDD
         SG0y3M8F2GoXFaodW6Mri7JU2mt5aETYB6W2PA9WxmypXnFotx2AabXQASPWVsHgUvqF
         OY5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=cNyFM0J2DfW9voxw9FzV7E7Y/LrzsWkGDKLqwe0d5pk=;
        b=MWhM9rU9iZ6yXRJEQo8YKWs9vZyb9AHHlbnSoqGlh4jkIVvgK9XlvGIgSirsEMRuEW
         M2vg8lT9iO2OA5xsMMUTQ53vpSoLjHfJiT9GBv7s2LKuCL3kLUhpLp+Hu/31ZXzARFE1
         mfDGVDIQjQsCPoONZW29vDS8p5JzxosWUUmXFyuJYcDesdP5ElTtWWBcsDwHeIo5DrNH
         OggtTkeYe8DEoGdHaOf9Bc/cEJe5/mgQICEbV8YhrefhoNiQt6xz1ZmWVbU8aslQaLwg
         5H/wLRvplXSul+ApneXLDpfxMqftqflhVf9dW1hsC87oc6jau62LOsl3wC/tU5Im7JHq
         lEsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=C8J8YEaP;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h131sor6773321pgc.9.2019.02.14.18.39.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 18:39:09 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=C8J8YEaP;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=cNyFM0J2DfW9voxw9FzV7E7Y/LrzsWkGDKLqwe0d5pk=;
        b=C8J8YEaP1sXar/+zW0yONM/GThKVOZP43UoKx+bsMs0rR+kOwbwuiT2BIDoESBLxKN
         X6AH8lyLqHVlJ3S1+7SjnEjca5R1G8T4RFnjNToQO6v4YNaQSQSNkLbvxe90zZykLVDi
         54ov/SHMO/cZOMqPEs91uSOr6MV9wmu9R1mZMEKYCox3q1ABu4U+roRJf/5xpBsTlTDO
         KAmeeosjCfbEhSgpHYgu6X3qTk/lRll1yN/eR/pYc5h5Gznm4xGDGVTvZ1VW0BjA2yKi
         9shB5cJBIHEFyFW2Gn9ppb3AKrv2U+8H26GIKZ1mUlV4K3ypWZYz6UbQihzp+r6bWUJk
         St0g==
X-Google-Smtp-Source: AHgI3IYPDJcfAJcux7am1/kgkI8RGRJz/Eho2e26RlxYpln5H5W4x8B/Nfk9OSESdiI7mMZpfEdzLw==
X-Received: by 2002:a63:4b12:: with SMTP id y18mr3125993pga.340.1550198349469;
        Thu, 14 Feb 2019 18:39:09 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.53.51])
        by smtp.gmail.com with ESMTPSA id t3sm4758131pga.31.2019.02.14.18.39.07
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Feb 2019 18:39:08 -0800 (PST)
Date: Fri, 15 Feb 2019 08:13:29 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	linux@armlinux.org.uk, robin.murphy@arm.com, iamjoonsoo.kim@lge.com,
	treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org
Subject: [PATCH v4 2/9] arm: mm: dma-mapping: Convert to use vm_map_pages()
Message-ID: <20190215024329.GA26372@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Convert to use vm_map_pages() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 arch/arm/mm/dma-mapping.c | 22 ++++++----------------
 1 file changed, 6 insertions(+), 16 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index f1e2922..de7c76e 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1575,31 +1575,21 @@ static int __arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma
 		    void *cpu_addr, dma_addr_t dma_addr, size_t size,
 		    unsigned long attrs)
 {
-	unsigned long uaddr = vma->vm_start;
-	unsigned long usize = vma->vm_end - vma->vm_start;
 	struct page **pages = __iommu_get_pages(cpu_addr, attrs);
 	unsigned long nr_pages = PAGE_ALIGN(size) >> PAGE_SHIFT;
-	unsigned long off = vma->vm_pgoff;
+	int err;
 
 	if (!pages)
 		return -ENXIO;
 
-	if (off >= nr_pages || (usize >> PAGE_SHIFT) > nr_pages - off)
+	if (vma->vm_pgoff >= nr_pages)
 		return -ENXIO;
 
-	pages += off;
-
-	do {
-		int ret = vm_insert_page(vma, uaddr, *pages++);
-		if (ret) {
-			pr_err("Remapping memory failed: %d\n", ret);
-			return ret;
-		}
-		uaddr += PAGE_SIZE;
-		usize -= PAGE_SIZE;
-	} while (usize > 0);
+	err = vm_map_pages(vma, pages, nr_pages);
+	if (err)
+		pr_err("Remapping memory failed: %d\n", err);
 
-	return 0;
+	return err;
 }
 static int arm_iommu_mmap_attrs(struct device *dev,
 		struct vm_area_struct *vma, void *cpu_addr,
-- 
1.9.1

