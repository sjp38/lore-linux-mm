Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97631C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AC3320842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AC3320842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABA1D8E001F; Wed, 27 Feb 2019 12:08:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6BD08E0001; Wed, 27 Feb 2019 12:08:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E1628E001F; Wed, 27 Feb 2019 12:08:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3339E8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:08:17 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id k21so4251752eds.19
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:08:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5+qDYU4THjLPvNOaZc1aA0s7EjXEEdRbPiGSrygYMH0=;
        b=Ev5gdc9zzYlHovXWhvEDvyhPZrP0H9CljdK12cGMjGycus4HlCYKJAhtgUkmz+9d+Q
         1iINmf9FQXKcrUCbup/b7SQqen+kkCeljaw2+qY0bbU7fJbU4zT8s/M42UhtaJSQbHNC
         P6NHyb8OFbEoq+nmCOVoQONs9tju1qczra2E4X5IPEC/Z9mbOJanz34Wn3VjIeRldB/Q
         zwcGZuD6SnTytO8TkYbFyRERc9QBkn5fEM214McZcr5Qis2QnfWt4jAG5HXBTDydr0xS
         G9QOz1wmg3L0y9eJ40+uwFF9kkaiVwVWT/xzqZcabvFqm3CWB8PB2f/o/T1FmSdWkbwV
         8rkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuaUpEBSsKGQ5tPlRQl7FkdFdibHXkezdPjeMLAo8Vo+OX6YDwHq
	A88NVAW5kcOyOc/WutpfXiseHyVqoENh2eTC6fXofRYnUAh2gsXVP9iRmwa3PjNn/X+jFojY3+t
	hd4D3J7pC/w5c7/lHolU3AfewIaA5dfFAWE9kgi89DYpiIflbUsx4uWCgqX876mCHNg==
X-Received: by 2002:a50:cac8:: with SMTP id f8mr3196686edi.212.1551287296709;
        Wed, 27 Feb 2019 09:08:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYeVIgW1b0Jg/w4dIhqe+PO0PfAoGUTBIfQW9siBNdXNeINVCRrBjH34RUopzN1DH3ObxZt
X-Received: by 2002:a50:cac8:: with SMTP id f8mr3196625edi.212.1551287295682;
        Wed, 27 Feb 2019 09:08:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287295; cv=none;
        d=google.com; s=arc-20160816;
        b=h3fiorNhmojkegE7+qEh6HbUITvw2ErflZnA8t1oNXUBf0KTzfwBDdXAajDBt61Q6M
         y4x45bcSFkQoS0k47RuYmS9hiy2ymfKnA7nKVBZobDxsW3Hh53c/f/4598shsXTfZ/Ng
         mxXxAscHIdmPobbt7p1uK0/QWNLJPbUFy9TTd7L0me3kbR1fB6uwqm4zdaEJbFm8ptPJ
         det+03cQD3Rxi4qxz8ccBjphTfU/xROuo/rdhPM/XKnPsARyH1einFwpiWHNBl5FnBqY
         gtri7tQ+QjDfxAqFElZs2puG+VInjxvygmgT8Lffv2fOG2O2QB4iKt7b9ue4VlvjUHFw
         y9QQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=5+qDYU4THjLPvNOaZc1aA0s7EjXEEdRbPiGSrygYMH0=;
        b=Qp0wqWfHCdvP8F0FUFP7dStxnX7eYSvcTZ754sNCOYcophgETWuajE+2mbmVGBh0zU
         ETz5J3xt182rM6/uylNONzPGntoF0lYCO0bXTC2/Mg3tv+7ii63GdefeTfhVdsxQgru2
         7HvXCbJBQVYJmhcbBckrydMzFLE5Z8oZSIQpuhdOv6imLfZN2nkwlKTUPiqkV8ll/XLi
         YwxfOtyb1k7wRkvUXm+5+eShlQs/+ZgrvXXNwkOnNUiKmDdrrlIWqk+ExYgpxza84g9T
         TFnjyUoDa21OZ17hAh9JLcDDn9xVPapQAhyeh/GCt60aPrjFyNSYgkLEdfUBG4gGZdvc
         RPpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o5-v6si2896540ejd.156.2019.02.27.09.08.15
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:08:15 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 980A81715;
	Wed, 27 Feb 2019 09:08:14 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5D5B83F738;
	Wed, 27 Feb 2019 09:08:11 -0800 (PST)
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
Subject: [PATCH v3 28/34] mm: pagewalk: Add test_p?d callbacks
Date: Wed, 27 Feb 2019 17:06:02 +0000
Message-Id: <20190227170608.27963-29-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227170608.27963-1-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It is useful to be able to skip parts of the page table tree even when
walking without VMAs. Add test_p?d callbacks similar to test_walk but
which are called just before a table at that level is walked. If the
callback returns non-zero then the entire table is skipped.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 include/linux/mm.h | 11 +++++++++++
 mm/pagewalk.c      | 24 ++++++++++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4ae3634a9118..581f31c6b6d9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1429,6 +1429,11 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  *             value means "do page table walk over the current vma,"
  *             and a negative one means "abort current page table walk
  *             right now." 1 means "skip the current vma."
+ * @test_pmd:  similar to test_walk(), but called for every pmd.
+ * @test_pud:  similar to test_walk(), but called for every pud.
+ * @test_p4d:  similar to test_walk(), but called for every p4d.
+ *             Returning 0 means walk this part of the page tables,
+ *             returning 1 means to skip this range.
  * @mm:        mm_struct representing the target process of page table walk
  * @vma:       vma currently walked (NULL if walking outside vmas)
  * @private:   private data for callbacks' usage
@@ -1453,6 +1458,12 @@ struct mm_walk {
 			     struct mm_walk *walk);
 	int (*test_walk)(unsigned long addr, unsigned long next,
 			struct mm_walk *walk);
+	int (*test_pmd)(unsigned long addr, unsigned long next,
+			pmd_t *pmd_start, struct mm_walk *walk);
+	int (*test_pud)(unsigned long addr, unsigned long next,
+			pud_t *pud_start, struct mm_walk *walk);
+	int (*test_p4d)(unsigned long addr, unsigned long next,
+			p4d_t *p4d_start, struct mm_walk *walk);
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	void *private;
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 57946bcd810c..ff2fc8490435 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -49,6 +49,14 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
 	int err = 0;
 	int depth = real_depth(3);
 
+	if (walk->test_pmd) {
+		err = walk->test_pmd(addr, end, pmd_offset(pud, 0), walk);
+		if (err < 0)
+			return err;
+		if (err > 0)
+			return 0;
+	}
+
 	pmd = pmd_offset(pud, addr);
 	do {
 again:
@@ -100,6 +108,14 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
 	int err = 0;
 	int depth = real_depth(2);
 
+	if (walk->test_pud) {
+		err = walk->test_pud(addr, end, pud_offset(p4d, 0), walk);
+		if (err < 0)
+			return err;
+		if (err > 0)
+			return 0;
+	}
+
 	pud = pud_offset(p4d, addr);
 	do {
  again:
@@ -143,6 +159,14 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 	int err = 0;
 	int depth = real_depth(1);
 
+	if (walk->test_p4d) {
+		err = walk->test_p4d(addr, end, p4d_offset(pgd, 0), walk);
+		if (err < 0)
+			return err;
+		if (err > 0)
+			return 0;
+	}
+
 	p4d = p4d_offset(pgd, addr);
 	do {
 		next = p4d_addr_end(addr, end);
-- 
2.20.1

