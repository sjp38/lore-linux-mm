Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EBACC46499
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 11:48:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C943120828
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 11:48:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C943120828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70F746B0003; Fri,  5 Jul 2019 07:48:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C0968E0001; Fri,  5 Jul 2019 07:48:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E2D66B0003; Fri,  5 Jul 2019 07:48:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2586A6B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 07:48:05 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n7so5456949pgr.12
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 04:48:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=JFd1Kz2TJ1yvQTvTPTXYIKVaXBPBhmDUTcvkrBOYdqc=;
        b=f+J4Fx+96paBYXCNobVzGdYEN+gWLEYklZ7NzDVToJgUSgU0WHge2BsmFtGXvGHzJV
         BaasKIcqHFj+aO2OMUT21/ANIvWycACgtnmPGdxpD6VyX02iv/oK7sPRqWorNpLi0qR3
         W3sc4sLIcsvdXud+Obt6AXxtkKmvNV8MC6YzeUUHmciLcaR3eob9WGn3xvfsxH45puAs
         9xVtkE4pWJRm8+YulTdt4T1qPZFdidwTol+hci9HwKMVLZ5af53SrynJi5gckJSim3fU
         kddi0nIlZlqYpwOjXKU3lHBzQWztPvAjGkjMNdvVkZatz6EZ0DmUYanmgFwZv2h/fFF3
         6OUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lecopzer.chen@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=lecopzer.chen@mediatek.com
X-Gm-Message-State: APjAAAWoTy3n3y8Q8Z0Sa2kpyv7J/iFUL4aW0iPRiIk4Ewuzf/ozchHW
	pd3TKYCj6Kw8H40DunnuEHTR8utCfHfa1AspeAQUGxAUtpE4V/0m1Cu7lccTmwee/Fqz7x3vjOK
	M4eniQiSZ663Q0jy9JAK8rnBQRO4KL2tTS2jMrodeCpM3ufRxaUES9Bk7md8pgmyIXA==
X-Received: by 2002:a17:90a:1b48:: with SMTP id q66mr4887894pjq.83.1562327284752;
        Fri, 05 Jul 2019 04:48:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIyt7JD7nKiyfKwYavWKVFnjvm6YAEo0QLP/148GhTA72ra/4VzsvWpfnvquMWZH470lpg
X-Received: by 2002:a17:90a:1b48:: with SMTP id q66mr4887771pjq.83.1562327283510;
        Fri, 05 Jul 2019 04:48:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562327283; cv=none;
        d=google.com; s=arc-20160816;
        b=UUsCphYS1AD7bqUJudMhYHN6ADBARMlzicF4pS7uQNZoTwot9J9oRPUBYD/kHCbvI3
         yvsX3g10XIPz/CUOtGlChxNBdOY+r+ZHdnvWEFUlUPepDFhQda3S7H4eVgr8K/N2UlDB
         AP9qLPNgiKU9ZKLvFQXsQrIm2rjnz+nSuBQnLs9PnCePUyRmprgrarmzCwmC4Phmgsre
         542hmbAqu9QxMQ/7h7Lyr7jb+AWPenRY6cl5eGfgDxyh+JYJYaje2ISR516Kbm5s92qI
         VTNMLNINdwa6K7trzd2bZIUi/SOGRX7VUOoEFbWDa7xrrUlrcCfBgIlMXY/3vo141luE
         23Lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=JFd1Kz2TJ1yvQTvTPTXYIKVaXBPBhmDUTcvkrBOYdqc=;
        b=djwxcMJ5Oan1l9SA3bn9iocCGs5qYCF0kvvD44xqUTIYlJwIF15/lb9FfgdeRB0NwE
         4JpXOrzwsjqkX37Gr90WkgSP/ycvS4h0jhwRwHXUPnMsbGtPfbunWgmvSdcFhO4g5GsW
         4nuw8qL/3XaT70lScDuwPeWmSgFkBgdyZzUQ71MIEVsIANp/AYqMmtVSVhq4UrgbZCz3
         CK0/1axjzV7C6QjAPcOwuGwpDZBF6P6jnS/HzLlIulthtgdvVC55HSrtHkO5r6ibizLJ
         KISetsgYBkJ2dr32JlIeK6sgZMFjtvO9WQNci6grSo1HiLQs3iJg4XkVtXkS6HyeQVLy
         6J0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lecopzer.chen@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=lecopzer.chen@mediatek.com
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id o30si9189256pgl.575.2019.07.05.04.48.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 04:48:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of lecopzer.chen@mediatek.com designates 210.61.82.184 as permitted sender) client-ip=210.61.82.184;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lecopzer.chen@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=lecopzer.chen@mediatek.com
X-UUID: 52c8e7680f8e49a59d113a524c37eb73-20190705
X-UUID: 52c8e7680f8e49a59d113a524c37eb73-20190705
Received: from mtkexhb01.mediatek.inc [(172.21.101.102)] by mailgw02.mediatek.com
	(envelope-from <lecopzer.chen@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 1234003082; Fri, 05 Jul 2019 19:47:52 +0800
Received: from mtkcas07.mediatek.inc (172.21.101.84) by
 mtkmbs06n2.mediatek.inc (172.21.101.130) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Fri, 5 Jul 2019 19:47:51 +0800
Received: from mtksdccf07.mediatek.inc (172.21.84.99) by mtkcas07.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Fri, 5 Jul 2019 19:47:51 +0800
From: Lecopzer Chen <lecopzer.chen@mediatek.com>
To: <linux-mm@kvack.org>
CC: Lecopzer Chen <lecopzer.chen@mediatek.com>, Mark-PK Tsai
	<Mark-PK.Tsai@mediatek.com>, YJ Chiang <yj.chiang@mediatek.com>, Andrew
 Morton <akpm@linux-foundation.org>, Pavel Tatashin
	<pasha.tatashin@oracle.com>, Oscar Salvador <osalvador@suse.de>, Michal Hocko
	<mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>,
	<linux-kernel@vger.kernel.org>
Subject: [PATCH] mm/sparse: fix memory leak of sparsemap_buf in aliged memory
Date: Fri, 5 Jul 2019 19:47:30 +0800
Message-ID: <20190705114730.28534-1-lecopzer.chen@mediatek.com>
X-Mailer: git-send-email 2.18.0
MIME-Version: 1.0
Content-Type: text/plain
X-TM-SNTS-SMTP:
	B5F96B9A41F2DD2F8286049F36ABA0FB5319729559A93CF5867822CD45F83C7F2000:8
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

sparse_buffer_alloc(size) get size of memory from sparsemap_buf after
being aligned with the size. However, the size is at least
PAGE_ALIGN(sizeof(struct page) * PAGES_PER_SECTION) and usually larger
than PAGE_SIZE.
Also, the Sparse_buffer_fini() only frees memory between
sparsemap_buf and sparsemap_buf_end, since sparsemap_buf may be changed
by PTR_ALIGN() first, the aligned space before sparsemap_buf is
wasted and no one will touch it.

In our ARM32 platform (without SPARSEMEM_VMEMMAP)
  Sparse_buffer_init
    Reserve d359c000 - d3e9c000 (9M)
  Sparse_buffer_alloc
    Alloc   d3a00000 - d3E80000 (4.5M)
  Sparse_buffer_fini
    Free    d3e80000 - d3e9c000 (~=100k)
 The reserved memory between d359c000 - d3a00000 (~=4.4M) is unfreed.

In ARM64 platform (with SPARSEMEM_VMEMMAP)

  sparse_buffer_init
    Reserve ffffffc07d623000 - ffffffc07f623000 (32M)
  Sparse_buffer_alloc
    Alloc   ffffffc07d800000 - ffffffc07f600000 (30M)
  Sparse_buffer_fini
    Free    ffffffc07f600000 - ffffffc07f623000 (140K)
 The reserved memory between ffffffc07d623000 - ffffffc07d800000
 (~=1.9M) is unfreed.

Let explicit free redundant aligned memory.

Signed-off-by: Lecopzer Chen <lecopzer.chen@mediatek.com>
Signed-off-by: Mark-PK Tsai <Mark-PK.Tsai@mediatek.com>
Cc: YJ Chiang <yj.chiang@mediatek.com>
Cc: Lecopzer Chen <lecopzer.chen@mediatek.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org
---
 mm/sparse.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index fd13166949b5..2b3b5be85120 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -428,6 +428,12 @@ struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid,
 static void *sparsemap_buf __meminitdata;
 static void *sparsemap_buf_end __meminitdata;
 
+static inline void __init sparse_buffer_free(unsigned long size)
+{
+	WARN_ON(!sparsemap_buf || size == 0);
+	memblock_free_early(__pa(sparsemap_buf), size);
+}
+
 static void __init sparse_buffer_init(unsigned long size, int nid)
 {
 	phys_addr_t addr = __pa(MAX_DMA_ADDRESS);
@@ -444,7 +450,7 @@ static void __init sparse_buffer_fini(void)
 	unsigned long size = sparsemap_buf_end - sparsemap_buf;
 
 	if (sparsemap_buf && size > 0)
-		memblock_free_early(__pa(sparsemap_buf), size);
+		sparse_buffer_free(size);
 	sparsemap_buf = NULL;
 }
 
@@ -456,8 +462,12 @@ void * __meminit sparse_buffer_alloc(unsigned long size)
 		ptr = PTR_ALIGN(sparsemap_buf, size);
 		if (ptr + size > sparsemap_buf_end)
 			ptr = NULL;
-		else
+		else {
+			/* Free redundant aligned space */
+			if ((unsigned long)(ptr - sparsemap_buf) > 0)
+				sparse_buffer_free((unsigned long)(ptr - sparsemap_buf));
 			sparsemap_buf = ptr + size;
+		}
 	}
 	return ptr;
 }
-- 
2.18.0

