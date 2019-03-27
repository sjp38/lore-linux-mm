Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 048DEC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:23:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC64320449
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:23:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="lhQGtHRG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC64320449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F53F6B0292; Wed, 27 Mar 2019 14:23:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A4CA6B0293; Wed, 27 Mar 2019 14:23:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5940C6B0294; Wed, 27 Mar 2019 14:23:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 202536B0292
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:23:39 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z7so10219481pgc.1
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:23:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YwBTBWxqdDgCH1DQmLZIzK/psIrF3TGXzKVhbLNl0nE=;
        b=BINMxNnBGU/F2f1oHWVaw3mZtIqZjMoIrR161hONCpssSso0mFI/7nCZQ1eg8YAbWi
         2JdQ0za76FDdapO9fNLy+95gnlpRiJhOkmEZnbPG53X4SquVt/nuE74dJWq88j13SDjR
         EuNfwSUpSf/uWI5T1+KcfvYF0lyre3ZgBXUNlTEDT/dUt0vYEUA6E78puYZxN+nXR/+w
         TepThZW0QKdTbHJjqlt3OdGiTmQESJESvXOTrci2keJmOY32+f3mbN4lsmrkZ+1KtwEI
         HmV8LyDlAGVm72kojU4ngydhhxix3zQ9rzA5HOMOdyHW9hmsKdSbaSmT5kpoPCLImks5
         jklA==
X-Gm-Message-State: APjAAAWYIGvWzz6c1DbhixXAu9Li59XIoBr3bzaYEzSwhzDzUOqVs0q5
	gO1s5fUohAqW9dW8A5yB2KM+wVubpaIJ1dCJVEtH/tQiODJ/84ns41bmEjTMViMtY/lVIdYF4s+
	37U1l2vA+e0QjfEXolloO4yr2Apb/T1xA/5b4QJ57fC0/kZh3ZftfplPJAVczRqQJ/g==
X-Received: by 2002:a63:5c5e:: with SMTP id n30mr35129091pgm.298.1553711018731;
        Wed, 27 Mar 2019 11:23:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/KjWTn6T3euSgysBZ33e1MXOqs4zIq7OG1eXZ+/PgdGuMt03/1cMt5qkL8b5C5U14+HnV
X-Received: by 2002:a63:5c5e:: with SMTP id n30mr35129038pgm.298.1553711018011;
        Wed, 27 Mar 2019 11:23:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553711018; cv=none;
        d=google.com; s=arc-20160816;
        b=uLYunUqO1bfAEdMjge9jsFTgcjAoP/LDgxByv0bAefqHP5/8INEuZb2R/+M5Cfw9r9
         s/jO/T2w8bIafsk6jskNnuO+j6JPFbrS9rQMn1zIX7nn/AtMmJrBU1hqqKpPS7dQSzmF
         UirOgS/K6YE2OegaSATFXJgkocb7K+j4lsCMyj4MZwaTbvZdpsR846BC7zCJEdVYb0bc
         3LKBuxWY6/4fj/oUQBuFC306mWjYD+FgJyOSGvCZSTayrnNAZ4bz85CT1JMg1ZvMqbG0
         I1Aijr37su6AvygWd0j8LeTRCz2xaorDtj1BpnwsxtHluKLZKKmxVRWlPWrnwusTlTkb
         Q0Ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YwBTBWxqdDgCH1DQmLZIzK/psIrF3TGXzKVhbLNl0nE=;
        b=VS70N6agTEAMEIFC/Zr59OHoNzJ9vkmNmfGb/sGErxyPRl2G485cnkpq0i/ticdQ96
         chpMCtuQaA9p/v0Rkps5Ph3borJyMbiMce/cKixEYM0iM5j6fhDt3DKHZ+zBXxWhLepL
         fmpSOHT/TYRq4jlOYPihDguzYPz4O6AGXfFj+Eengj7O1RvCUvIPm263gjAjB19pmVUk
         ixMh86WtKDwUZkTes+X0qqAYkkMPxeXw5IeV+vn+WnLHKe8RipFfSuGaESXI0BlJ4EI/
         C6OXCB/vv0dJNMwXc7j/iD7IgR/l9RQ49UCh7XhG8SxBZjuwntzUWvVfpIQ+JVr6sg/x
         eNbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lhQGtHRG;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l11si20277546plb.159.2019.03.27.11.23.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:23:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lhQGtHRG;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5553C2063F;
	Wed, 27 Mar 2019 18:23:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553711017;
	bh=xfPjTZbl0guBHbXrcyWt9wkOWvjJdbxsx62YRpHf9ac=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=lhQGtHRG9WIxZZJiiS/XrOZzo9iLllM+FNSvFo2TAaitEoMfLTMbpIqS6xwPAD4+a
	 sxTnmPuBHmUYIb4VCkcZQjScT/Lo6mG01bzdKB0Oq/ylZUfpfHqMLM0EOLIYEzSuxP
	 7Jc1Okzg9XN+Ew7+Putt4Kaw9Y6NUMcW0dubqE6w=
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
Subject: [PATCH AUTOSEL 4.4 08/63] mm/cma.c: cma_declare_contiguous: correct err handling
Date: Wed, 27 Mar 2019 14:22:28 -0400
Message-Id: <20190327182323.18577-8-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327182323.18577-1-sashal@kernel.org>
References: <20190327182323.18577-1-sashal@kernel.org>
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
index 43f4a122e969..f0d91aca5a4c 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -339,12 +339,14 @@ int __init cma_declare_contiguous(phys_addr_t base,
 
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

