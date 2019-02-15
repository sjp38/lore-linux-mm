Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B3E9C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E803821924
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E803821924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DF4E8E0006; Fri, 15 Feb 2019 12:03:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88CB58E0001; Fri, 15 Feb 2019 12:03:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A44E8E0006; Fri, 15 Feb 2019 12:03:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 25AAE8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:03:18 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so4251183edd.2
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:03:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cgmVGKBRQKtEZdJyjA1gIFBtbXN/G8O1rrSlP5LxrbQ=;
        b=TVKs8Pd0nui+pmydpOMLMV5MWc6HUaxw814MBEuGGb1rdPwd261eCijcNom+86yH3t
         NEN2TJiWfaggMXSZPi1hqljHM/rENec43BRcwAT4FiJ0XFW9RHN3X032sxMfw+2sCp6R
         b4ErV2vD4hJr8ROfWvpd8/boeBRelE+9nPAZd/fG+brQZrqN8W32st0GtPSlC7zR6tcZ
         SU586ezxJ6FUaH8CWtIy0TsDk0KZTPDeK60ec7oe8FkYU6iLxdPPG7NSv609hWjZfZwQ
         7PJGgdxZ31AF+z2+DPhcZk9CTYBbFhOdt5mPeQURv/Aj5iep6KxTmspNyXwLKBuC1uwj
         8b8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuYGdgAlhojg7AdqUUIjMx0U2TPPEelHXlNJkuD3fBuHAoMo4aB6
	TBk4T/O8+/hFH2W5q/mckxRkVwwqEFN1xFc3t14NwAh3UVeK4vAyAsaf+lPLt7v3MlzNh7dd4+x
	7METoiA3sBgETJfC+Od6sw7pLt1TemgiyADSY4g3G4STUb3A8onMJeXS8dYBMxbkQmg==
X-Received: by 2002:a17:906:a3c3:: with SMTP id ca3mr7345751ejb.25.1550250197649;
        Fri, 15 Feb 2019 09:03:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaLag4HHIUgW/LTxlTrWys+if6hbmvRKCsMQCK8hAJXySe3xpHkDtGmiPVrcdn+YYK/qVD0
X-Received: by 2002:a17:906:a3c3:: with SMTP id ca3mr7345681ejb.25.1550250196408;
        Fri, 15 Feb 2019 09:03:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550250196; cv=none;
        d=google.com; s=arc-20160816;
        b=CjsfsvxQrLzDxo8fXitoXJpIFPsPIwXDiIMO/LeQlvc/Qd2YftWimAvcHbaoVonJAI
         f+PwQQYJjWUbZUZkjTirF8lwj90Y0XuMRgcQEzuuvSfPTKDhbQ+qjv9vbY4L4wNLQ46X
         bQMDxCbqN4AEaldiFrUzW9kuLzNaAd8sW4epcOUMNosNOuB3zd1iO+B9R15HghG7OlH7
         X+USfystK5jKthhnaTQs42lX1XQLHUXPYHju1G7u434shL9JRg3nA3Z52tdlaTTk+h1T
         fZTjJxIeNgR8DzkXtbObIv6qxnVPqXfsLfVhtvdjon0wgHDQQh1gy7YgSLL7b49GfJ81
         aqhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=cgmVGKBRQKtEZdJyjA1gIFBtbXN/G8O1rrSlP5LxrbQ=;
        b=eWf011aQJMS3iydDesn0idKd7TQQnCOjvyq+bB24jM3MQmn7B4HViU+WvbEVnPcr1k
         VuwyISsQ1VJZJc/h6DAjUl7PCWe6fcY8q5LJ9Zlc8Z8HpLltvOHzDepF6CJDNCdt/j5/
         TjuC6N35vliRxTZ3c8N0Pb+LZ3M7UXyWDi3FqN8nZx0HAZvUxDCjZV+GIVGaKnR4aBOO
         fg1DABmUYIYuA08eckO/NSfU60kbjkr+xxtxnHJAZx+mIIG3XHnVFyztZeAL6s4U+Fve
         HXASyE+D2hP5K+MJ4fKsEzQu3EwFjkU+PeqNDYIHDgX36zDY7f5RPApqz9XcWYudmqXp
         dJZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p22si410809ejr.147.2019.02.15.09.03.16
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 09:03:16 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 71631EBD;
	Fri, 15 Feb 2019 09:03:15 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7D4693F557;
	Fri, 15 Feb 2019 09:03:12 -0800 (PST)
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
	linux-kernel@vger.kernel.org
Subject: [PATCH 03/13] mm: Add generic p?d_large() macros
Date: Fri, 15 Feb 2019 17:02:24 +0000
Message-Id: <20190215170235.23360-4-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215170235.23360-1-steven.price@arm.com>
References: <20190215170235.23360-1-steven.price@arm.com>
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
 include/asm-generic/pgtable.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 05e61e6c843f..7630d663cd51 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1186,4 +1186,14 @@ static inline bool arch_has_pfn_modify_check(void)
 #define mm_pmd_folded(mm)	__is_defined(__PAGETABLE_PMD_FOLDED)
 #endif
 
+#ifndef pgd_large
+#define pgd_large(x)	0
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

