Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91561C5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:41:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4802E214AF
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:41:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bizikAVg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4802E214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9C608E0010; Mon,  1 Jul 2019 02:41:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4EE98E0002; Mon,  1 Jul 2019 02:41:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D153D8E0010; Mon,  1 Jul 2019 02:41:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f206.google.com (mail-pg1-f206.google.com [209.85.215.206])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6FB8E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:41:02 -0400 (EDT)
Received: by mail-pg1-f206.google.com with SMTP id x19so7070303pgx.1
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:41:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=smDmHv6fTQfEC2Xw13QJ3CuxW2VIYrqrjOiGuS7E8nY=;
        b=I6WZLtY862c4oGqrxBqts+uR1BwtB/z77T09FRrHJ5c75657zV5h56dcTQZi6udOUU
         wl7sQAOt0bvd6qvdZTEewDn1YS7b/UAu7Mpy9tLdkiGPwy7eB3SOzV6alnzL8EUCMsfY
         tTVfvXpeGMHsgUJ8JEcNCxb3Zk9yQw08PW4bD3BhmsZnKSyHdg5baoz/x+iRD5JMNdSv
         A3X1FfwsmC2Hf2ebYVTnuc5p2oLQJ3eCxE1gVmj20HNGcKLRjSnaDMV5IkU1ZznceoJg
         mgoZ/cKSrWdKFi91PZq3h6qZpc69kiKbNLfkoRSup3uTcPk7+jyXm73Enf2kAQE9siFf
         5XLg==
X-Gm-Message-State: APjAAAWh93Gy1g7l3CKKK/iWXtqIBI9ZVl+y5VlnWC1nQUYdE1qBG0O7
	OerkIK4jt8GVdofHTP8mBQv4Qa2VRtTnouqV9U0EuXS5zOpMxEkpyjmG37SU6QnBCwb5YyE+yTV
	jvxxyloU/b6Xp0pMYqUExPLQTdMrkw7/CqKtpaiGX/t8UQa9yY56XCrFD/DVH8bC9OQ==
X-Received: by 2002:a17:90a:2ec1:: with SMTP id h1mr29257371pjs.101.1561963262265;
        Sun, 30 Jun 2019 23:41:02 -0700 (PDT)
X-Received: by 2002:a17:90a:2ec1:: with SMTP id h1mr29257309pjs.101.1561963261513;
        Sun, 30 Jun 2019 23:41:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561963261; cv=none;
        d=google.com; s=arc-20160816;
        b=jPx4P4qt3bHgmxdQ4Syldg9TATpTVYpAH55UF6fWNklBa4VTnly1+heUwvn0GzHyGy
         JdMz3dzAfS42+i9X0kiZjZXKY9J/3eBjKeHChdCwgbcRlVpZzTeBL0mrd4zVwaekILxb
         fnsbRdbmnfCWaI9mRhm3QyO4sng8m/R4jxkP3aEAI/BOA0RCTPgGh2rBjG9tocPJcDnf
         TN+Sj+0d3664el+G9l9KcB4/96TEN2vMhDtZl0cnlSE8M5DcFLTl0sYAcmZEBfwVlIor
         O1CScKpuakRZ62dmFR0tRC/kv/K/raCRzBCxeO9VqoAioshbCfwp2cYEQyZIHEzoovKt
         hozw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=smDmHv6fTQfEC2Xw13QJ3CuxW2VIYrqrjOiGuS7E8nY=;
        b=acR0YbaPzbJ5Zjs3i5UZHGRXHaw+PDhZft+pkt34g6+VCeDnZXD38J1MGOH0PXM6o3
         BS81k84QF1FAh8BmBHqUBU0b+thwpuJs/llmMz9zRHdLcDpUXmsFpeWEBb0fzzNxonSm
         W7urispfZgx3h4ufNaL5ighG450NY6WoHlE7qtTfvfiUFvOtbQra1Xl7px+OB6kZFlTJ
         VBEplPwT/RL3GkKG0yMcdqdIP8X2LFdfjpUkWjC0cveE9qUPTOJj3iWJNw5YxpNE+GhU
         0rFuAmb/9VYsQ4FZVosG/4GyLi+/287bUZE/HuWNw+G1Yc1TZw9Rt7KtW3tMpx7BSEEP
         1Xtw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bizikAVg;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3sor11203805plo.62.2019.06.30.23.41.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Jun 2019 23:41:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bizikAVg;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=smDmHv6fTQfEC2Xw13QJ3CuxW2VIYrqrjOiGuS7E8nY=;
        b=bizikAVg98c+yn3J0ciWcHUsmX+eyH5Ec+Sx1ENDwBE32Rx/0lg8b1PCfc37WCUEDP
         jvLHutEpkCjCeKIF+3OCxCQD2xwfD1eqZv22X/0xYJQ2gfkR6T5h9U/i3UGWyxnopCfA
         Lc9xD+81BMSV0KJwxT6Zl8kgkeypStm0C7tCePD/8Phv4vhKKMSzIoSCKbqq4aQcXAk2
         zSivyt8fYuQ9m/IJ5Iloms2K0emcTQysfKlLQHpo7SvscAXV2YkufHhBN7FSL1dpYBzJ
         hW4BMvvO1kSJHQ22hVPW5au0hnygWqK2g/+kZgrcqWqf4S6z9Rb8Swfe1cQTUPSpss9b
         XiSA==
X-Google-Smtp-Source: APXvYqxC3bQxXqpIe85UilgRlX3q9ASs816UdqitUsnjCUP/RYiNALnXskGWa2IYqd1xwqXJJ9Kx/Q==
X-Received: by 2002:a17:902:d887:: with SMTP id b7mr27095942plz.28.1561963261105;
        Sun, 30 Jun 2019 23:41:01 -0700 (PDT)
Received: from bobo.ozlabs.ibm.com ([122.99.82.10])
        by smtp.gmail.com with ESMTPSA id x128sm24238285pfd.17.2019.06.30.23.40.57
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:41:00 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: "linux-mm @ kvack . org" <linux-mm@kvack.org>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	"linux-arm-kernel @ lists . infradead . org" <linux-arm-kernel@lists.infradead.org>,
	"linuxppc-dev @ lists . ozlabs . org" <linuxppc-dev@lists.ozlabs.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Mark Rutland <mark.rutland@arm.com>
Subject: [PATCH v2 3/3] mm/vmalloc: fix vmalloc_to_page for huge vmap mappings
Date: Mon,  1 Jul 2019 16:40:26 +1000
Message-Id: <20190701064026.970-4-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190701064026.970-1-npiggin@gmail.com>
References: <20190701064026.970-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

vmalloc_to_page returns NULL for addresses mapped by larger pages[*].
Whether or not a vmap is huge depends on the architecture details,
alignments, boot options, etc., which the caller can not be expected
to know. Therefore HUGE_VMAP is a regression for vmalloc_to_page.

This change teaches vmalloc_to_page about larger pages, and returns
the struct page that corresponds to the offset within the large page.
This makes the API agnostic to mapping implementation details.

[*] As explained by commit 029c54b095995 ("mm/vmalloc.c: huge-vmap:
    fail gracefully on unexpected huge vmap mappings")

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 include/asm-generic/4level-fixup.h |  1 +
 include/asm-generic/5level-fixup.h |  1 +
 mm/vmalloc.c                       | 37 +++++++++++++++++++-----------
 3 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/include/asm-generic/4level-fixup.h b/include/asm-generic/4level-fixup.h
index e3667c9a33a5..3cc65a4dd093 100644
--- a/include/asm-generic/4level-fixup.h
+++ b/include/asm-generic/4level-fixup.h
@@ -20,6 +20,7 @@
 #define pud_none(pud)			0
 #define pud_bad(pud)			0
 #define pud_present(pud)		1
+#define pud_large(pud)			0
 #define pud_ERROR(pud)			do { } while (0)
 #define pud_clear(pud)			pgd_clear(pud)
 #define pud_val(pud)			pgd_val(pud)
diff --git a/include/asm-generic/5level-fixup.h b/include/asm-generic/5level-fixup.h
index bb6cb347018c..c4377db09a4f 100644
--- a/include/asm-generic/5level-fixup.h
+++ b/include/asm-generic/5level-fixup.h
@@ -22,6 +22,7 @@
 #define p4d_none(p4d)			0
 #define p4d_bad(p4d)			0
 #define p4d_present(p4d)		1
+#define p4d_large(p4d)			0
 #define p4d_ERROR(p4d)			do { } while (0)
 #define p4d_clear(p4d)			pgd_clear(p4d)
 #define p4d_val(p4d)			pgd_val(p4d)
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0f76cca32a1c..09a283866368 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -36,6 +36,7 @@
 #include <linux/rbtree_augmented.h>
 
 #include <linux/uaccess.h>
+#include <asm/pgtable.h>
 #include <asm/tlbflush.h>
 #include <asm/shmparam.h>
 
@@ -284,25 +285,35 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
 
 	if (pgd_none(*pgd))
 		return NULL;
+
 	p4d = p4d_offset(pgd, addr);
 	if (p4d_none(*p4d))
 		return NULL;
-	pud = pud_offset(p4d, addr);
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+	if (p4d_large(*p4d))
+		return p4d_page(*p4d) + ((addr & ~P4D_MASK) >> PAGE_SHIFT);
+#endif
+	if (WARN_ON_ONCE(p4d_bad(*p4d)))
+		return NULL;
 
-	/*
-	 * Don't dereference bad PUD or PMD (below) entries. This will also
-	 * identify huge mappings, which we may encounter on architectures
-	 * that define CONFIG_HAVE_ARCH_HUGE_VMAP=y. Such regions will be
-	 * identified as vmalloc addresses by is_vmalloc_addr(), but are
-	 * not [unambiguously] associated with a struct page, so there is
-	 * no correct value to return for them.
-	 */
-	WARN_ON_ONCE(pud_bad(*pud));
-	if (pud_none(*pud) || pud_bad(*pud))
+	pud = pud_offset(p4d, addr);
+	if (pud_none(*pud))
+		return NULL;
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+	if (pud_large(*pud))
+		return pud_page(*pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
+#endif
+	if (WARN_ON_ONCE(pud_bad(*pud)))
 		return NULL;
+
 	pmd = pmd_offset(pud, addr);
-	WARN_ON_ONCE(pmd_bad(*pmd));
-	if (pmd_none(*pmd) || pmd_bad(*pmd))
+	if (pmd_none(*pmd))
+		return NULL;
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+	if (pmd_large(*pmd))
+		return pmd_page(*pmd) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+#endif
+	if (WARN_ON_ONCE(pmd_bad(*pmd)))
 		return NULL;
 
 	ptep = pte_offset_map(pmd, addr);
-- 
2.20.1

