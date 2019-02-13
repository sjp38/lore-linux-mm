Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60B1CC282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:06:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29C72222CD
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:06:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29C72222CD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E286E8E0005; Wed, 13 Feb 2019 03:06:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D89BF8E0001; Wed, 13 Feb 2019 03:06:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C51438E0005; Wed, 13 Feb 2019 03:06:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8438E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:06:51 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f17so646683edt.20
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 00:06:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=podC4yBE/C4EalrFbyfqigYUTjh8/0NvFB8BYgeqwzI=;
        b=WQOglXebwMBGN93B/UGp8Day8CBGAw/k6HPCSOrtY632OFRUS4d75jGtFqvXHKTQvG
         fFeDrJqGPDDvGQ6PG3Penz+6EJpgo+dKaR8VwcvBNa5YZMQKJZmvS3lWLnwwf+1Vwbaz
         QIkoPMTt2w0J7gvGnksfE74kr/F/LbWxOF6Nmk7N1uVP/O/Qe+ePFjXvnNAo+hItj+Xm
         KTF67Lug036FRGw42Lh1lbQ8p8CgdqKq2seJSQ78cuSHhDxFRPAmgp7Z6zW2XmouwLhp
         dbpQIZLBIzn6g5gimalesGrjNGNtFyFtHv20JZfeqF0p6yujHzkaeZLE1ze1M9Tcz9FJ
         V8Eg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuZaagh6FV8KS/XjciyqCXtBAXVcjbg8aPVQWPg3XjgJ28++hA7M
	wswQhqn+SFdtxY9HOBdRl+/zxotdOINL+1UiePwChgSEsLxIsyrATpE9pgtV3QYSclhIhixHQ27
	m1eIj+lpIdqWHAmAeH9v5VMvRD43jwnsrorjN8B8/15YSMwA7+bnYK+HJW5hSyJ5/5Q==
X-Received: by 2002:a05:6402:1588:: with SMTP id c8mr2205569edv.176.1550045210904;
        Wed, 13 Feb 2019 00:06:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia2B1lP/e5gVO4YsRjrK3zlJG2Ui4t3Ae6gmL6MDmJOQ7+x2xgX0SIP+2L+ADHpCG9dEFT5
X-Received: by 2002:a05:6402:1588:: with SMTP id c8mr2205527edv.176.1550045209965;
        Wed, 13 Feb 2019 00:06:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550045209; cv=none;
        d=google.com; s=arc-20160816;
        b=ASu/5BglPOI81MJkOBX4XcWWC9rx9oOPgyIwEoPIP8YendpclIF28l3/DDYnd1AU/F
         ONCCo677gzduN4J6s1iYJ/DI1eJjiM/Rnspcl86R161VlEZIHKqH5PBZ/+zZvzuuA4eY
         mksyTlVkqVZuvYyG6SGqqa0htyYG3qoLGzPZn6lwV+s5H491626OgXTl8Oz2onpLH5/K
         OdztdR67CiL93CX5HSw3ErkVQ7Rf/F7b0g2gPq8vS9BrvWckw4FpVsellRJCFYl3ukns
         9CPCotk+SvA101JY/usq533fXWJIHXvu9P4tVSAE/N3iEquCBLgGOTH5Crqkhld0U3Dl
         N4zA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=podC4yBE/C4EalrFbyfqigYUTjh8/0NvFB8BYgeqwzI=;
        b=tw5HyGhkJit/yXJAxdJYgx1pLJ29FxclLy7s4dXP1zOrkAr+/vb7UMBAOcXxqyVmdc
         I3YZsrvHwgvwZk/yOX/YjMrT5PlNYIRWd8qFM59BnjMrDSShaeA53RGgBQxJT4PDkR2S
         OuAb4AqSsEkAyb8YnHMlFprJRTHRFHCTT6R+idCkXuE5UdWv4c6ZWLA5vu+6bmZ50Knd
         EpxTlrJym/G4EoaT5xonjwLRqlWomCIfskNVoxSqT7R76VQhh47Vsc4UiuWCpnKgWCa1
         yP6G8IGBabKUnifB5bNlavgdL/yeH4BYaKQYlHT9sVAc7UyyxfnnXRPCfdCtdWT6/T1K
         1Hgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 12si2621876edx.436.2019.02.13.00.06.49
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 00:06:49 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E152A1596;
	Wed, 13 Feb 2019 00:06:48 -0800 (PST)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.43.147])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 146E13F575;
	Wed, 13 Feb 2019 00:06:45 -0800 (PST)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	akpm@linux-foundation.org
Cc: mhocko@kernel.org,
	kirill@shutemov.name,
	kirill.shutemov@linux.intel.com,
	vbabka@suse.cz,
	will.deacon@arm.com,
	catalin.marinas@arm.com,
	dave.hansen@intel.com
Subject: [RFC 3/4] arm64/mm: Allow non-exec to exec transition in ptep_set_access_flags()
Date: Wed, 13 Feb 2019 13:36:30 +0530
Message-Id: <1550045191-27483-4-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ptep_set_access_flags() updates page table for a mapped page entry which
still got a fault probably because of a different permission than what
it is mapped with. Previously an exec enabled page always gets required
permission in the page table entry. Hence ptep_set_access_flags() never
had to move an entry from non-exec to exec. This is going to change with
deferred exec permission setting with later patches. Hence allow non-exec
to exec transition here and do the required I-cache invalidation.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/mm/fault.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 591670d..1540fc1 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -227,22 +227,25 @@ int ptep_set_access_flags(struct vm_area_struct *vma,
 	if (pte_same(pte, entry))
 		return 0;
 
-	/* only preserve the access flags and write permission */
-	pte_val(entry) &= PTE_RDONLY | PTE_AF | PTE_WRITE | PTE_DIRTY;
+	/* only preserve the access flags, write and exec permission */
+	pte_val(entry) &= PTE_RDONLY | PTE_AF | PTE_WRITE | PTE_DIRTY | PTE_UXN;
+
+	if (pte_user_exec(entry))
+		__sync_icache_dcache(pte);
 
 	/*
 	 * Setting the flags must be done atomically to avoid racing with the
-	 * hardware update of the access/dirty state. The PTE_RDONLY bit must
-	 * be set to the most permissive (lowest value) of *ptep and entry
-	 * (calculated as: a & b == ~(~a | ~b)).
+	 * hardware update of the access/dirty state. The PTE_RDONLY bit and
+	 * PTE_UXN must be set to the most permissive (lowest value) of *ptep
+	 * and entry (calculated as: a & b == ~(~a | ~b)).
 	 */
-	pte_val(entry) ^= PTE_RDONLY;
+	pte_val(entry) ^= PTE_RDONLY | PTE_UXN;
 	pteval = pte_val(pte);
 	do {
 		old_pteval = pteval;
-		pteval ^= PTE_RDONLY;
+		pteval ^= PTE_RDONLY | PTE_UXN;
 		pteval |= pte_val(entry);
-		pteval ^= PTE_RDONLY;
+		pteval ^= PTE_RDONLY | PTE_UXN;
 		pteval = cmpxchg_relaxed(&pte_val(*ptep), old_pteval, pteval);
 	} while (pteval != old_pteval);
 
-- 
2.7.4

