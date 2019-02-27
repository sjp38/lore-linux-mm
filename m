Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 302AFC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE27320842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE27320842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F4BF8E0015; Wed, 27 Feb 2019 12:07:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A6A98E0001; Wed, 27 Feb 2019 12:07:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86F2F8E0015; Wed, 27 Feb 2019 12:07:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 283B88E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:07:36 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d31so7237997eda.1
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:07:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=d7Ez4LEs1GxX+k7wJ+eVDpmUwku09yzSGsf2pAay+/c=;
        b=ts8fVILfWUjFzXfHHf5wco35zwkPLkpMAbnE2TFijY4EXSNJcp8YsSrSrOjvwqpqGi
         5EJyKJEaArrgD87qlk6NPBU+uDdko5JqPCdL3vD5TqJgdEdsZ1SFAQ6JVmiX3N2rm8+B
         roREa/HhdiekeeJYnthJabgQwkh7SH7Lf/3MsOy497w8tmqEMuG5Q7a7n5DyNaIM2T2H
         s86lTepYhQY6xdSrcDXe5Y81UIkzQvMIpHrdDk2oV5l6Gnuyl1WX3AiN0YVRO4JdEkbP
         9ubHzhz+6Q5e0yPYhTN4IjiPR1wsfJ+fzBxbkPpuFc1gvUnCi7mxkKhW0CYh9xni9ZTZ
         JDjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuapiN3Q6EuWjNP231FbUKPMr+9U2vSoaJwf37Fe/ph6jtQLaDkq
	FI9sKdfsOTMR16DrDL08gzpxwqL28MuT2zDJy4fzIzQMGablUBL9O5saNDQDYLpPDiVODfEBkp6
	WemywKjYyTECEeDPZIXPG5T+BKqF+WjxHm17lYFS3vg/fRHq695zY7K/FdwrrhR7q/Q==
X-Received: by 2002:a17:906:5612:: with SMTP id f18mr2306254ejq.44.1551287255666;
        Wed, 27 Feb 2019 09:07:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZtXKBFcJS/Wjaz8yythsjd7f3NZYFrjARpW9k2CzhF6DGxRyPwyPx0ZbQyDphqDGN+X0qN
X-Received: by 2002:a17:906:5612:: with SMTP id f18mr2306192ejq.44.1551287254685;
        Wed, 27 Feb 2019 09:07:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287254; cv=none;
        d=google.com; s=arc-20160816;
        b=Lb6a6ykqFiIBLAipaoHgiU/a0XbTvu0Vfz9b9fEflvTMnbcohqjlvQeVb8UClgz2af
         8yYnOy7aG6cbZOXGTHYau5WnfQyd5tIHSnBupXFQsIi3uIa3rFeeXLa6zC6uD7fxM0Bj
         Jf1s7GjzSbovH7pOdyZcZIHixU0UPQbPBKGRzyultc7c+BhVEM6qScfAZFFbyll7SrjO
         utqI2ljMxDVglZS3pZl2np7gN6pVK/b4f50dePTUHKkR6pgfSdRbvcCVwJ9s9EQiguMa
         LAmw6W2f+7I8vcLsDoAxZPokCcpqmK2wN4ZqF3OzH67vcAnlH3ylnYRFS7oT+tGNtQmu
         ELvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=d7Ez4LEs1GxX+k7wJ+eVDpmUwku09yzSGsf2pAay+/c=;
        b=Nl1egvahvbm9Wxy1a4ikIE0lNMbNUsBsRhPVMQZUcMymJ3b0bvpd73uzRNnPC4Msd8
         CwafjcL/V+Jrm7S9tJ/hfkHaQ19j3qJH7GaXUKQ7JmxWo9/51eSg+qJYiIDxLSdagnt9
         uQ9ybLQnc+W8WnBBOGTmzYlxqysgm92nfhLV5Bw00mJ3yELKbJ2oUK9KqPvIOyfTQjZN
         GjcruB76wv/1y3aR6caCLC933by+M/QRmte4/wD6SK3/EjifSnXQ4GRvo4ye5Ea290VH
         ex8/dJkPUGmZoQrOZPyUYlbmPjAYDE3QhiCRH1KBoAkaJvMETRHQboq4kZwqR+FhoZQl
         g6lQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i14si1737427ejh.321.2019.02.27.09.07.34
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:07:34 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B989EA78;
	Wed, 27 Feb 2019 09:07:33 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 13FF23F738;
	Wed, 27 Feb 2019 09:07:29 -0800 (PST)
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
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	linux-riscv@lists.infradead.org
Subject: [PATCH v3 17/34] riscv: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:51 +0000
Message-Id: <20190227170608.27963-18-steven.price@arm.com>
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

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information is provided by the
p?d_large() functions/macros.

For riscv a page is large when it has a read, write or execute bit
set on it.

CC: Palmer Dabbelt <palmer@sifive.com>
CC: Albert Ou <aou@eecs.berkeley.edu>
CC: linux-riscv@lists.infradead.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/riscv/include/asm/pgtable-64.h | 6 ++++++
 arch/riscv/include/asm/pgtable.h    | 6 ++++++
 2 files changed, 12 insertions(+)

diff --git a/arch/riscv/include/asm/pgtable-64.h b/arch/riscv/include/asm/pgtable-64.h
index 7aa0ea9bd8bb..6763c44d338d 100644
--- a/arch/riscv/include/asm/pgtable-64.h
+++ b/arch/riscv/include/asm/pgtable-64.h
@@ -51,6 +51,12 @@ static inline int pud_bad(pud_t pud)
 	return !pud_present(pud);
 }
 
+static inline int pud_large(pud_t pud)
+{
+	return pud_present(pud)
+		&& (pud_val(pud) & (_PAGE_READ | _PAGE_WRITE | _PAGE_EXEC));
+}
+
 static inline void set_pud(pud_t *pudp, pud_t pud)
 {
 	*pudp = pud;
diff --git a/arch/riscv/include/asm/pgtable.h b/arch/riscv/include/asm/pgtable.h
index 16301966d65b..17624d7e7e8b 100644
--- a/arch/riscv/include/asm/pgtable.h
+++ b/arch/riscv/include/asm/pgtable.h
@@ -111,6 +111,12 @@ static inline int pmd_bad(pmd_t pmd)
 	return !pmd_present(pmd);
 }
 
+static inline int pmd_large(pmd_t pmd)
+{
+	return pmd_present(pmd)
+		&& (pmd_val(pmd) & (_PAGE_READ | _PAGE_WRITE | _PAGE_EXEC));
+}
+
 static inline void set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
 	*pmdp = pmd;
-- 
2.20.1

