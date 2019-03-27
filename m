Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FEA0C10F06
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:25:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D66BE2177E
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:25:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="fctj+U6L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D66BE2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CB9D6B0292; Wed, 27 Mar 2019 14:25:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8514F6B0293; Wed, 27 Mar 2019 14:25:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F3B66B0294; Wed, 27 Mar 2019 14:25:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2CE5F6B0292
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:25:29 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h15so14616449pfj.22
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:25:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4lfeKdpeHnNE8aCiHVhvadGn1yHYtDb+GjA+BNmQkBM=;
        b=b9zHwRS0V2ocaQ+yz96vDwal/lOCOwMbfpwIUXBsYMVOItuLG7Oy3yVFDEDOgzYlei
         JY4IwDQ98OJzkygYRCH/ZZdjWqN6S8Zu5lz+puv99Vskb6bmS2eUuAihMz3ck1dYDi0V
         qNsIaQ/ijHjEKf8ctGPI53sa+ObXjPF0oI/k/hMdX06mAQvvK9Wauufs9agL4q24fx3J
         iyf9wrK0WxwKIMhXvfTVa/2oRZW0N8JjZB/q7iK5j1WfC1USBmbPIgdGUSfqLoycZxna
         bGq2+qlbMiz2vA6+wkU3r881vssC86j5zuY4NO5pM2UbSIPMorT0wZLyk5cUsHAC90wJ
         QjSA==
X-Gm-Message-State: APjAAAW/yTRceKxCPRKhKJjJBe4B1pxxZ9ycLyYlz63IGzRO9wYnWSD4
	3wJnkT2eN/cMd9W2QRmpq0kL1ZdLh/N0LnQUxg0LbdBAU+dgwSx6FOKEs28iN1Becs9fZQgtKOF
	dGejHheGlIhEw1dsN2gAmmiviDpcvCX2hjCkcVdzbTg3ubpui3VxgRsuUPKDdwwOvUA==
X-Received: by 2002:a63:d4f:: with SMTP id 15mr35929750pgn.162.1553711128846;
        Wed, 27 Mar 2019 11:25:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdoVJxk9GxhbiQdYj3fgNw6AwB41HDpWDFtQg08fym7ZhDe64VJbA0PK+VTQX7zrxEOcaH
X-Received: by 2002:a63:d4f:: with SMTP id 15mr35929711pgn.162.1553711128236;
        Wed, 27 Mar 2019 11:25:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553711128; cv=none;
        d=google.com; s=arc-20160816;
        b=IROOGPt2+yeBQreuiXbUCPqTdsqaVwjNANMga9H8NicyEmAhggrLNHjix1LT1aU0V8
         d3sHTjTPWRRcbfuddpsJoAykOZR3u4sLmID5FiqpsRl1lysQrl+2vrN2AeS9GgSdXWae
         JGs+ItuW3YuV2fT7DKEZW2SfjFGFfO6xOjNjYsOzqg/K+lAGEEceq/QfuniRPmsEGTzm
         pQ9Svdc1W62zJA0+UVLOfeOtp6wRVs3nL36Y0xBSe4h9CtJpbsQKGeVHbtQElWZmv3Sr
         izOjclz+NVeWFqy0iSpxIXGluVdFXyQz3dmZZi5eYKSNW1pJtSMEc/0jbOZGBcwYPaEC
         wGuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=4lfeKdpeHnNE8aCiHVhvadGn1yHYtDb+GjA+BNmQkBM=;
        b=O4RWjq1zppC7/9Uz3ZbNKovB+6VFCHojGcjUe8uWSVeSGcsSl1URaRxQtAY6F5mkI4
         G9rbS5DdMcA/pXNsIqvDvagw2k+Caw0Mh9dHh/Gqp6AyCo4TM2bsuBAFzu7h3TtOhSn7
         RBoHvBMG7F0Q3PQ2qUD8xM6JCJzd98YSRWoafNBea1AjMK+3i8EthwtIf2+nGd9Mg9wu
         hQZIX2Mm0sUMuGYoLavmSixNGZgof6Sp7uFo9p4L81AkKTtJJkiR5cTU9mfvn3O1vUN+
         0oFedLjCq6gcMssVLHBKzKOSAjmyrXHV3KkhUN9qYDLowPLS2hIjGLp1/pmm0tc/WFRe
         DIXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=fctj+U6L;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u31si18758403pgm.352.2019.03.27.11.25.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:25:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=fctj+U6L;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8F26521734;
	Wed, 27 Mar 2019 18:25:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553711127;
	bh=s0jlfuyPxKB8w3OrmRUprC9URENN0chCNNDEug0VH6M=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=fctj+U6LZbUpsbvyj8CQ0hDFEs7WefnuLDHwN6w8YijO0WwvA9G4+Ez/wOh4ao0Nf
	 3uHgu5O4xKxqb6SX9WlBNSojWQu0AhES7cmBVDE6HjKuv1N5p72D0/YYwcP5hb7jNe
	 fwhGdFf8L7TBzRrxpAi27rdvvnfDxmUnoCcizE98=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Peng Fan <peng.fan@nxp.com>,
	Laura Abbott <labbott@redhat.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 3.18 04/41] mm/cma.c: cma_declare_contiguous: correct err handling
Date: Wed, 27 Mar 2019 14:24:41 -0400
Message-Id: <20190327182518.19394-4-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327182518.19394-1-sashal@kernel.org>
References: <20190327182518.19394-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Peng Fan <peng.fan@nxp.com>

[ Upstream commit 0d3bd18a5efd66097ef58622b898d3139790aa9d ]

In case cma_init_reserved_mem failed, need to free the memblock
allocated by memblock_reserve or memblock_alloc_range.

Quote Catalin's comments:
  https://lkml.org/lkml/2019/2/26/482

Kmemleak is supposed to work with the memblock_{alloc,free} pair and it
ignores the memblock_reserve() as a memblock_alloc() implementation
detail. It is, however, tolerant to memblock_free() being called on
a sub-range or just a different range from a previous memblock_alloc().
So the original patch looks fine to me. FWIW:

Link: http://lkml.kernel.org/r/20190227144631.16708-1-peng.fan@nxp.com
Signed-off-by: Peng Fan <peng.fan@nxp.com>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/cma.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/cma.c b/mm/cma.c
index 7d266e393c44..1f4a7e076a5c 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -340,12 +340,14 @@ int __init cma_declare_contiguous(phys_addr_t base,
 
 	ret = cma_init_reserved_mem(base, size, order_per_bit, res_cma);
 	if (ret)
-		goto err;
+		goto free_mem;
 
 	pr_info("Reserved %ld MiB at %pa\n", (unsigned long)size / SZ_1M,
 		&base);
 	return 0;
 
+free_mem:
+	memblock_free(base, size);
 err:
 	pr_err("Failed to reserve %ld MiB\n", (unsigned long)size / SZ_1M);
 	return ret;
-- 
2.19.1

