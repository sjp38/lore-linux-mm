Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B873C282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:49:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3954C20815
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:49:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3954C20815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2FDC6B0003; Sun, 26 May 2019 09:49:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDF226B0005; Sun, 26 May 2019 09:49:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA7706B0007; Sun, 26 May 2019 09:49:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5CD7C6B0003
	for <linux-mm@kvack.org>; Sun, 26 May 2019 09:49:18 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c26so23232667eda.15
        for <linux-mm@kvack.org>; Sun, 26 May 2019 06:49:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SIdeHf7UhNLwsGYhllhi9P4YFI2Wqufk36v6ndrJAYI=;
        b=eCQVg6mWY835Gh4frAGDaPzIFZoz9EJHbVPrpz3sQHF2yjepZqxP3oCOSw5E1bscD9
         UEbefk830tLf7FSdeFsxCLdci9eJmr06N7kJoqMvjHDuZOyht5r0OBZHSV/y/m79+ACq
         j/7/ILtPRHvrgiGQzdCJgwpp3Xjj82aPMuSLxivAOp8fYOy17J8pfHpQvAShynpqLu2Z
         1OgB8nJLFvlFC8h/Cw+w0l4cFrmKtf5E391/EIX233jlSQxSL32FH6p0hGHymUN45t2n
         mhUT0HENcX7R+4fj0dAQ3RYisAU9h0FihH1BQ4MFZ2ZS/9rBB0cTRrBhe+mLghQvZ8dd
         dXVg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVXRH1L88P7L8Rg8sSuG0hwIHEICLq1sSld0UaNTg6Ww2bETfes
	R8n4iDl3LT/hjrlPP2pRc31JGOUF+sgOwWqw4Ebz8dJTeb5/bR2m4aJnotD9X1QPHhjVwaFs9hi
	BrgnuOa0x5S6kpZD2XYl6vhl7ArL6C/MsFEhXMwPjqa5vtXFklp7GkxRGC28ORmI=
X-Received: by 2002:aa7:c596:: with SMTP id g22mr117761017edq.32.1558878557776;
        Sun, 26 May 2019 06:49:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwK1dpRpU/bum5j3Gm4HlYOjpIe4v1u+c9qzIibg5G631ycXr73nZUSvEDJNU3nuFgjqq4J
X-Received: by 2002:aa7:c596:: with SMTP id g22mr117760947edq.32.1558878556575;
        Sun, 26 May 2019 06:49:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558878556; cv=none;
        d=google.com; s=arc-20160816;
        b=dPjrFVOnu0TVgzt+MR/H35ff6cK6mEXhg4tCBkIV7wi4/WJpp/XjJSNZ4WVzv9570F
         592YTlxa2UurLBtLJ9yv+DTYg2V9S+k4HY3H3wuROwhlVb62AsyYPTUhvKeGtAjxhfXb
         cb8fRH/2TKwH8vQh5zx/XQhEDedia5e5AtXiq1VusmQtMrYCRVcSkr0YpGGx+D9c8D3I
         OrbxSyQ0TTI1TJQ2tTCTaIYMnsPUlzPyh1Sly7MgkmNtTFqTGsHppeqOZn1VNpmbi5pC
         DlPdognLV1iFsc83ARscZoCwHDonFcasRkZMrBQcpWBgQXAMlHiMIOh/tYcxPEL7MylD
         BysQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=SIdeHf7UhNLwsGYhllhi9P4YFI2Wqufk36v6ndrJAYI=;
        b=Ox9RwbOy46id7AJszcE6fRIRCfFiVN4mTqpYwoiG6bKlrRSHT43d9McyXQbTCBnB2b
         dvssA0U5KSc84vqlLbATQmcM6XacD8VhWG2W+TW+NPgpcZrONc2B9y8Ky4nwjNbrbOEl
         wdyGx2fZ34NlL4o9nATxicge+hx1wGyw3ETykH/uTJMWuLMXG1UTJwlZ5zR7LJZDaBKD
         e2ob/NgyFAUynrkU5GGoYsa+b7ZoASW0qtHRfJMDqTp0NP373BZSY8uWN2qqtQfD3DC9
         iXpv75HXMk3JKS6HGmtK1p0Xbe3mPZIRi9I3h2sPrHUSZK5C8uatEewXQASsSK5sg9nQ
         w6sw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id g28si5203223eda.439.2019.05.26.06.49.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 May 2019 06:49:16 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id 16C8C20002;
	Sun, 26 May 2019 13:48:58 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v4 01/14] mm, fs: Move randomize_stack_top from fs to mm
Date: Sun, 26 May 2019 09:47:33 -0400
Message-Id: <20190526134746.9315-2-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190526134746.9315-1-alex@ghiti.fr>
References: <20190526134746.9315-1-alex@ghiti.fr>
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
---
 fs/binfmt_elf.c    | 20 --------------------
 include/linux/mm.h |  2 ++
 mm/util.c          | 22 ++++++++++++++++++++++
 3 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index fa9e99a962e0..d4d2fe109ee9 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -669,26 +669,6 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
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
index 0e8834ac32b7..446ec32c62b8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2368,6 +2368,8 @@ extern int install_special_mapping(struct mm_struct *mm,
 				   unsigned long addr, unsigned long len,
 				   unsigned long flags, struct page **pages);
 
+unsigned long randomize_stack_top(unsigned long stack_top);
+
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
diff --git a/mm/util.c b/mm/util.c
index e2e4f8c3fa12..dab33b896146 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -14,6 +14,8 @@
 #include <linux/hugetlb.h>
 #include <linux/vmalloc.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/elf.h>
+#include <linux/random.h>
 
 #include <linux/uaccess.h>
 
@@ -291,6 +293,26 @@ int vma_is_stack_for_current(struct vm_area_struct *vma)
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

