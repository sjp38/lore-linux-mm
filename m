Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF89FC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:47:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A299521773
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:47:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QU7zypPw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A299521773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FFA96B026F; Tue, 16 Apr 2019 07:47:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AF2C6B0270; Tue, 16 Apr 2019 07:47:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29FC56B0271; Tue, 16 Apr 2019 07:47:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E72046B026F
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:47:34 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f7so13916982pfd.7
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 04:47:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=XQSNSZywn2J5tIibcMqEyCRYg0DoENdsUd09NDa1qxo=;
        b=YSmfzE1Gvls6sByYNurVEoAVj5Rya28VZbUSf/wx/WuG9k5KVRIDsvPRHjMHcZPubJ
         yU2PLIxd/BWgHnijteYyavW7O/NrMrxbfrz4wtta6Vc0f4z+BAU2s9YjhldUqT375ZB2
         WNm5+4LObkwMyMWdkBnKBIAxiiPSIM85NKZuWQFOV/ss9bccKc1/C8inuqJAqjTgHSPU
         GZFGQx9011uQm9xO/iECT1mhQdgJeTLDAVnshYlz31y9o0n971EoPIZSSpNJDAIt0L7B
         t5Rm5mzB1cAKpdoDLsR4bOoxwcEorWxwiUBlWRwEmOPYJaVnNyIBqVGAA0QX0z2q+oxF
         dd0g==
X-Gm-Message-State: APjAAAWKljsOgD5K8m5GSQzDwbCiraa1XCP9HtNZBnxftW1n5WQnk/vZ
	67XrrUAD6aaKP14sPkTr6kASgVGPY2jMHaPPrxcTMhEMfxAyp3v65t4yi/ku2KIyKnDAo1bAby5
	H78YIfBQ7QGYZqFjoAu2EP73ct/rnNk3cwCZmzuZbuA+dzXE0Le2zpadA59JLsmy48g==
X-Received: by 2002:aa7:9ab1:: with SMTP id x17mr76374450pfi.4.1555415254640;
        Tue, 16 Apr 2019 04:47:34 -0700 (PDT)
X-Received: by 2002:aa7:9ab1:: with SMTP id x17mr76374393pfi.4.1555415253937;
        Tue, 16 Apr 2019 04:47:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555415253; cv=none;
        d=google.com; s=arc-20160816;
        b=zrcAcmwDGkEaExYQb8Mqtyb4dT4YGjdoHlrVXYDMBKckKDkO7aMq9mRVfFJhFxYn3T
         MNSKhx6hxvrFm7pYBue9Xl1LsSsxaFLfNZoK84uSCd95RwgF5ZujohaCeMBS9qyqyN85
         9ezk8x+fvj1gIpFbsdFuc2o1U9v/bUL0Wl94/6jZ0qyqRBYC/UXM0dKmSy1vD4WZNqMI
         8GfSTkFqwdaI9omo01LJ54HyLBvc+nP/QbGMklomDuZCsS2vryozn1WspLSq8oyrO5UQ
         KyXIDl8sqzjNhCtd4bH0dxiAQ2RWmQxLAWNRvVvs2BqULiZqrgfOZaicNi82ieZHF95K
         Jkeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=XQSNSZywn2J5tIibcMqEyCRYg0DoENdsUd09NDa1qxo=;
        b=C5jD6/y7Ru2ZPZENnbQiaUSzAGeBQiptMEW/euiP8bnIroVa4B6XrcZm/0gR6m/lfC
         2RGo1nmmQzgPmoxoyFxW5eCYGUEg/DtwxSOV30dpV46QE4TkiJVBwN2Ryo9viiCWVSHj
         TY8GDjhO9bZbjkUwg44vMotYMhI7WiRNOZbNxn+Qz2SIQa2qoUihi0ruaJzYr0APyGT+
         VLIWQGtGaDP8pCqolu0clX+epdftEFMTF2YY2qNWJkD58nP1U49eSXDujWx1PNTHxF33
         VUK/eIi1BFXXWA7tV9mQgugldcY2Y9xrjfGiwwwtChzrI1FQIyjZajzyhu9lXVV4F9od
         dKIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QU7zypPw;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g7sor25770835pfg.13.2019.04.16.04.47.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 04:47:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QU7zypPw;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :in-reply-to:references;
        bh=XQSNSZywn2J5tIibcMqEyCRYg0DoENdsUd09NDa1qxo=;
        b=QU7zypPw1WcpMxPNCjSaR++TBxlQknuhjLVn/zaIQwjmOn12W8kM5SRWXeRSniSIiQ
         nvWs4u3O61QXyzVFht2ICP1gsPHIZUm3ad2VsCN/SyjHCTFWoSHyQfjmYp9DdtyUBaTQ
         BJawsaXLI03EMX2IZPCe6XRNLtbXberYyZ3mJqTPPZ5MQ3FMuPF6guMSfqSb+RWysVuC
         8lRcAAUhKgdn9Aeu7inwA3G4VSt0hChEPqIvDaTLmxEMhuLSrCEonk3ftiCQIyMRXs6b
         uGyLPtBauzLGcvw+vV+Kix8kWY2mAa4ADOTTyJKgDjXtcsidFwBHAyNWYPc19m8AkhM7
         YFTw==
X-Google-Smtp-Source: APXvYqyMCj+Ghsusn8bhw1pE9GkbUM8F5CYPfXi5LJf73fYESAfpDuXDqO4AOj4QsBAxm3YNHO4Aug==
X-Received: by 2002:a62:6086:: with SMTP id u128mr82559935pfb.148.1555415253653;
        Tue, 16 Apr 2019 04:47:33 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC.domain.name ([49.207.50.11])
        by smtp.gmail.com with ESMTPSA id p6sm55942835pfd.122.2019.04.16.04.47.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 16 Apr 2019 04:47:32 -0700 (PDT)
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
Subject: [REBASE PATCH v5 6/9] iommu/dma-iommu.c: Convert to use vm_map_pages()
Date: Tue, 16 Apr 2019 17:19:47 +0530
Message-Id:
 <80c3d220fc6ada73a88ce43ca049afb55a889258.1552921225.git.jrdr.linux@gmail.com>
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
Message-ID: <20190416114947.4sY1emo6vZU_Kuclc0x1eQmjJQW56KQqEIqgyjcJi5Y@z>

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

