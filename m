Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA1EEC282D7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:04:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6FBA218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:04:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tSgjerC4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6FBA218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F1A78E0003; Wed, 30 Jan 2019 22:04:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39F4D8E0001; Wed, 30 Jan 2019 22:04:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 240398E0003; Wed, 30 Jan 2019 22:04:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D454A8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 22:04:48 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id x7so1265717pll.23
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 19:04:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=9UKheLNLSM7085+hYajJxzL+Wpldb3TOma8RXX0hjL4=;
        b=scj8n5gtmWNJiKYB7C9ZjCcL3SGsBCs8lmuOh8hgOFZU4eo5igPH+lxGZf7u0LvYD7
         vwdPg2iq/SQTzVr3xQK4ZCZHHJHv4c9NLezBb2OO6qmavN3oqcgT/7T2pFKPROenFqup
         XQPQ43OyJ9CsApaJFjCGNIPHtbT48g6zUpxxa4lLUSpZnCW0mD5lq0IkJK/J1yKbTbOR
         AY9UNe4F3jgJw7mJtHkQVAbywK16z2tzyY4/wSeUoTduumSY/O/hHm9xo9CwkOmQwVqX
         R0/KIc1EWaGLb7mBJvoEc+U0yH1Nvl7UJcqBLsR7m7s1S5rr38GMvi+xHlCaLG4pwD0z
         irfw==
X-Gm-Message-State: AJcUukdH7vVHBOs/ENE13hkOY9KGExKmq4DXm04hRGj5y26yX3B3wtwo
	WyocjkJvKDDflJ+R3R7QVfvMeZCdd1CH4HXYV2rhmZzJk6rIRlcUjI6OxWFhlOvE6R63DCdBi/i
	sgZ52RzY2R3BV+1/KYRLK+h5/qNxngbV8b6L+/R1lotcIQZq/HEGIBcvQ4yeKxt9swJaCAaU0vv
	COa1C74PTZYp0K+Owfa54Yr9a3GDwYKAAl4tuxSllCIdFQxDphWgqIps1wNxhtiSc+oETz0rxJD
	YG4N4/EeUCKG3LaMGRWTZERjF3KNrHbSxd7wPcPr755wv/KUyWeFN7EjEDm7YjscSmhOTFoZ5zA
	4WIZANWPektaHUQFy/3F9LHVhgcwbjBHIfhLoVK3msaqQGFBAPlBt6NRNiYuyVBZ1ZsrGZZm3YP
	D
X-Received: by 2002:a63:5621:: with SMTP id k33mr30241917pgb.395.1548903888494;
        Wed, 30 Jan 2019 19:04:48 -0800 (PST)
X-Received: by 2002:a63:5621:: with SMTP id k33mr30241885pgb.395.1548903887717;
        Wed, 30 Jan 2019 19:04:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548903887; cv=none;
        d=google.com; s=arc-20160816;
        b=UP9tOiw0K+3L2fM3aS7YRdJYzHG8MFSLictEpxynqMC3gDCuU6pqPddVM48BdJA/V4
         hWy+uQlEzSn8PRbjuLLj7MY8bZY8bfR9cHgJ4fCEj29qdLsbXACACBFeAQpG5g6viI9S
         LydmAXCWB9NA4sqcyph96ER7vfrh/tR8Yg1nBQa0ufwE69et7cP0GE2BUJFv0jG7mGol
         pbncmXD2bIQgOjYPn4Im6iwepKp9TvO8z8slAI3i/5z4iQpnGXsuw9Coz/N4VMkSQGy7
         05YiwjmNsolSIhp7SETGNGSgkOIUzSG1SZ+snYRI5EUjTzMPJJ1E8rrqHe8px2Bq5FnE
         AF1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=9UKheLNLSM7085+hYajJxzL+Wpldb3TOma8RXX0hjL4=;
        b=UA4muo+ssqOLAGgzzATTUalc03x3Fq1Il8d7TQ6F/DAeNDTTfAszpI/kZysYRcAvIR
         WDReJFTqufDKB9Y5XQkkoQgONBQbzBhejn7le2cb7DFctnuElP/nDP40tCY8N5GDuu47
         G6Uw/oKv5BqwHIghUJ2hmGgfuWIQKO2dGLikmf5kBbFzEwltvnbG7pW746rEsJrjokrW
         EISeQB5PEYQM6BAsM3niEP8MpfMC4LYEttZfMOadyx39WOcvn6NXrIsmkfqC2GLs73XR
         mJ5dFkakFd2vsxvlL8215G6xgJzWgl493U+0oCB5Hm0NxXI7v+b2RfxQqrjU50RFIRJN
         Xnpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tSgjerC4;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w65sor4944095pgw.5.2019.01.30.19.04.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 19:04:47 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tSgjerC4;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=9UKheLNLSM7085+hYajJxzL+Wpldb3TOma8RXX0hjL4=;
        b=tSgjerC4dK44S06W0OSTr53cNg28+6cUTE4HzPUKTdkevWVpDJ97JFTp+cPosrPNEV
         D8rphH0u8PJiDjdQsW2TNjafYIBoOsL1lTpSoOkAZyJOLs4Vo+jTdmYEwU7Jl7hXgk8u
         bhAoeiu1BDGFLMWPAWbdszIxVsMvwVSrmn9/NbkQyumWfBx94sOwPfkrdncoz+vMpmLN
         GvJIbeBoL5m3lTrGsdAHY7E5Ffo5FQtSCX5JwL9a+t7uCBTkj1fO/HsLuTpU2zXaDEU3
         Ob05VCxwKCGE7QtPagY4Sd1s9LT8xNY41xJLt1okURF5K+hRbPJY9tnqbjP0VDuMbxqy
         h/+Q==
X-Google-Smtp-Source: ALg8bN4FchuqbyYG65Y851K8FAAMbykpYxvta9bA6d520FyHakM49c32bL40WPlrtGU5T7jPX/J4QA==
X-Received: by 2002:a63:7c6:: with SMTP id 189mr30429168pgh.129.1548903887364;
        Wed, 30 Jan 2019 19:04:47 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([106.51.20.103])
        by smtp.gmail.com with ESMTPSA id o13sm4055072pfk.57.2019.01.30.19.04.45
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 30 Jan 2019 19:04:46 -0800 (PST)
Date: Thu, 31 Jan 2019 08:39:00 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	linux@armlinux.org.uk, robin.murphy@arm.com, iamjoonsoo.kim@lge.com,
	treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org
Subject: [PATCHv2 2/9] arch/arm/mm/dma-mapping.c: Convert to use
 vm_insert_range
Message-ID: <20190131030900.GA2284@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 arch/arm/mm/dma-mapping.c | 22 ++++++----------------
 1 file changed, 6 insertions(+), 16 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index f1e2922..915f701 100644
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
+	err = vm_insert_range(vma, pages, nr_pages);
+	if (err)
+		pr_err("Remapping memory failed: %d\n", err);
 
-	return 0;
+	return err;
 }
 static int arm_iommu_mmap_attrs(struct device *dev,
 		struct vm_area_struct *vma, void *cpu_addr,
-- 
1.9.1

