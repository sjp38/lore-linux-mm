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
	by smtp.lore.kernel.org (Postfix) with ESMTP id F31CEC282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:01:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B12462190A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:01:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Zwi9ddgs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B12462190A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5018A8E0002; Wed, 13 Feb 2019 09:01:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B2238E0001; Wed, 13 Feb 2019 09:01:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37A9A8E0002; Wed, 13 Feb 2019 09:01:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E79558E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:01:42 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id e5so1720725pgc.16
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:01:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=XQSNSZywn2J5tIibcMqEyCRYg0DoENdsUd09NDa1qxo=;
        b=ebg8OhEHK88aKlFNOAWe7msQ0xm2mBoNQWOUXxwnDaDMGPuliVUTMpHrFQ/ylfZ2d9
         Rx6z1nh5Gq7K1UP87PSRsqpN5zhDaEWRhnRVQnLj6MSMpFR8Tpci5If2f++7NWDW8KWE
         HhjVFJlzwCOzbmO0mdntpjuFW2R7e0/5EPFkXhZagafC+M6aIA9Wu1TQBzb0GDyOfVU+
         9wzh20V7df+8iY41vwDMxWaJzYq1CmPsInKxCpvV743u7NlyHchCG3j5SM/BbesP29N6
         eAjEoAktOczpPKQPgYYw7AaIqh1Z1lSV1WvdRx3cu2W+VvWd9pTRhxDwrPUd6I2vt7u3
         nv5g==
X-Gm-Message-State: AHQUAuYAfeH8fbGicT5zU+aqpsWNZbXSiwdU/wNvlwJTEkGeFiaJMTOx
	NxpHpk8rHqaAPgWcLn82xrptUTYhSELA44z5Xl/Jrd9zGz7/x5XgPJLWN/MKj/KDnMXpQvcuuXW
	csO83rXhy6mTYN2XcyBclnIFiQ0IFFpLkiCiwfnZBozhD+tPsr0+swgT7yFRCAAGoZF6RhRU3vT
	wvhKI/SOwocm5dgdJv71uM4yG/OlafXDlLRrBiHk79tIKEaF6MmUUUiZjLc1/Ujx99J85+z2dcR
	XZ+xHSOWJYia1EOeHQqr3UYjIJwov+Wwuy6UocffyQ/fFhAxvIvP1aDS5mwo4wXaVi4YsVobkve
	zhgK9ExyUjekK5+0QVBWxiI4W4LbyMRfRZ7M6cwaJGVQx7BUn+HhmVfyNFoM+IM930VUUbQz8pj
	n
X-Received: by 2002:a62:6453:: with SMTP id y80mr618515pfb.203.1550066499127;
        Wed, 13 Feb 2019 06:01:39 -0800 (PST)
X-Received: by 2002:a62:6453:: with SMTP id y80mr618453pfb.203.1550066498414;
        Wed, 13 Feb 2019 06:01:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550066498; cv=none;
        d=google.com; s=arc-20160816;
        b=CNZpFL4KbXjx4hlbLvNeAv8E8gMrZgvDzCwKSmOEAs0N0Zb28UrabLfBLVTVDibeib
         YqefjsbavVIm1EqgkFbd8ww/jagJLE9jhWaK+CXwgriL4KyScCjIrI7JdPRkjvVdXvq7
         pDDVhppyjXkNxrDjxZUcjyEGzZAxSj7vRKUmWCXT9iD524+/151rjzuu3liRQYYGageH
         9uwzEwPOgeCV4HOM89JIMofXKPFv165M/qJ2J0cKUAKm97i61bon7EbcknX2jT79IdfX
         IzFU9dnO6IhnfsY7OIQtNIXRsN80Ld1C/OvcY9mdP7lFQXJ0Mx4xB06fFnFM+MC5OkSQ
         OiJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=XQSNSZywn2J5tIibcMqEyCRYg0DoENdsUd09NDa1qxo=;
        b=qhu2aMJVcMNPE3t55GsAYngGIliKltdvKKWRIGzHkFV/wGGoXbRcn8iqqBa0T1AZzM
         C0x0bzqQZPM10Osfo1GLd1smgCvqVw/p4BXtFH5Ryw/vkbqNBAPCaUBx5HEhQWD9U9Eo
         6ibLTf3Ia6WPzXDZY4TKzAfWCcES8aRDpMFm5SPlIpqFvCIBFq7/1MKoRFXWOo4FvP7g
         24gg7u84qR1HE6EKJmg9TWH3kY9AnrgAZLXzgVZuUEgNFOpg+NxkxnQ/o/6kdwRxOGqX
         dv2RjD1meGZdsoeR7UFCG1vBumRDMjqb1nhLTI9JKYxkXu5YIgXB7+XGmSM9toN00yko
         pDcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Zwi9ddgs;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z188sor23982628pgb.42.2019.02.13.06.01.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 06:01:38 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Zwi9ddgs;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=XQSNSZywn2J5tIibcMqEyCRYg0DoENdsUd09NDa1qxo=;
        b=Zwi9ddgsFqc+aI6RdkAmjVmRVQY2kIKEA/goavGMF2UFBR08h4VxEcopFWUJ8ademS
         ZJOhPqL44qeZwQfJTEnpnw7+bU9w18GR7lIPaDoqZq57oox4meb6Xl74zzQ8HRGJgbov
         qInTG5TXVfyHQ4zMGO1uJ+vVConWVyQmndvdBQ+1MUmbcUjqQb5pD2dS7rqEHlwTiamY
         lH11ZOtRgcKEnG9eEW+nFs+LbEWXWyfD8JNldEEhi2Vob6oqD2b8EtFVXo+OCAXHAWRH
         MSbOIj/OUJgJkAbowIXY0GDKCpsjOzNv45CTvhRmag02UpXHiTn+BtsFC2GwTsr/2bQD
         r6oQ==
X-Google-Smtp-Source: AHgI3IbSufXkNPVxD86rAOaQ3sWfm+MBjGYH5NlkKVhrp9RhHT/Mp9udXAimuDrAmAMeLxIHijJ1fg==
X-Received: by 2002:a63:f552:: with SMTP id e18mr588329pgk.239.1550066497651;
        Wed, 13 Feb 2019 06:01:37 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.48.54])
        by smtp.gmail.com with ESMTPSA id s12sm15439846pfm.120.2019.02.13.06.01.36
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Feb 2019 06:01:36 -0800 (PST)
Date: Wed, 13 Feb 2019 19:35:55 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	joro@8bytes.org, linux@armlinux.org.uk, robin.murphy@arm.com
Cc: iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v3 6/9] iommu/dma-iommu.c: Convert to use vm_map_pages()
Message-ID: <20190213140555.GA22045@jordon-HP-15-Notebook-PC>
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

