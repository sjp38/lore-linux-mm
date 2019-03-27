Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D2F8C10F00
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:02:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D80B217D9
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:02:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="lWz3fb6R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D80B217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC0BA6B0008; Wed, 27 Mar 2019 14:02:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B73AD6B000A; Wed, 27 Mar 2019 14:02:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A118E6B000C; Wed, 27 Mar 2019 14:02:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7B16B0008
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:02:52 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g1so13848934pfo.2
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:02:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oshVF3pnS80y9kU1Xv9q7KmogsfX3bUL924jNqzFaYY=;
        b=MQFyLGSSglTcE9JiStMj9nEXzOmcF6e/S7/J4SYUYVcffRJnST0ESqll8tQRQtwGJ+
         U4kK7BPclECl7n+wh2wJNEWYj4EFfOfP6XVvx2iX8+P1eg1N+rG6jRiC5g8KhzfyY0kR
         4E5xjLmBWkcO/CYpQkQqbi0QkZD+k0Sj3MSNfFsuWCIF79kZMgzG3ltF3/Znk6HaFjok
         Zwnas+gbWuTqrQGU6LBGvOLbWCAGufLgPqxnPslZwqH9FQ8ek7I7RkPZoYMMVsmdPDao
         M71VvqgQnYZeGZwC8GTi0OotojmxkJLpUVVN9JW3TdCsOGNqRvxr2eUkBKWaGrzhU/Ul
         r9MA==
X-Gm-Message-State: APjAAAVUmZmX7ly8VUtIEeFbLpXB7gIvwtflTddHxRy1FhrNF0Nbj3AR
	994cCQB6xT3LZkOTIarmZPYM4qT+RfWWNQ9cMV7qKmITQsGZ8eRbQ9Nd83Jh8E0BstZGhdIUVOy
	8bWTGuE2eCAyL9EgCNlN+0CJ9C09BGFA0omWCqHGpyXRHzrhNlUvnNv15oH3I0v9i1A==
X-Received: by 2002:a63:190d:: with SMTP id z13mr35213334pgl.432.1553709772052;
        Wed, 27 Mar 2019 11:02:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwCMWBmnMTtTNH3qxDuTGkbRz7PtKd0kNW0NjsmXzQAfhakmosgdasB2EByiLHdqajDnz8
X-Received: by 2002:a63:190d:: with SMTP id z13mr35213268pgl.432.1553709771349;
        Wed, 27 Mar 2019 11:02:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553709771; cv=none;
        d=google.com; s=arc-20160816;
        b=MevkL3voWxLd48I7rKtUJM1uIsPnvnCGH7yDJPCmwxdsAtUFscCuk4Cm634r3lYjZ0
         LB2IPo50cYU1d9z6S2eY3G3vdv8B/wASX7RCidsgVri0iY6KQksydJHdZC+3RyJQRTh2
         lJ/5jxVJzSOmlNLXQMsi32rJPxmwW5M+3pl/SQ8MTRn3Yx1QkfsM8RMzdv2u0DwiLLXp
         LD+M8R2JVmR2URGHelg717pyinY9x1A00Dh0dvs5NDgNUEPEsi42RbYXO3HDxbBjR4z0
         rXAre0euCbKL4PABDY2zTMkwqVLvZtT+q6uHKvBBWHM9igl/7o40CzZJqDTjUpzOsIu+
         1gOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=oshVF3pnS80y9kU1Xv9q7KmogsfX3bUL924jNqzFaYY=;
        b=UNgIJpRNjkeUF9N3ptJOsh7PCE2Q+22ZiNbx0LFM/ozv0+BV0olMUkovdnZmR2xNSz
         5P4NR83qOU+FiP8jU7QHorp/xCirxLHdMoHT079BXhF6iSvBjSfJalIgIMeEOqdivSXC
         mRA9fhBRYaE+aBVu5vuzRx7khR9F9s6ddKnO2svcvdHOu0gF+DAimXUf6f6b6cHlIJA8
         dYSEerBDjOhkCVxmXz6bB3tF8uPyOx0Xz0FAzxqJZ6O/tdVuIURvzMXSSd3J0Ccmf3zC
         W26ItN89H7T3e+doYaOfZmR+XBsg76x3PNlHBZVO76ZR6BRRpDkiec31aV1HeftO0DP+
         iJNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lWz3fb6R;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f36si5296506pgf.332.2019.03.27.11.02.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:02:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lWz3fb6R;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AA0742082F;
	Wed, 27 Mar 2019 18:02:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553709771;
	bh=VmNGT9gWdIwRpvfBryTTHeFlhfr4c6tuu743yAtQCJM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=lWz3fb6Rbv9F1qvi/uEXlWtWQpWXQnRHYTDiM8f8+S5SCs8GfDPZ6/61HXpM+GW/T
	 IKCEiz7zl3vbSENbqPD5ijCLEE7GhXySM7eJzEM3iw6/sw4htiAadayHOfeOYM7bAm
	 4LWUHIkltljvSi6bt7vwr0W+oZ1O6qq9y4f+gwBY=
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
Subject: [PATCH AUTOSEL 5.0 031/262] mm/cma.c: cma_declare_contiguous: correct err handling
Date: Wed, 27 Mar 2019 13:58:06 -0400
Message-Id: <20190327180158.10245-31-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327180158.10245-1-sashal@kernel.org>
References: <20190327180158.10245-1-sashal@kernel.org>
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
index c7b39dd3b4f6..f4f3a8a57d86 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -353,12 +353,14 @@ int __init cma_declare_contiguous(phys_addr_t base,
 
 	ret = cma_init_reserved_mem(base, size, order_per_bit, name, res_cma);
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

