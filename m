Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32962C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 23:13:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2FE9218AD
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 23:13:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="bsfGy1P+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2FE9218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A15648E0004; Mon, 18 Feb 2019 18:13:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C7CC8E0002; Mon, 18 Feb 2019 18:13:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8197F8E0004; Mon, 18 Feb 2019 18:13:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4FAE78E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 18:13:27 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id i186so1273683ite.8
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 15:13:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=V1IdqbYubtCixESl5TR0muUvkg/E2O8mQvzM202vMJY=;
        b=Q2/hm4yQZXbAVQQ0foHZhAqo8TfBMlc8R1NAbKk/onb0U+tPYFAzabPE7L5HfbXx50
         Qo22TxQjTQbmEMDezvZueoggjXyLv7GYp3lo50ZKT85Q6ZTSy6NxNgpVAt5sTdJf3YGS
         +ycVRlbBR266ssS2P/ip1Yxm7MYjitYwgdj5bYzpMqyeLYLfdvuLgp38bR35b1DapB/O
         byUb3q3ZM4jB1KIG/5iyZDeBtqjItvwt4UHCmCZPp2NvHZAYqm7VbDI5h+NbO0ZZvoH+
         U/Eo/dw4rPamzVh44eV8v8J470L3jx/JGI6S9zSv6ZmfcE4794j++IUeqrm8WIHTvb7v
         0+cw==
X-Gm-Message-State: AHQUAubXq6ue6Je5x8ZtBSs+AsQQEOE5N7H0amC7SjImtJz8ZGvfNqFd
	5ZyDPd6oPbA2887xLdDjY3yx/ihpjSQV+LAOPFuVA7RpzB6MTEaJHBpa1hH90AZTV5dTX6GT0Dn
	guMO5ZSSijzgJ9SrYGgWelRKZNPQjvm4NXHbs/PKls0qIYeCtB6z3TnuZAGXpb4B+rKWvUnwtbD
	yCF2jHJzXnZnWWEG0jy3mxb5K9scDyAWlU81dOvQY3sxl9oLfOc8HHUg9uoEh6ix7ssbA/TW4qU
	Wgg9q0atRMFOX3sbh4PEwkJuOHnysKTvlveed7b4PM8+thK/ZdqC8XZHba+iEizRlPrsH0g4+ym
	cyAevZcz4wgfPFTmd/3Wln8Mx1aZe/ZJ4sX4UHUIIHNno4dFEI7aOjl1o3WcWqUYkg+CV6OHkDg
	P
X-Received: by 2002:a6b:e810:: with SMTP id f16mr16922921ioh.194.1550531607094;
        Mon, 18 Feb 2019 15:13:27 -0800 (PST)
X-Received: by 2002:a6b:e810:: with SMTP id f16mr16922896ioh.194.1550531606551;
        Mon, 18 Feb 2019 15:13:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550531606; cv=none;
        d=google.com; s=arc-20160816;
        b=JJ9Fpwg0uERHQxKYC5uueUx7MoEH4o7GHY9YVA+v9TaFCQ0J0utl5tP0HYN7f6MOuI
         LHeDFYoVwAJSyc7SFnebbNyIhP0Fqz0siuls/FXrSCnLfIelnUSmTcuIE9sVszaMbgTa
         oDnMczixkTCFZGKQoSKZM/zMlQtJAUb+yi9jlO31Q3zFM0Lq6r03RFQAFeVSvPe+bYjW
         Zf7yViQ7nZp2QaNkx+eLpYZ4rtNQSinLE7Ys6tM/hT3amLeVB3vveUWfHq/wEnT/h0ap
         kdqItyPqpIQ5JJX6SDb5reqi3yOKGIUX+XxvhKea1ZQOmcYDZc2/g9+J7IC5ViN0Ay1o
         i0wQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=V1IdqbYubtCixESl5TR0muUvkg/E2O8mQvzM202vMJY=;
        b=VaRY5Oltd4uJonZNBY94VYbgz59R3EkyOIlks7gurEPxn1OaC+b5K+774KFbz6BXko
         ADTPiA5qevg1WiPxGNN6MjKXYFAXluVK0VjZ6wJv6aq2gXM/XQCakiSYJ3Psk/e2HaB/
         ecTtCxrRDqBfTMQEni08B7CFepBLhdr1NjTW7i7XGYdD+a0/YYERLwWZLmClWgKlmXlS
         LCNp0E3JDZnzm93K+x7SwK1snOefuoE67VmRW1NZdVASOBoMwMqUl6+qdfRECTyPGph4
         Z9P+HjjaXTGcbkzDYLVzbis/0ADHg2TjKwWAQHNofYToa7nZGt6gM2Rkrxm1k9IiyaO5
         9+Aw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bsfGy1P+;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 68sor1232954itu.24.2019.02.18.15.13.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 15:13:26 -0800 (PST)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bsfGy1P+;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=V1IdqbYubtCixESl5TR0muUvkg/E2O8mQvzM202vMJY=;
        b=bsfGy1P+JAaNzK2xsZmC2Tj104zGh/lur1QTBqvenBJ2/qYq2g/zlrWxNZQtQfM35p
         SvHcbH51aav58mTv6SC3r+eXafQV/q2wT7dySMfLdYtqGwd3IU4BO5OncxK0Sc1m+fIj
         nQfKurxrxsrekUV5Engn2LJyRILWrYvwJyz5n0SWzgddARHKb325HaCw91Il4vDU1Zx/
         mk9/PYlyIFAHhkP2hr5znpaOUFZOUpl6KFCa/NcBzVtwHJoN4RB7/T7YpN2vbUZpYTCL
         LQgIbfhf2ht7PVFcOoXfG78S2gMcj0aiK0WoV3lEAuUhwncWxtNbknbhAN1dIFxSI790
         gxtw==
X-Google-Smtp-Source: AHgI3IZT6Mu4hL5CdKV5I1EiL7aKLnA6dLePkX8jtfw/N38Liese0eXKCRasVCtk+AF0ZUvijxlkeQ==
X-Received: by 2002:a24:7d88:: with SMTP id b130mr796701itc.163.1550531606189;
        Mon, 18 Feb 2019 15:13:26 -0800 (PST)
Received: from yuzhao.bld.corp.google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id x23sm6541463ion.38.2019.02.18.15.13.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 15:13:25 -0800 (PST)
From: Yu Zhao <yuzhao@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <npiggin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Mark Rutland <mark.rutland@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Jun Yao <yaojun8558363@gmail.com>,
	Laura Abbott <labbott@redhat.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org,
	linux-mm@kvack.org,
	Yu Zhao <yuzhao@google.com>
Subject: [PATCH v2 2/3] arm64: mm: don't call page table ctors for init_mm
Date: Mon, 18 Feb 2019 16:13:18 -0700
Message-Id: <20190218231319.178224-2-yuzhao@google.com>
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
In-Reply-To: <20190218231319.178224-1-yuzhao@google.com>
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218231319.178224-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

init_mm doesn't require page table lock to be initialized at
any level. Add a separate page table allocator for it, and the
new one skips page table ctors.

The ctors allocate memory when ALLOC_SPLIT_PTLOCKS is set. Not
calling them avoids memory leak in case we call pte_free_kernel()
on init_mm.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 arch/arm64/mm/mmu.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index fa7351877af3..e8bf8a6300e8 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -370,6 +370,16 @@ static void __create_pgd_mapping(pgd_t *pgdir, phys_addr_t phys,
 	} while (pgdp++, addr = next, addr != end);
 }
 
+static phys_addr_t pgd_kernel_pgtable_alloc(int shift)
+{
+	void *ptr = (void *)__get_free_page(PGALLOC_GFP);
+	BUG_ON(!ptr);
+
+	/* Ensure the zeroed page is visible to the page table walker */
+	dsb(ishst);
+	return __pa(ptr);
+}
+
 static phys_addr_t pgd_pgtable_alloc(int shift)
 {
 	void *ptr = (void *)__get_free_page(PGALLOC_GFP);
@@ -591,7 +601,7 @@ static int __init map_entry_trampoline(void)
 	/* Map only the text into the trampoline page table */
 	memset(tramp_pg_dir, 0, PGD_SIZE);
 	__create_pgd_mapping(tramp_pg_dir, pa_start, TRAMP_VALIAS, PAGE_SIZE,
-			     prot, pgd_pgtable_alloc, 0);
+			     prot, pgd_kernel_pgtable_alloc, 0);
 
 	/* Map both the text and data into the kernel page table */
 	__set_fixmap(FIX_ENTRY_TRAMP_TEXT, pa_start, prot);
@@ -1067,7 +1077,8 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
 
 	__create_pgd_mapping(swapper_pg_dir, start, __phys_to_virt(start),
-			     size, PAGE_KERNEL, pgd_pgtable_alloc, flags);
+			     size, PAGE_KERNEL, pgd_kernel_pgtable_alloc,
+			     flags);
 
 	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
 			   altmap, want_memblock);
-- 
2.21.0.rc0.258.g878e2cd30e-goog

