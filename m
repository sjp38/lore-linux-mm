Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 892A1C31E40
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AF68208E3
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AF68208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3323D8E0002; Tue, 30 Jul 2019 01:52:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E1CF8E0003; Tue, 30 Jul 2019 01:52:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 182788E0002; Tue, 30 Jul 2019 01:52:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B14998E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:52:37 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so39572633ede.23
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:52:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zeV7cRDg//NBM0c2n9mDOnVPZ/BNPft3Bx8vY7oRip8=;
        b=LULngB6248yWJFeMvI8Z67om7OEs8M0AlSR9LbJ0vLCTHI5eqJsVh9ASR983Y50xHZ
         mGJzm4Uy5wJDq2FmQQOU3nBmT9Nd4rABqu4EhZbSDkYF6t9T2jZ3thjKyF34bNe7RsoU
         ygSe7t37EYbBN1gpMdkansaUbfG6AFiGlIhwBpo7dkWEtRkNqEva/Tm333rist2bxM3+
         abqTtZL8F0NaaMS/nsk6FZjb9HhyayWWa2AKBY72qj7YB60ybeR+0V6tymszFcesBnpV
         M258Dk8is1kTr3ldrhlvNfoZcZrb0c4x01cYlr8LcQtuoEhsRZsx5xF3PQd5g52kRyzX
         WmCg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWoshToAwgoOcF1U3lVaOLL4SLMfYnwOH/yJjpz+mWxfL0e4ktL
	z6X1uiXRzLz34nSkFNQxGFUYlWtFv/9w9+1YHyFcutwCYZes4r4ezuIQC6uLsAhZKKdVjAWEr7z
	vhJC5CH/eg9AFGp76u0qaaUb4NO8GQo982wlDk/CdBjmwQfF3tauj2CpPqLU7cE0=
X-Received: by 2002:a17:906:19c6:: with SMTP id h6mr31213ejd.262.1564465957256;
        Mon, 29 Jul 2019 22:52:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhMCCh14+Xe11jHiRbURLfr6oG98TiTHAuZzT5wxJ3mk+Gp+U/Dik7TJ8t8lBani6Yf1BD
X-Received: by 2002:a17:906:19c6:: with SMTP id h6mr31185ejd.262.1564465956375;
        Mon, 29 Jul 2019 22:52:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564465956; cv=none;
        d=google.com; s=arc-20160816;
        b=NotiSM/eF9udhu4P58FYLf/kitMsZSBVMWTW6zzMLsYRdTcFnAEczlmJPGN12CAvZC
         3pw3fDVPgAnZa9/aCjG4CBWJQOnVuVtclyC/EyJM8DvOtn2V5EihpNHVWG32OTUWXwLp
         cmih37DslNcP75y2woCzWaxVjwQ//UbvZsrb34XgAgg1K1nSZSd6U4IXD93+JNWBmNCD
         li13luQoYvmwZaL10dZxAk+PRrNK+Fke2CWHNopgvosZV1lxWQyf3QMBbm+Rx9U3frQb
         ZrQdJ6hz3FHluf2kioO6t0OgImnSUwdh+MWv2JlSizPBI2vUWvFR5YjiTKmjiAJAsJGu
         eoXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=zeV7cRDg//NBM0c2n9mDOnVPZ/BNPft3Bx8vY7oRip8=;
        b=QZNLVswtKByMe2cwSWygXAe515rlSis5qO4SupUQBzJoDvDtAFtG2r6UPjQCXn9otA
         f0WnNUcBoymPYQPfSuttvT32kV1wFQhp5R6vZ50AdZrSxOHqjiIr6GwIOjVmRm4rKzt6
         V+OjzKgBgY57v4u8m1WTVBD6MmVsnJOJ42wgZeSNaN/jD1uNojgcAjJYxxhgFkXz3hPq
         iGVm6SfeNuQ+9sP9kGAWSVBalkv9ouwjAiAyROCSFyWdpOnnECqtmxb8PcicB5BMEGKM
         cE+GeLjViyvEa2xxTkSOnOpgVnJSEiLs/XWjndDZKUNYOPIKZRhm4w4qKKu4v9QyjGd3
         9IVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay8-d.mail.gandi.net (relay8-d.mail.gandi.net. [217.70.183.201])
        by mx.google.com with ESMTPS id by8si16345785ejb.129.2019.07.29.22.52.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jul 2019 22:52:36 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.201;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay8-d.mail.gandi.net (Postfix) with ESMTPSA id C4A9E1BF20E;
	Tue, 30 Jul 2019 05:52:31 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luis Chamberlain <mcgrof@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v5 01/14] mm, fs: Move randomize_stack_top from fs to mm
Date: Tue, 30 Jul 2019 01:51:00 -0400
Message-Id: <20190730055113.23635-2-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055113.23635-1-alex@ghiti.fr>
References: <20190730055113.23635-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This preparatory commit moves this function so that further introduction
of generic topdown mmap layout is contained only in mm/util.c.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 fs/binfmt_elf.c    | 20 --------------------
 include/linux/mm.h |  2 ++
 mm/util.c          | 22 ++++++++++++++++++++++
 3 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index d4e11b2e04f6..cec3b4146440 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -670,26 +670,6 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
  * libraries.  There is no binary dependent code anywhere else.
  */
 
-#ifndef STACK_RND_MASK
-#define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))	/* 8MB of VA */
-#endif
-
-static unsigned long randomize_stack_top(unsigned long stack_top)
-{
-	unsigned long random_variable = 0;
-
-	if (current->flags & PF_RANDOMIZE) {
-		random_variable = get_random_long();
-		random_variable &= STACK_RND_MASK;
-		random_variable <<= PAGE_SHIFT;
-	}
-#ifdef CONFIG_STACK_GROWSUP
-	return PAGE_ALIGN(stack_top) + random_variable;
-#else
-	return PAGE_ALIGN(stack_top) - random_variable;
-#endif
-}
-
 static int load_elf_binary(struct linux_binprm *bprm)
 {
 	struct file *interpreter = NULL; /* to shut gcc up */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0334ca97c584..ae0e5d241eb8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2351,6 +2351,8 @@ extern int install_special_mapping(struct mm_struct *mm,
 				   unsigned long addr, unsigned long len,
 				   unsigned long flags, struct page **pages);
 
+unsigned long randomize_stack_top(unsigned long stack_top);
+
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
diff --git a/mm/util.c b/mm/util.c
index e6351a80f248..15a4fb0f5473 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -16,6 +16,8 @@
 #include <linux/hugetlb.h>
 #include <linux/vmalloc.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/elf.h>
+#include <linux/random.h>
 
 #include <linux/uaccess.h>
 
@@ -293,6 +295,26 @@ int vma_is_stack_for_current(struct vm_area_struct *vma)
 	return (vma->vm_start <= KSTK_ESP(t) && vma->vm_end >= KSTK_ESP(t));
 }
 
+#ifndef STACK_RND_MASK
+#define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))     /* 8MB of VA */
+#endif
+
+unsigned long randomize_stack_top(unsigned long stack_top)
+{
+	unsigned long random_variable = 0;
+
+	if (current->flags & PF_RANDOMIZE) {
+		random_variable = get_random_long();
+		random_variable &= STACK_RND_MASK;
+		random_variable <<= PAGE_SHIFT;
+	}
+#ifdef CONFIG_STACK_GROWSUP
+	return PAGE_ALIGN(stack_top) + random_variable;
+#else
+	return PAGE_ALIGN(stack_top) - random_variable;
+#endif
+}
+
 #if defined(CONFIG_MMU) && !defined(HAVE_ARCH_PICK_MMAP_LAYOUT)
 void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 {
-- 
2.20.1

