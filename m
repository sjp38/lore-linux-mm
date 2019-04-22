Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0C26C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:00:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B43612075A
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:00:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B43612075A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C02B06B0282; Mon, 22 Apr 2019 15:00:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD5616B0285; Mon, 22 Apr 2019 15:00:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DB0C6B0283; Mon, 22 Apr 2019 15:00:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 40E6D6B0282
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 15:00:26 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c64so8126975pfb.6
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 12:00:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=vrkYcNOiqWdKT5EnvOrVHGGI0BGyhk1VWyHkq9CBPjA=;
        b=Tr44IoPH4/5xR2lWA4QMViBebDUoo7bQE58m63MkKJqcFm+jYefWWwKwHfYy+wCdJJ
         wEonUqREBx05sN8nApYlxjUhsnAmIo3f7YqiH9JxgpUAVqkeY2xO6Bh25QeKi91b9lAC
         smZbSv89tg0UUfWU0mcxpb5qnLCka3YvGq9lptVsguMzVPb6ld8ubah1Rr11gp+nX3AD
         5NCqEf2PLXIBTBQSwS9/sanag/0ZmrPbwREbKP0dcnO+02yZbESsvI1+bJvIDVIOG7Pa
         VzDx8HW+6vr6VVvTw7L9Lh4WYO247GmdcU9g9+Woe1S4ah56ebZeHbaftwNTsGk1FKRf
         zmSQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU9XNVfcgfubsXDX25DCi/re0fE4whaan8TdO0A0GErUD1J4JmR
	dCd+oAxLKdI0fsLcCAByhrnUICwQNka6/qg0DFhtSNTbO7kB+eSHnNArlDbW7fPbsfH/xFQnOEs
	tn+XD60SOHD5GhPgkGr/n141fF3Bqs1FRBmouONdSBPODD5hmX464ZdzZWuWN+UmwwQ==
X-Received: by 2002:a63:4b21:: with SMTP id y33mr20933293pga.37.1555959625934;
        Mon, 22 Apr 2019 12:00:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYe+7nx5RX/Yp9g5O/G5o4nzZzhgco8JVsrt7cupWlIJ5x4AHJ6HzTr7P81laXYMZREH/6
X-Received: by 2002:a63:4b21:: with SMTP id y33mr20926173pga.37.1555959524391;
        Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959524; cv=none;
        d=google.com; s=arc-20160816;
        b=bDK1VL8TEfCf6CdiK/g13iZfeBLHHoYx9LXqB6Afk2ANbcjscuS2mEYqk8z6/T32N4
         J5N7xqEtSYNOwaN0aPJpK8FkGgfWDUCJpU+HpKSnw+PzH3opLngfKvYUFhCynVB4ETd8
         GelC+Tm6hNKvgK+chWf7lAYfps+b3nCDLiCTkeSjxXXBN63H9s9eF0J8bNOkMzkCx8Dz
         LszLiUiwzDlTv4g68EYI6Tu2lqTlkNbVNQRzDk4sUQNeafqXv4Q8zqwHTdbg0BlQEk6p
         yHocknzYe9Gho+jf1Bt9ewaObKjQqraeJVpOMIE7HauRVAYBxL0tqraMTr613en/4qDy
         tbRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=vrkYcNOiqWdKT5EnvOrVHGGI0BGyhk1VWyHkq9CBPjA=;
        b=Aim0LC3XqKJ2bloKH3h3a696616dPXaciISWjuiNUljua0yqB/4G06Rx/R97gHzAqk
         9FsSxpyb3mZCzQSPdA8doyfx43ipi/iF11d9J/JbVlxxAwk8m6kmUdh9Snxi4uxsiKh8
         SBZtHSzWqm/n+VP8ZIG1UqM49ortx//goX2I6k5zPBhbbIK/Td78BxXeKmriguEBhgOy
         6e5vTb3hbtg/t3L2RMNhJhupzqvL7ZogJNBNTbJFqDIgGAd/dlS6h1OKC7h6JER6ybM5
         P0bwDCSWUwVhRXzHa6xjnFZhGqT6enBbpZX5BrLtLjE07vjUxFsYfwJDqVWYCY11x9ro
         Zxrg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id w15si615875pga.591.2019.04.22.11.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Apr 2019 11:58:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,382,1549958400"; 
   d="scan'208";a="136417176"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by orsmga008.jf.intel.com with ESMTP; 22 Apr 2019 11:58:42 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>
Subject: [PATCH v4 20/23] x86/kprobes: Use vmalloc special flag
Date: Mon, 22 Apr 2019 11:58:02 -0700
Message-Id: <20190422185805.1169-21-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Use new flag VM_FLUSH_RESET_PERMS for handling freeing of special
permissioned memory in vmalloc and remove places where memory was set NX
and RW before freeing which is no longer needed.

Cc: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/kprobes/core.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
index 1591852d3ac4..136695e4434a 100644
--- a/arch/x86/kernel/kprobes/core.c
+++ b/arch/x86/kernel/kprobes/core.c
@@ -434,6 +434,7 @@ void *alloc_insn_page(void)
 	if (!page)
 		return NULL;
 
+	set_vm_flush_reset_perms(page);
 	/*
 	 * First make the page read-only, and only then make it executable to
 	 * prevent it from being W+X in between.
@@ -452,12 +453,6 @@ void *alloc_insn_page(void)
 /* Recover page to RW mode before releasing it */
 void free_insn_page(void *page)
 {
-	/*
-	 * First make the page non-executable, and only then make it writable to
-	 * prevent it from being W+X in between.
-	 */
-	set_memory_nx((unsigned long)page, 1);
-	set_memory_rw((unsigned long)page, 1);
 	module_memfree(page);
 }
 
-- 
2.17.1

