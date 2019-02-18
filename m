Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DECDEC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 23:13:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91B4621900
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 23:13:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oz6Vj4Z9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91B4621900
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA9CB8E0005; Mon, 18 Feb 2019 18:13:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE4258E0002; Mon, 18 Feb 2019 18:13:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C38358E0005; Mon, 18 Feb 2019 18:13:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 97C8F8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 18:13:28 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id m136so1301724ita.9
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 15:13:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Ptp8Fjet112pFAX81FwzCfRXujZdfs3mZO2hPYz+OK0=;
        b=WsPJxLKtEzTT0QJzdGPkV10gdmdFnBzm74SjAeztHhcta/a6uMHweC+nAJhC2lIsb6
         pcrz9OyRzuC6GS0W6kLmyPCtHSEJiqSqzviFTouqxatWi0iys/nxfMof3dGLqs5p5ti7
         yFDVZzCzKNNgovojcuVXmbRWpPP71TnJI+oq8GvtSV1iF/TtrLKsM78wmbTohnKBfpyY
         zx0UxJd3wAYOSM16BlQUy4aBj7pQG+U4J5XRIWlVHKaMNCdWp1+VT35MM8Aq7UyJ007D
         zbdmggO2dfJcLM/Gd6PfOtvLLz4UhcL/H1huUH8oopIUFCdsS8YPSgD4+jIJLt1ubhIX
         YisQ==
X-Gm-Message-State: AHQUAuZkAuVhY2E7CUGbEoOLejo5IhMSlounVi/rGTmVhoBaKbFX5/nu
	QULzhWOk2pNprbHOJiGgCmEUd142ShK3/EwV81RXniL+GCMjx+nh+iNs/qDOdLfZAb9ujTRJY2o
	98ycQMcyo7835pnmqrh+egJ+9YKhWHHm5YVaSJ0l5P5pNP5WOCVeVWP/mEA3xj4M3Z92HHL5w9T
	m8ip8VW7RXIk0qhlEKlbr7rmdCLljJ9KUCjDnLjqTCQ6jgKdc1yf3f/Ib4aBdFA7nzeyVg2BmK1
	0tQTn//hDHRazYfiumV6JIaJfi9brfu8F/Pd6BoK38YHvG/TimxntarG94LdjDmN6YmhFVgZ22o
	/KZUqzlRNIBVFGcE7TdptJSDyzc35USivIgDXa9B91+wdt2lq1TazpitT7PUesXI5KK/Crdbt2t
	W
X-Received: by 2002:a05:660c:12c7:: with SMTP id k7mr714763itd.148.1550531608426;
        Mon, 18 Feb 2019 15:13:28 -0800 (PST)
X-Received: by 2002:a05:660c:12c7:: with SMTP id k7mr714740itd.148.1550531607708;
        Mon, 18 Feb 2019 15:13:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550531607; cv=none;
        d=google.com; s=arc-20160816;
        b=YZwYmsZT2ILwT9t5vxpvQYI+zovR9FoJSJ6kn8KRDCBslNKWOUZG8JnQKYy8pTfSUT
         IQZ2sCzmFrNrFZxQOMmqPOLaz5rAha5qIzLSTJZ1K8U1Gdx+MCBPk9XTb9HjMH6HFzjK
         fWIPaoYbnilZwkPLG50lOjKjm9yjh0X0yXZJIrVS1cglL6vEVUt05dCNUuyuNmjQ/Vzl
         PD0qdp0SS4kyETDHzU3x6ux2UVvPvJfBOcNZRRFXZt5863NPDcJm/QjzoIFpvOlx25wG
         zAyeKw1esoJ+jRwlwdISblsw5/p1Y/SNJDGSifwWtT1c6xB/TAv2m/mx1Zvglcj9GiRV
         Hyiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Ptp8Fjet112pFAX81FwzCfRXujZdfs3mZO2hPYz+OK0=;
        b=HcHwqUYxV8g3t7nBKexWvBsyjuux3x6/sYn+WfUDnzYnO6QFY/lrvbx1h7XG/8POD4
         1I/XJhrL2sgyuC6BQ27AdHDKnVM/Tvlu3xWWzAwudNyJrCmw99iooU+eOvcKrgTYaq7d
         8r6nmJme3hXb5CQ1IyQP9MWfKO1/VEKrDK+yA99D2GBw01Dn3ilDmb9zHAK0inmpVKoH
         NtSjYzV/Z9eQwa3ZmLFhyl1t/BiQp9qo5NNuagvTklBCUZWk2sq7si1wrm4HbAjD8plr
         6/WIg4e+6J8Llu97OpG5QOoaz2FDCxRGGCfEpp51pHDiJizYPS+WBS6cmu6ZPb6SkjJv
         zmIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oz6Vj4Z9;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p3sor8806916ioh.112.2019.02.18.15.13.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 15:13:27 -0800 (PST)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oz6Vj4Z9;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Ptp8Fjet112pFAX81FwzCfRXujZdfs3mZO2hPYz+OK0=;
        b=oz6Vj4Z9Eu13inGGnH5X0txN4tIEXnED3IA3SA+DL8Hs6lXNzNnfm18np5LEndb7ZA
         voPhslSSyKSjUqu885dvRfDAXX/PbCgZmQFNVkOsVEN+4xI1ESCcr1mz5xtEvA5kvars
         09wiPRS+Hwsa+5nu9xpAsdZrJaodFZfBOg3XimOLubN9MU2y8MKftP9YelUNkAzC/6g9
         QAcyLa4Y+3B7hEfLJ2RdQBWvCjW1fk05ykLXknVMZlQjFrReHBgkwhMkb22PovOrMA07
         3g+h9qiMKm7CgJHN837fmuTIcRUGWB9IqflxYJVAswPy/99fhVawSTjRKNSbOu0mCQwq
         hz5w==
X-Google-Smtp-Source: AHgI3IacpXhp7hqR4gpLOYb6jmTOiOS9RIZiMJQCPu5S8CRxsY3H9kPVQ0HReFAyHwtbAO1IIUX12g==
X-Received: by 2002:a5d:8545:: with SMTP id b5mr15973963ios.288.1550531607332;
        Mon, 18 Feb 2019 15:13:27 -0800 (PST)
Received: from yuzhao.bld.corp.google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id x23sm6541463ion.38.2019.02.18.15.13.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 15:13:26 -0800 (PST)
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
Subject: [PATCH v2 3/3] arm64: mm: enable per pmd page table lock
Date: Mon, 18 Feb 2019 16:13:19 -0700
Message-Id: <20190218231319.178224-3-yuzhao@google.com>
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

Switch from per mm_struct to per pmd page table lock by enabling
ARCH_ENABLE_SPLIT_PMD_PTLOCK. This provides better granularity for
large system.

I'm not sure if there is contention on mm->page_table_lock. Given
the option comes at no cost (apart from initializing more spin
locks), why not enable it now.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 arch/arm64/Kconfig               |  3 +++
 arch/arm64/include/asm/pgalloc.h | 12 +++++++++++-
 arch/arm64/include/asm/tlb.h     |  5 ++++-
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index a4168d366127..8dbfa49d926c 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -872,6 +872,9 @@ config ARCH_WANT_HUGE_PMD_SHARE
 config ARCH_HAS_CACHE_LINE_SIZE
 	def_bool y
 
+config ARCH_ENABLE_SPLIT_PMD_PTLOCK
+	def_bool y if PGTABLE_LEVELS > 2
+
 config SECCOMP
 	bool "Enable seccomp to safely compute untrusted bytecode"
 	---help---
diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
index 52fa47c73bf0..dabba4b2c61f 100644
--- a/arch/arm64/include/asm/pgalloc.h
+++ b/arch/arm64/include/asm/pgalloc.h
@@ -33,12 +33,22 @@
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return (pmd_t *)__get_free_page(PGALLOC_GFP);
+	struct page *page;
+
+	page = alloc_page(PGALLOC_GFP);
+	if (!page)
+		return NULL;
+	if (!pgtable_pmd_page_ctor(page)) {
+		__free_page(page);
+		return NULL;
+	}
+	return page_address(page);
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmdp)
 {
 	BUG_ON((unsigned long)pmdp & (PAGE_SIZE-1));
+	pgtable_pmd_page_dtor(virt_to_page(pmdp));
 	free_page((unsigned long)pmdp);
 }
 
diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
index 106fdc951b6e..4e3becfed387 100644
--- a/arch/arm64/include/asm/tlb.h
+++ b/arch/arm64/include/asm/tlb.h
@@ -62,7 +62,10 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
 static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp,
 				  unsigned long addr)
 {
-	tlb_remove_table(tlb, virt_to_page(pmdp));
+	struct page *page = virt_to_page(pmdp);
+
+	pgtable_pmd_page_dtor(page);
+	tlb_remove_table(tlb, page);
 }
 #endif
 
-- 
2.21.0.rc0.258.g878e2cd30e-goog

