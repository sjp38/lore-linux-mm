Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9507EC00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58DB22086C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58DB22086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 062298E0076; Thu, 21 Feb 2019 06:35:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 011878E0075; Thu, 21 Feb 2019 06:35:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1C4A8E0076; Thu, 21 Feb 2019 06:35:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8542B8E0075
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:35:29 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c18so11179632edt.23
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:35:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CXiwyxpsYbtktJw1JiQrFKlxs5Eu1bgqDSTeXz8tQMY=;
        b=URCacJ2xd9CRVm9iGtg7g9xP7TES/xD0Kr/P8Yk04gpszkJzcX1HXIQVBNNxtouAMC
         eTTVr2ZBf745aas44h2BIgmqAHm2SLdUPlpgKD3lnHAd88H+I2fyX465lNnQPBHjU5Su
         6GcA4aFeaMQKoJxEoFQIDJk8YCeoYGjHQIXPk8HYGCu2s8bmD7eBWGzzaeSiG+WWEKzR
         cOq0LrcEO1f+VuuTmJdrW/tBpCQSCxBkKjEEfAri8Nt3RmEhpwWcBGL2hXVaHTDHzqwB
         yhSrpxQpa6DV1JJIblOT6POGbRn6Hrs02wabpYaYpFmZrS+kddA9yaSbfI1IUdOPFQYw
         bSIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuahxXkAC8FtyWtulf/6oi7XjPI0LWtQk9s8NI1oTBLOhC4/jyCs
	wH0f3mW/6QMME2iCb0FrJv73WvCbEDif/+mDHBGciLB8u7nmL6KSJK2aKTzlo6hB8d88XOr4CGp
	3/6lWUBmomxmZem9wrIpX0BtaXl4P+hQn1aaCaRYirDkSMSmhVKFBuaxJ99c8p61WbA==
X-Received: by 2002:a50:f5ea:: with SMTP id x39mr28548977edm.154.1550748929040;
        Thu, 21 Feb 2019 03:35:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IayJYreM9rZSt5CGDg38IVAPURNqdK5Qbhu6oU9c9NX1xHVirgNlg9UectJ7pJtn30GeSoO
X-Received: by 2002:a50:f5ea:: with SMTP id x39mr28548920edm.154.1550748928047;
        Thu, 21 Feb 2019 03:35:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550748928; cv=none;
        d=google.com; s=arc-20160816;
        b=fCpbO+GcrbiIxi5GETKl8pLJjgSz6RIwPEawtaswGgrnFlbGt9o0PfF91JMQNKvIFk
         JzEiHeo/dj5ZnEtNAsqj2vtXw/mIebOSzES4aT6BV+4qT3F8RHGJJLV3ssiNlCkvnT5V
         Xqq7e9kgNEG1pqzH5bhxtnPcG6qH7X2kM3Dzz8bFf90SJ3YLYX/RO49pQV3CTr5AqoVL
         LNdcJ0qIWsE5CLNjCtSlRk02TFA/D641DuCzppLZR6O51p1PNHK6LvU8Na+WYc8fz3KS
         9Ov7FoivT6EbbhZWvEUsIA87/2ds3H46wBEU4ULDUeMY32YRjMfrwOhgli1FFZegip7a
         uRCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=CXiwyxpsYbtktJw1JiQrFKlxs5Eu1bgqDSTeXz8tQMY=;
        b=DRFg6lrTvEKExyyxjUdzowBuxAzgn5eu23RRKUlAGZoZ6TGfZ7PoVdGIvbdYDS3Rp6
         PJq2d4XdffJHJUMMHdIo7uqswxDuKFVy4rAhjlkYoGpAAl+5HSjhBAglRNgLRZic4iZ8
         P6Qb74w/bUVoTGtw3ekXsM+A5BTIG/60xGZvgb7zcgK5OtXwqi17nuiYYiWiu7KqQqUG
         2MybcZnZmbQlbZgtmOTrJfLO1EKtDV9qSPlktcIsggISCHh/AZ7yL/fvTXGLxI9kYQXW
         SA6f3SkR2ep595A6WhFP6+ISxlqFbcNkk0h7OhGYvHOlU7GURrHbZgxapFhXIs8e032d
         loUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m27si460642eja.92.2019.02.21.03.35.27
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 03:35:28 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0263315AB;
	Thu, 21 Feb 2019 03:35:27 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 75F723F5C1;
	Thu, 21 Feb 2019 03:35:23 -0800 (PST)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: [PATCH v2 03/13] mm: Add generic p?d_large() macros
Date: Thu, 21 Feb 2019 11:34:52 +0000
Message-Id: <20190221113502.54153-4-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190221113502.54153-1-steven.price@arm.com>
References: <20190221113502.54153-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: James Morse <james.morse@arm.com>

Exposing the pud/pgd levels of the page tables to walk_page_range() means
we may come across the exotic large mappings that come with large areas
of contiguous memory (such as the kernel's linear map).

For architectures that don't provide p?d_large() macros, provided a
does nothing default.

Signed-off-by: James Morse <james.morse@arm.com>
Signed-off-by: Steven Price <steven.price@arm.com>
---
 include/asm-generic/pgtable.h | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 05e61e6c843f..f0de24100ac6 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1186,4 +1186,23 @@ static inline bool arch_has_pfn_modify_check(void)
 #define mm_pmd_folded(mm)	__is_defined(__PAGETABLE_PMD_FOLDED)
 #endif
 
+/*
+ * p?d_large() - true if this entry is a final mapping to a physical address.
+ * This differs from p?d_huge() by the fact that they are always available (if
+ * the architecture supports large pages at the appropriate level) even
+ * if CONFIG_HUGETLB_PAGE is not defined.
+ */
+#ifndef pgd_large
+#define pgd_large(x)	0
+#endif
+#ifndef p4d_large
+#define p4d_large(x)	0
+#endif
+#ifndef pud_large
+#define pud_large(x)	0
+#endif
+#ifndef pmd_large
+#define pmd_large(x)	0
+#endif
+
 #endif /* _ASM_GENERIC_PGTABLE_H */
-- 
2.20.1

