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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14BFBC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:42:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C55052192B
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:42:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JZi03g5m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C55052192B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CFF18E0005; Thu, 14 Feb 2019 21:42:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 657338E0001; Thu, 14 Feb 2019 21:42:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F8BA8E0005; Thu, 14 Feb 2019 21:42:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 116698E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 21:42:44 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id i5so4911483pfi.1
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 18:42:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=XQSNSZywn2J5tIibcMqEyCRYg0DoENdsUd09NDa1qxo=;
        b=lnqKi/9yHx1Cjuo2cKS6tihJoDHuz0pzs1Zxny0B1lfOA2KpsYSphRI+WEX4ERXbU9
         6zZVRXbenia9B0WCQxisLMOEo/3ztroOLsHkoTxbkWMbaY6rCFskH8Tx3EMJ5Jq25g4t
         uXsxvxDHLf5F+i4M4crb3e8Lt81oW9pnig+NtnlQvcWTnKOEAsufUe+lg3Ohjnzf7QLh
         II1BYN2ODsMN1SyKGQoQUkSA3CpkOMjY9cSJuZ/syd0uyfh2R6nB8EzRKDBsF+EE1NSg
         AxlJUj63IPpvZH9qrooFsvt6xtKenEGNt9qVtdTibrCie0SoWxKgsy48nXvqR1UlWPNn
         gHyA==
X-Gm-Message-State: AHQUAuahuUkD2TSOmQ2EMykn7ex1hcBbSB8UUhWHsvMvUwUhtfbYIXg9
	egLpPXiDzOqXD+9elxXpzQi9CtspP14yWLmDQKNJdiBOrInC1FRPPiCshKbUsub41wevs2raIFb
	FS0VCFR6yD9fT6uoD6k0gMjZ+hhF/A5x3GZI90UW8nThy3TgX3R/TmX8dghPCSVT2BzMlIrhj9n
	lY8V+oiSRvYRQn2vLSue8VUjrgbikTmSWNwdRg8+GpVRRZGFij+BYHx8ZbeZVBsQintqwQMtjnV
	L/DG/rWcIlEztYjAzGOa/gNQJ3TqZQ50E+f3u6fHNTSkfzXvQ1vgGM/oTjZ2AJHsl/sQdKd82m7
	X/wSMJCNp+FCCKcpn35IF0cM36AKmykN2O6tphvUR0LLxbUJbSHw77K68DLzNPHkxZUjY+hAliK
	i
X-Received: by 2002:a17:902:4124:: with SMTP id e33mr7681474pld.236.1550198563757;
        Thu, 14 Feb 2019 18:42:43 -0800 (PST)
X-Received: by 2002:a17:902:4124:: with SMTP id e33mr7681440pld.236.1550198563135;
        Thu, 14 Feb 2019 18:42:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550198563; cv=none;
        d=google.com; s=arc-20160816;
        b=tB7oYnx4d4sESPU2LPXMiIHk5EjrUkJCeDL7O91x/4epdBgTEQvcdMHya/cbVUPrKO
         N8xeWtee2m0Sur5RG0mtvAauB2ZIfsCnYBYTLadgiq1DsahOuyuCCBC1jy/FwTPrnXXy
         rIidx8fPGrvmSOmEdPdYrvIk9ru4BpHyZSV+NNGh72BR4iJxJZBzSIcGAVcaUXH06WDg
         Ap/sgQUfyg+XCxo6S/cNajrfJ30aqhVZPEe1/vM0gPZB9L/VQtQooOc6uM1Q2kQCvsWG
         01Da70V2lPwPNEHRS3lolfdlZ5lGacIvDRQDDSUJMMPfrefHtsL2gjDUsfNe8chnpec8
         KSUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=XQSNSZywn2J5tIibcMqEyCRYg0DoENdsUd09NDa1qxo=;
        b=rSIxXsUPe5tbSLrvgRG0MbMX5K6OE8jdeqocDiyHVO6flVfyeqBubBFYq/pTI3fNyG
         rEFHetkUnG7ejPFA8ajH7g+6RVxBARVuE+pzn/j+WXKDHysa1yRCf4LnaIlkhHBlOH7l
         fSSvvrSJTo/XM2K3/SjD7Sd7ShxGclyT56FbeF4cs168ynz945KplvZNPM+7BbuZaRpc
         UvbP5ceRVub3WUCQWOI2LK98ZVTIGTvInmxz7DxhIZ6YZZGsoI8aH4PniwIIqI+ruCB1
         7IkNGQjmtgsQaw7XdeMsLBiGrzGd5uHF2xpxzdCBEk3Wfgmzpu1eQQgos9kD70PrZpnl
         5dsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JZi03g5m;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 35sor5817876plf.23.2019.02.14.18.42.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 18:42:43 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JZi03g5m;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=XQSNSZywn2J5tIibcMqEyCRYg0DoENdsUd09NDa1qxo=;
        b=JZi03g5m8SqN4fzXTLvaMrZBoX3tseOnsMCKC/62M1fb+WcWoioZRu2l43B9pfFRQ2
         WXlq2oi4wn0yLXfiWFYswzWzIwq4w5bg5KUOQqXwHgWQAE+lk6jNrBiI49ibZOXzAjYB
         S8xwAOlxwx6HrAa45AL9/1l+BkEjI1D/wYBYF5rR1UnrnGZzphD/5/CSGuRCJ64MvEcH
         DReeXATf/+Jz4/zN0EJD+9cfFSCrLW6CKrkgZOu8eMnbvIrFvUZ+1Plc5qyMCcYCp2YU
         2sV0wsN2fmCXsUVqfPMdD0e6g3l2vcbQyVMaPVeMlRxx/bfrmGunMWVPf8F0LURXsG/d
         FuLA==
X-Google-Smtp-Source: AHgI3IbXbVi4CkMxM7o0ba7dPvq9bi9XCTF85E7sfNodnY+9YIlbe7/Qi7XYnRlOQPjwRJgGuWuFBg==
X-Received: by 2002:a17:902:bd82:: with SMTP id q2mr7737899pls.156.1550198562436;
        Thu, 14 Feb 2019 18:42:42 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.53.51])
        by smtp.gmail.com with ESMTPSA id z62sm8961035pfi.4.2019.02.14.18.42.40
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Feb 2019 18:42:41 -0800 (PST)
Date: Fri, 15 Feb 2019 08:17:02 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	joro@8bytes.org, linux@armlinux.org.uk, robin.murphy@arm.com
Cc: iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v4 6/9] iommu/dma-iommu.c: Convert to use vm_map_pages()
Message-ID: <20190215024702.GA26442@jordon-HP-15-Notebook-PC>
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
 drivers/iommu/dma-iommu.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
index d19f3d6..bacebff 100644
--- a/drivers/iommu/dma-iommu.c
+++ b/drivers/iommu/dma-iommu.c
@@ -620,17 +620,7 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
 
 int iommu_dma_mmap(struct page **pages, size_t size, struct vm_area_struct *vma)
 {
-	unsigned long uaddr = vma->vm_start;
-	unsigned int i, count = PAGE_ALIGN(size) >> PAGE_SHIFT;
-	int ret = -ENXIO;
-
-	for (i = vma->vm_pgoff; i < count && uaddr < vma->vm_end; i++) {
-		ret = vm_insert_page(vma, uaddr, pages[i]);
-		if (ret)
-			break;
-		uaddr += PAGE_SIZE;
-	}
-	return ret;
+	return vm_map_pages(vma, pages, PAGE_ALIGN(size) >> PAGE_SHIFT);
 }
 
 static dma_addr_t __iommu_dma_map(struct device *dev, phys_addr_t phys,
-- 
1.9.1

