Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 170CDC43613
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 09:45:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5C9720679
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 09:45:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MC3Fgqht"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5C9720679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 764296B0007; Sun, 23 Jun 2019 05:45:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6EC0B8E0002; Sun, 23 Jun 2019 05:45:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DB468E0001; Sun, 23 Jun 2019 05:45:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 282836B0007
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 05:45:44 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 14so7110881pgo.14
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 02:45:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8jypfSRuf2tzCnQqgBbeT0KAA5/GWGPe8r0gYwybhoA=;
        b=ert74fN0VGz/LDN/C74DjupLjtPvv00ASW5QQoeYiVUVBVTSjUhdKC5eBtpKolnQ72
         AwTcCJ02As1xsf0Y5Mh0MfHrtBIYAwWwiO3n6lxRDv4HXtzHw+ogJkPkNZxEtPSYQc3N
         LXWYDHIkHvOkO0H8wj+q12NtcyeGisk3rb4Kpd8EWr7vHTuzSoDPWxJ93vMZwLZHlg7C
         oe4XNHa5owC21HkZ6f66k8md08jWlIdEQWawh2MntUyg7m4dDMlrenDbwrQBKfSKaH6U
         ZRAIryfpU+eRgJfc+cRaQzlbQKOkXjQPBjpBDiYSXfuU2GMIRgkag9VVlyO/RxPyIgkZ
         OM4w==
X-Gm-Message-State: APjAAAVVt6mlFnZBYUgq9qNkXo5AjRqZQgg6w0bi0icCGCZ18PIkoHiN
	z0Tr50GwDcnpaRghXcyTx65LzZHgyjlxE44P6pbgf1anc91fxHzSWV/ktoEkeVpWMvIvTNZhnlF
	lMlNxGHFhJXKAlrZKJk8QJwSnWcoYLoZli198ICp78g/O9xDZO16Vl+7Ta7s5KWevXw==
X-Received: by 2002:a17:902:820c:: with SMTP id x12mr45025942pln.216.1561283143850;
        Sun, 23 Jun 2019 02:45:43 -0700 (PDT)
X-Received: by 2002:a17:902:820c:: with SMTP id x12mr45025872pln.216.1561283142845;
        Sun, 23 Jun 2019 02:45:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561283142; cv=none;
        d=google.com; s=arc-20160816;
        b=dj014P2G96sPKGIzXnxQerDMKUqv/3Cm0IqPzzJwU7P4XZiL8FyMh7CSG7cUC+JhCD
         Xz/Jg09T52QD0zlf9jEo9J9EgVav5w0fQE7W8ILwCHeEHzzais0uXNlQ17C1ayyWHqg8
         9niai475YqPTBVPaGO7vtoVMjQuT/nvwFp6pmCzFFVuML4to67yM75WlKlvDLvdp8N3N
         beb7FjkBQLNB88sITJAHWEeT/byIz2mRDoioSGHJBskDQd3ryFFnq9Z0DPOf3aMHUJmM
         E0AuyTHJe41GIGpL+hUYklDp+LPMMsEAJR0PE2vfAlRcgO9Dq2f3xL+bn95vZ+uk5o17
         ns+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=8jypfSRuf2tzCnQqgBbeT0KAA5/GWGPe8r0gYwybhoA=;
        b=hZdLnWJFvSVZPPVRSmIXAo6jh/MINWQjgUeMopxIm4taH7S84t8vnlDfZidivt+3Gy
         AmHjNe4HkW4QGhyGrBgKv/EuDBWV0RLtkgZKZ7zqIHEu06VddomEzN7IZ4F2R4s0/3kP
         MsMZQLGv41Rr0Pk5paLaxCjqsHfixUrggIN+cXExywW9JFItbOSIf88WFLwwajdddrYW
         oCkMrYnWd+E6fWS2jT6AW1UXDHXmQV8uznMgvVq16+9/21kfC4MfGVCHVcU9KULnmnvl
         IvVjznJAuR0KdHMcHggMqo9DjCQ77BYsHfC7eZ/kejKTVwkJ0UJulTFhQ1y+15yIuMXp
         KjIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MC3Fgqht;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d37sor9292830pla.2.2019.06.23.02.45.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 23 Jun 2019 02:45:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MC3Fgqht;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=8jypfSRuf2tzCnQqgBbeT0KAA5/GWGPe8r0gYwybhoA=;
        b=MC3FgqhtZqqZOa3fca2etHFPOlAX/zHSptGaJf3qBl/azqwKXvi2ibRnsxz9AQxojg
         EICGDT1H4meg+DusobPeLFIRimkWAHJJDK/dlKDhDPS57IyazF6sl+ol2f+XRdncSjTx
         ujEpJ6IHP0e4ia/heO06G73O29JIvv3eBxJ8vsug9U/B1QpbHlPO/jQtEgUyBX1hHmH5
         zhJon/QZMy/0r5wuDPk+yXcnBxYz2434lS1tOAZo8EudlMygn0yOCpQ4Q+dnsj6bSIhB
         TiQ0NJrPR2ggTlL8e/n3bTP2N95KcpYLeCsOcEREJ/hqIDZLZqTrbj00s66H18rrjXqL
         +jKw==
X-Google-Smtp-Source: APXvYqxG5TUNwj0LFGeB24LqT2Ou4ZDW4mig65P9OQLsMEMD34gg1qObLUiUXmLaNRqELQkQNbwqkg==
X-Received: by 2002:a17:902:a517:: with SMTP id s23mr13564230plq.306.1561283142460;
        Sun, 23 Jun 2019 02:45:42 -0700 (PDT)
Received: from bobo.ozlabs.ibm.com ([1.129.156.141])
        by smtp.gmail.com with ESMTPSA id d26sm6181062pfn.29.2019.06.23.02.45.37
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 02:45:42 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Mark Rutland <mark.rutland@arm.com>
Subject: [PATCH 2/3] powerpc/64s: Add p?d_large definitions
Date: Sun, 23 Jun 2019 19:44:45 +1000
Message-Id: <20190623094446.28722-3-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190623094446.28722-1-npiggin@gmail.com>
References: <20190623094446.28722-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The subsequent patch to fix vmalloc_to_page with huge vmap requires
HUGE_VMAP archs to provide p?d_large definitions for the non-pgd page
table levels they support.

Cc: linuxppc-dev@lists.ozlabs.org
Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
Upstream powerpc code does not enable HUGE_VMAP, but the powerpc next
tree has patches, so this patch is required to fix dependency between
this series and powerpc tree in linux-next.

 arch/powerpc/include/asm/book3s/64/pgtable.h | 24 ++++++++++++--------
 1 file changed, 15 insertions(+), 9 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index ccf00a8b98c6..c19c8396a1bd 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -915,6 +915,11 @@ static inline int pud_present(pud_t pud)
 	return !!(pud_raw(pud) & cpu_to_be64(_PAGE_PRESENT));
 }
 
+static inline int pud_large(pud_t pud)
+{
+	return !!(pud_raw(pud) & cpu_to_be64(_PAGE_PTE));
+}
+
 extern struct page *pud_page(pud_t pud);
 extern struct page *pmd_page(pmd_t pmd);
 static inline pte_t pud_pte(pud_t pud)
@@ -958,6 +963,11 @@ static inline int pgd_present(pgd_t pgd)
 	return !!(pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
 }
 
+static inline int pgd_large(pgd_t pgd)
+{
+	return !!(pgd_raw(pgd) & cpu_to_be64(_PAGE_PTE));
+}
+
 static inline pte_t pgd_pte(pgd_t pgd)
 {
 	return __pte_raw(pgd_raw(pgd));
@@ -1083,6 +1093,11 @@ static inline pte_t *pmdp_ptep(pmd_t *pmd)
 #define pmd_mk_savedwrite(pmd)	pte_pmd(pte_mk_savedwrite(pmd_pte(pmd)))
 #define pmd_clear_savedwrite(pmd)	pte_pmd(pte_clear_savedwrite(pmd_pte(pmd)))
 
+static inline int pmd_large(pmd_t pmd)
+{
+	return !!(pmd_raw(pmd) & cpu_to_be64(_PAGE_PTE));
+}
+
 #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 #define pmd_soft_dirty(pmd)    pte_soft_dirty(pmd_pte(pmd))
 #define pmd_mksoft_dirty(pmd)  pte_pmd(pte_mksoft_dirty(pmd_pte(pmd)))
@@ -1151,15 +1166,6 @@ pmd_hugepage_update(struct mm_struct *mm, unsigned long addr, pmd_t *pmdp,
 	return hash__pmd_hugepage_update(mm, addr, pmdp, clr, set);
 }
 
-/*
- * returns true for pmd migration entries, THP, devmap, hugetlb
- * But compile time dependent on THP config
- */
-static inline int pmd_large(pmd_t pmd)
-{
-	return !!(pmd_raw(pmd) & cpu_to_be64(_PAGE_PTE));
-}
-
 static inline pmd_t pmd_mknotpresent(pmd_t pmd)
 {
 	return __pmd(pmd_val(pmd) & ~_PAGE_PRESENT);
-- 
2.20.1

