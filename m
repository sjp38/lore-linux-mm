Return-Path: <SRS0=oA8h=PB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17358C561E6
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:21:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C603E21B69
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:21:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CEHFTcrB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C603E21B69
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 681188E0008; Mon, 24 Dec 2018 08:21:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62E9B8E0001; Mon, 24 Dec 2018 08:21:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D13B8E0008; Mon, 24 Dec 2018 08:21:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 061A98E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 08:21:41 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id r16so10809256pgr.15
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 05:21:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=hyvE++JUAtEdBgl01+ceVDX4NOixn/zsoYEYg/CvJYk=;
        b=nK8Y9dXyi1DKpBb16BHEVmawNtbVvi2hjDwPvjbecflXmL/8Npopd7H1DwNUBiWsXL
         Vlc15qy7Rth1Jn93xuS1Xoc6RVJkWvJPcS7rqvtU7MOm+ee0h4zHwoJOAgnHaFKxvt2C
         HZQqK0J7HmxP2xuVfym6At6qMkx9PYiDZhcOXIVcyHphxAzEPg7ADqV2nwXKv826CDf9
         jFci2jI/o48cVHYkNQGv0NpTa0uu5qumhJMmWiVhGDTrasBga51D6+iV4xWkSVIfTljR
         fiqiWkyO92A8quHMen6uiPL94znrY3srR92JoC7MPWK/ixVRzqotuetKG9LZ1bp2Bchq
         YPlg==
X-Gm-Message-State: AJcUukeS0bApYJSuYs5IfcBCZp/VkIqxqvsvVxGpHl16Vagbr8O/AK28
	e7Xm7LWiI/aJsBvgTpvS6O5EDlYxCqLwf7R0wq4/98n8AgttMzODff3fIFu5a3PKQE5WHEzPrw4
	Sp/wwf6j7Jce4nGE/dTV/v3igf57aFcFZkubvglUSvHV9bQ4vZ8Px75EwOL8ie6xGXB60lXbLRA
	oGUhGntHRGPG4xavKYIYKQuJ3hZSpFCpkfR8GZd98fQgJAT6Sni5iksXTvil0U+1+ZLv3YIkDG+
	s4dAdfai29gxcy9KRoh46o48vmTYvnnys8a4s4B3wtVGkqI2vjnR+JIXG1/XNcSNCqPzN0PkKSo
	AGr4ROgl4AuQ1D9tf3o2mhNfJTcL11b9c0hbdDqYTaiF8JiT0+nXqAYNNgvX+AktidrF+4+r4M8
	q
X-Received: by 2002:a17:902:28e9:: with SMTP id f96mr12992563plb.169.1545657700714;
        Mon, 24 Dec 2018 05:21:40 -0800 (PST)
X-Received: by 2002:a17:902:28e9:: with SMTP id f96mr12992522plb.169.1545657700097;
        Mon, 24 Dec 2018 05:21:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545657700; cv=none;
        d=google.com; s=arc-20160816;
        b=NYVPNX+AHYFD5uiBAlcDWO7RomLMWlxEb+En/iRFeFHuiwjTjJAn0eYJXC22y+KQtn
         cDUKKzREeCqQG8+DZSaxnY23qP0V93YA2qpyhgtWjdYN6kpq1mumRsbf02Q4PW5zblh3
         NaKD527ePVMPQ/pjc6zXNBLoFJweWy15LhrEFFygkA651JrV6RqzbxdUC/gWFuVdn2GD
         YunRHzmBlTOrZh2APKFwSSDFmEkCi0o6nauG5XCoa5ADAwL54zzwaAlVDd7N/ns03GMr
         xQCpzIMNJX2XZIy6npkjJI7oiHDiDKJHWHZECV5yAyHYcKg/UkNGvnR1vmygaOxZtETU
         Hb0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=hyvE++JUAtEdBgl01+ceVDX4NOixn/zsoYEYg/CvJYk=;
        b=YVnnLieCOfsmyOwxhiWvfBrlzOk9pV/2x+EEpNTj5wVTTr5vKhk6CrjUfaxKKAmM+K
         rOJ4ff9j2qNW06Yn3WiMU6Bj4q+/lVl+Dq3ZqsDOKmdVU3nKUS+694hpp/g0/rNS/3yO
         lPTVfsfr2XrWJsVBQrOWSG0YRp9oodOCuFkJIMlZKFeRkxMQ9jabOquhKlVJoOzDUxEc
         3G1jWzlOKnhG4CvQMA3N8DU+T4IhnimOUt4eLWO4e0FIu0DdINNjV9PjkF00mfUWg/Pz
         d86hj+oriqPGgOvP5FFjQol9qVMt+OALnasT3agCoY4ex7HebfQaULQF6zAXb0wHQ3tP
         wshQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CEHFTcrB;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v13sor50589385pgn.66.2018.12.24.05.21.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Dec 2018 05:21:40 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CEHFTcrB;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=hyvE++JUAtEdBgl01+ceVDX4NOixn/zsoYEYg/CvJYk=;
        b=CEHFTcrBkyeCWeCmPrwn2688YXOdYONJIrN0FDYedH3wOLlUMBEllDzlhZcd34fVTK
         PVN/K5qsz/SDWgrxoU447eNOJ+Uwup96nxoNgOgUlQOQ13YmehCBt15uIzwDcL834WB+
         1V2D5GZRCpWh5bWe3K+7fli2aLbfN7muPdbKp+K5klF2OAEPz3Omo3WxJVWH+iE0KYW+
         WRM7Y7bB/2Q4e7scf8d2tc9sHWt7qho4T1VtjVba0K8NyB9RvGQ16XNaDLKLohjtuJ7W
         M/GFEzgPI0wWXk5qZ9aQAs0zJHqCzO/cRE/cf/TYZf3+d4QEtZJUwwgpGUr3zwext/hT
         2vgQ==
X-Google-Smtp-Source: ALg8bN7sI6Y4DpvdHRECfX2DJrfkjetdnJLz04OveHwsKqHkXorBy4SWhZzQ1kNDsKb748UfZoEkUA==
X-Received: by 2002:a63:9712:: with SMTP id n18mr12115990pge.295.1545657699357;
        Mon, 24 Dec 2018 05:21:39 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([106.51.18.181])
        by smtp.gmail.com with ESMTPSA id x3sm101389647pgt.45.2018.12.24.05.21.37
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Dec 2018 05:21:38 -0800 (PST)
Date: Mon, 24 Dec 2018 18:55:31 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	joro@8bytes.org, linux@armlinux.org.uk, robin.murphy@arm.com
Cc: iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v5 6/9] iommu/dma-iommu.c: Convert to use vm_insert_range
Message-ID: <20181224132531.GA22150@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181224132531.F0JgvWN5ZJ2V_RHbKaEVIWIxyTWxwC-pucyLXn0glAc@z>

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
---
 drivers/iommu/dma-iommu.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
index d1b0475..de7ffd8 100644
--- a/drivers/iommu/dma-iommu.c
+++ b/drivers/iommu/dma-iommu.c
@@ -622,17 +622,10 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
 
 int iommu_dma_mmap(struct page **pages, size_t size, struct vm_area_struct *vma)
 {
-	unsigned long uaddr = vma->vm_start;
-	unsigned int i, count = PAGE_ALIGN(size) >> PAGE_SHIFT;
-	int ret = -ENXIO;
+	unsigned long count = PAGE_ALIGN(size) >> PAGE_SHIFT;
 
-	for (i = vma->vm_pgoff; i < count && uaddr < vma->vm_end; i++) {
-		ret = vm_insert_page(vma, uaddr, pages[i]);
-		if (ret)
-			break;
-		uaddr += PAGE_SIZE;
-	}
-	return ret;
+	return vm_insert_range(vma, vma->vm_start, pages + vma->vm_pgoff,
+				count - vma->vm_pgoff);
 }
 
 static dma_addr_t __iommu_dma_map(struct device *dev, phys_addr_t phys,
-- 
1.9.1

