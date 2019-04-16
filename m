Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6B46C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:46:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C96320821
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:46:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oeEcKFpL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C96320821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0098F6B026A; Tue, 16 Apr 2019 07:46:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFC146B026C; Tue, 16 Apr 2019 07:46:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEC886B026D; Tue, 16 Apr 2019 07:46:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A7EB86B026A
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:46:56 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j18so13909702pfi.20
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 04:46:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=cNyFM0J2DfW9voxw9FzV7E7Y/LrzsWkGDKLqwe0d5pk=;
        b=JzmXyDQBC8/2AIW9zTfa8cmc4AkBgXpGJDKoZ4JgG2cvUOd+cfvNqxMCOWaomEQtzg
         Ho0ZNo0e7saNjV30P3S3w8NeMT03+/OgHXoxWbGUq0nebHsojTK0czVqtifj/sEN+u2J
         C+q6Si1RvQVZ3U1HMtA1RZPCxVJrJ1z6ilindCUnG6qrQrOl6cFIMiWCBcOqTrqPqh7i
         W9L5PxXWTdWtmBicrL7w4WhPLoWGXk7VVSiR5vNhR69HBy9SDqppDyTAwVJKZEHs7Q8/
         cxOdfcs3oYFipXhGSdoUBUJKbtTWTO/l1OAyG+QBbmUrvxnbcCm9BjO4RtoA6QZsMpQ/
         FBWA==
X-Gm-Message-State: APjAAAX26d4D5I9x1k8YQCeeo/PIDGOdPt0MPiPrF907+dtYX+XztJmO
	e7k+dyxEr01194rrNaCTEN6pWB7WCcQyE0KyI8ivqOktBR82UGD+f+k63Bz+U28mLmL0EFRVg/i
	Ii3urx+u/791wzCL9cduU5Fm50ede3TNVXX5EOJrXQYcNnH5iNp2Im4jhg1xFhebOzA==
X-Received: by 2002:a63:720c:: with SMTP id n12mr76256845pgc.348.1555415216371;
        Tue, 16 Apr 2019 04:46:56 -0700 (PDT)
X-Received: by 2002:a63:720c:: with SMTP id n12mr76256781pgc.348.1555415215445;
        Tue, 16 Apr 2019 04:46:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555415215; cv=none;
        d=google.com; s=arc-20160816;
        b=dqHO+zCNFVjIm+e/bM4L1H4WYaEdz/FEju70ZkTAETuIdzYODeyxgm/0UPCRfYyed3
         NCZuGTS2813wfn1iM+puuJwn6RG09DIZvwhFBmnUg4hC0VqkN8atsD5zskgC6FcqU+bh
         3FlG8gTxZdOrJW2S8oIpqVvLy4WmfCzwVZnErXMqhcb21A4H5h1maYLDalFF0XMtf1p6
         sxlxaxxIF8+e9R+czQp8O4YsxE9N7Zno8Cy4Sp1O4B19EOrmUmM53QUk8alqu/vXKpRl
         4egGR5Z2fKhEmByzrx6N//79iOqWUmC0sc8JK3JPzw2noKX544EknNEYsBJn+P8Hip+u
         yLKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=cNyFM0J2DfW9voxw9FzV7E7Y/LrzsWkGDKLqwe0d5pk=;
        b=j2SiMHrveZTlVS1JJoQe97f5jb1NKEWwXtkID7qN47kb8dnZlmqteEHfE8j8R8OK/v
         JyaL195jopq7E9OyN0GlzmBO8USE+s9K+muUD978bsfW3WjrvqPtiX2kJS2OTTgWxGqk
         3zlcPjIKYQCXlWj0tzI6IUYp2+hwxAigtDXM3MACHHWscLCyFfW3DkpZeE/Q9K7KFHwF
         RuK8RnJGbb3nhnnV2MAMM7cDx51gCUt1mkVlbF/TmzldTc6zHYZuqQZhm/QLTNbw94Iu
         rU6nhu5riH8xKuBPA13o7gUlG1PzYrBzG9I0cZ0eZXAyF2Flp44hKqGtEFxVJLrXSG8V
         PIDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oeEcKFpL;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k75sor45935281pfb.7.2019.04.16.04.46.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 04:46:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oeEcKFpL;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :in-reply-to:references;
        bh=cNyFM0J2DfW9voxw9FzV7E7Y/LrzsWkGDKLqwe0d5pk=;
        b=oeEcKFpL3vmK9+DpAkDM2pqJ4cwz8D1E2liXXkVcMS/mCROTNxreZ3tJiZU7AMhYGa
         jdvIuxFSG51quKMSoG7eGUWo0OFVjsfwlsv0j6QgATWKo4Y/zRlxt4YEDfEpCBvwBcDU
         oLh7KOdm3sUnBXGsWZumlJIoubWl0FlACsdqSTDMD22x9YueAbdJduUdqxf+Fzo+qE4b
         G/2XochB6n9yIyfIIw7vwaFhmKiDJzF2ILx3ft6jONO/3Tp5olQ3mZrspX0N7+OtxUzw
         L3gftE9ttJboi/nhCsZ8IHvh1byiu+1G+2wjx/i6t9Le5dXmn/WMY4e9g4nRHdsI6qmW
         KGJw==
X-Google-Smtp-Source: APXvYqzT/G52JjPlhhzDjlzXSHHg4UNZ4b12u0OW4Mw/nQ9ugBF4FdGP/KIWXfE/EW5Pz1mzLpMj5g==
X-Received: by 2002:a62:6ec6:: with SMTP id j189mr346760pfc.195.1555415215118;
        Tue, 16 Apr 2019 04:46:55 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC.domain.name ([49.207.50.11])
        by smtp.gmail.com with ESMTPSA id p6sm55942835pfd.122.2019.04.16.04.46.45
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 16 Apr 2019 04:46:54 -0700 (PDT)
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
Subject: [REBASE PATCH v5 2/9] arm: mm: dma-mapping: Convert to use vm_map_pages()
Date: Tue, 16 Apr 2019 17:19:43 +0530
Message-Id:
 <936e5e107c746a7310e3a3c471188ca3ac8f9754.1552921225.git.jrdr.linux@gmail.com>
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
Message-ID: <20190416114943.sUl31BEeoNCb9-3VmihTLQz04yiTguD2ACz56C15RjY@z>

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

