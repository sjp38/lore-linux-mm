Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 989EBC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 15:40:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 510AE217F4
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 15:40:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JnpuD7Lh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 510AE217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD4938E0007; Tue, 30 Jul 2019 11:40:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DABAD8E0001; Tue, 30 Jul 2019 11:40:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9A438E0007; Tue, 30 Jul 2019 11:40:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 95C648E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 11:40:11 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f25so40995077pfk.14
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 08:40:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VL69OhOnAwL0XYVUd4iryHVhyGAPtRV3TIOYsddsZuM=;
        b=hZ4haluAwgeYR4swzOLd6SJvvXwUWrbMZYvcSBzuQq9hpJ4sQDL1nw7J6l9rJcfOUQ
         4MMeE5wkDk+h72DalB+BAWI54CmhuAvrakGBtiOeRnjwYtIWGUJPk7qEVyDMeQoTM48h
         Axs9WRAP96ir9nmsVFlwsKjt6vJ7AAbgG3W+7lLhIPVxJQoECmFjLxkX8YJybI4GGtnQ
         5RXNlgGIpwPAj0RfRYSUZ0hIexp88bjn10v0qs1jIqFcebg5LpuFiQn1kJlQGoL9vHOV
         D2AVnGCi1/QlygJsJfQLOMf5530ZWcEebU5Yw8pq5dVvnxbd5+KqmLDZGpQI479wT0r+
         IVvA==
X-Gm-Message-State: APjAAAUYUoXBE+6R9Zvj9Axe9J6h4xY+YNd2Q9Bf7/EEv+sKB40asc9N
	Ej6i8+qj1tEfoFP/zp4KH0CKTWlhU7d2AdO8c8m2ZliDZ1NpyvXj7cqeH8VOpDEzDAauj5ziKWC
	y7ayAzjgusavQU7Om0bt4FWwb74/M8HzmeuCl38TrDAGeS8RHJp7bXDt9SQNf9yTwlQ==
X-Received: by 2002:aa7:8641:: with SMTP id a1mr42691931pfo.177.1564501211155;
        Tue, 30 Jul 2019 08:40:11 -0700 (PDT)
X-Received: by 2002:aa7:8641:: with SMTP id a1mr42691843pfo.177.1564501209884;
        Tue, 30 Jul 2019 08:40:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564501209; cv=none;
        d=google.com; s=arc-20160816;
        b=L2o36lbqhsUxIeyzlqUij8qbX5JO9xU3laPhA0XhnSLhSlRIP0CqCTQKC5bdclBSkq
         f805uBiAv0BBKk+f1U4EYeDZgL0c7R3EzchMI42hTfw3jQg0FziFM1o25tiWu05WfeMt
         EkPsA9HwYN/+mIVHfMZDOiTYod0LozujX+mo1Don/J39YQOTBNXGG+A+QtOJ5Ql57QJg
         nOOskNlkkRtHlNwoCqO8VKXIVTZJIF6mjwGbTz0vWoXWtYkku0J5vhMc+dYw5KnF35ne
         j5ARu10s9BVSz4N1UHpauKA1U4eteehY9EhCLV2mKGeQSJRXIcEuajOB7jjKd9F234eQ
         ZHYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=VL69OhOnAwL0XYVUd4iryHVhyGAPtRV3TIOYsddsZuM=;
        b=IaOn8BSDVNr6xNerqGHVVeiCoMRnV1pxk8jZKtYfXIt94uU5eyLBY+1B3cgk9/glA1
         TgJu8flM7dj371+3l09JtDXd3YuI0a+kLLXLTnhTpJncDUk/zBkrPQ0iDwoOamk9eyxu
         l5e2EVNH74MSce4USmV+cOLxYg7v1xJyyK9C85e/0y+PphbrzirsOI6Bw/xxuPmmbjeq
         p2gqiMJ8mt7jHCCoN4cz5pt9yUGuQ7WWjCuwt4aYzORSt3CpYqxtztVsp7DXmsjv47Fz
         I/1oV6PbZBJUKAfw8Jte2/pud4iDFis/ZPKH6ffr/u7yLszCu/8948nXIylt3shzWUlt
         MkGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JnpuD7Lh;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b17sor77093328pjz.4.2019.07.30.08.40.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 08:40:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JnpuD7Lh;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=VL69OhOnAwL0XYVUd4iryHVhyGAPtRV3TIOYsddsZuM=;
        b=JnpuD7Lhn/qE7XJv7n7efhB9Y1FFuZ2F4tOy7xPNk3kBOJquUa5ZdXVE2CaWJEsrVh
         yMfhPN5d3zlY7lks50LSVx43a9lRWN3fEw+2mRlkOtiPyWUiI+jM084e7+I7io06LwW4
         kK68uPBHyuRVpRWRsz+aFk7D++UOdv1Lu2AkC6wYhYUrHLpHRAcI7yLQGzf4fxZ1UvEf
         MqI3XIEqPLJYE3iB6QcnVLgMG3zmHV68RS5MYxD0/c3AeU0Dct6278t6LVZ1T4B0j1Ew
         DlcnLz7xXh4kbs/9etasPC7viCglq3IR4SDSVF2nF9sw0Uiur+vimuBZvOX2mrvMzSNT
         29Gw==
X-Google-Smtp-Source: APXvYqxzMdxms+bc78CL5gsMck7qwh7ISTe+alN65NyxUVXjwyMgBoEubKQB6gleAbfiP0OgFFPVqg==
X-Received: by 2002:a17:90a:8a0b:: with SMTP id w11mr116924577pjn.125.1564501209516;
        Tue, 30 Jul 2019 08:40:09 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id 67sm36860864pfd.177.2019.07.30.08.40.08
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Jul 2019 08:40:09 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: sivanich@sgi.com,
	arnd@arndb.de
Cc: ira.weiny@intel.com,
	jhubbard@nvidia.com,
	jglisse@redhat.com,
	gregkh@linuxfoundation.org,
	william.kucharski@oracle.com,
	hch@lst.de,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org,
	Bharath Vedartham <linux.bhar@gmail.com>
Subject: [Linux-kernel-mentees][PATCH v4 1/1] sgi-gru: Remove *pte_lookup functions
Date: Tue, 30 Jul 2019 21:09:30 +0530
Message-Id: <1564501170-6830-2-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1564501170-6830-1-git-send-email-linux.bhar@gmail.com>
References: <1564501170-6830-1-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The *pte_lookup functions can be removed and be easily replaced with
get_user_pages_fast functions. In the case of atomic lookup,
__get_user_pages_fast is used which does not fall back to slow
get_user_pages. get_user_pages_fast on the other hand tries to use
__get_user_pages_fast but fallbacks to slow get_user_pages if
__get_user_pages_fast fails.

Also unnecessary ifdefs to check for CONFIG_HUGETLB is removed as the
check is redundant.

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: William Kucharski <william.kucharski@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel-mentees@lists.linuxfoundation.org
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: William Kucharski <william.kucharski@oracle.com>
Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
This is a fold of the 3 patches in the v2 patch series.
The review tags were given to the individual patches.

Changes since v3
	- Used gup flags in get_user_pages_fast rather than
	boolean flags.
---
 drivers/misc/sgi-gru/grufault.c | 112 +++++++++-------------------------------
 1 file changed, 24 insertions(+), 88 deletions(-)

diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index 4b713a8..304e9c5 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -166,96 +166,20 @@ static void get_clear_fault_map(struct gru_state *gru,
 }
 
 /*
- * Atomic (interrupt context) & non-atomic (user context) functions to
- * convert a vaddr into a physical address. The size of the page
- * is returned in pageshift.
- * 	returns:
- * 		  0 - successful
- * 		< 0 - error code
- * 		  1 - (atomic only) try again in non-atomic context
- */
-static int non_atomic_pte_lookup(struct vm_area_struct *vma,
-				 unsigned long vaddr, int write,
-				 unsigned long *paddr, int *pageshift)
-{
-	struct page *page;
-
-#ifdef CONFIG_HUGETLB_PAGE
-	*pageshift = is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
-#else
-	*pageshift = PAGE_SHIFT;
-#endif
-	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <= 0)
-		return -EFAULT;
-	*paddr = page_to_phys(page);
-	put_page(page);
-	return 0;
-}
-
-/*
- * atomic_pte_lookup
+ * mmap_sem is already helod on entry to this function. This guarantees
+ * existence of the page tables.
  *
- * Convert a user virtual address to a physical address
  * Only supports Intel large pages (2MB only) on x86_64.
- *	ZZZ - hugepage support is incomplete
- *
- * NOTE: mmap_sem is already held on entry to this function. This
- * guarantees existence of the page tables.
+ *	ZZZ - hugepage support is incomplete.
  */
-static int atomic_pte_lookup(struct vm_area_struct *vma, unsigned long vaddr,
-	int write, unsigned long *paddr, int *pageshift)
-{
-	pgd_t *pgdp;
-	p4d_t *p4dp;
-	pud_t *pudp;
-	pmd_t *pmdp;
-	pte_t pte;
-
-	pgdp = pgd_offset(vma->vm_mm, vaddr);
-	if (unlikely(pgd_none(*pgdp)))
-		goto err;
-
-	p4dp = p4d_offset(pgdp, vaddr);
-	if (unlikely(p4d_none(*p4dp)))
-		goto err;
-
-	pudp = pud_offset(p4dp, vaddr);
-	if (unlikely(pud_none(*pudp)))
-		goto err;
-
-	pmdp = pmd_offset(pudp, vaddr);
-	if (unlikely(pmd_none(*pmdp)))
-		goto err;
-#ifdef CONFIG_X86_64
-	if (unlikely(pmd_large(*pmdp)))
-		pte = *(pte_t *) pmdp;
-	else
-#endif
-		pte = *pte_offset_kernel(pmdp, vaddr);
-
-	if (unlikely(!pte_present(pte) ||
-		     (write && (!pte_write(pte) || !pte_dirty(pte)))))
-		return 1;
-
-	*paddr = pte_pfn(pte) << PAGE_SHIFT;
-#ifdef CONFIG_HUGETLB_PAGE
-	*pageshift = is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
-#else
-	*pageshift = PAGE_SHIFT;
-#endif
-	return 0;
-
-err:
-	return 1;
-}
-
 static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
 		    int write, int atomic, unsigned long *gpa, int *pageshift)
 {
 	struct mm_struct *mm = gts->ts_mm;
 	struct vm_area_struct *vma;
 	unsigned long paddr;
-	int ret, ps;
+	int ret;
+	struct page *page;
 
 	vma = find_vma(mm, vaddr);
 	if (!vma)
@@ -263,21 +187,33 @@ static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
 
 	/*
 	 * Atomic lookup is faster & usually works even if called in non-atomic
-	 * context.
+	 * context. get_user_pages_fast does atomic lookup before falling back to
+	 * slow gup.
 	 */
 	rmb();	/* Must/check ms_range_active before loading PTEs */
-	ret = atomic_pte_lookup(vma, vaddr, write, &paddr, &ps);
-	if (ret) {
-		if (atomic)
+	if (atomic) {
+		ret = __get_user_pages_fast(vaddr, 1, write, &page);
+		if (!ret)
 			goto upm;
-		if (non_atomic_pte_lookup(vma, vaddr, write, &paddr, &ps))
+	} else {
+		ret = get_user_pages_fast(vaddr, 1, write ? FOLL_WRITE : 0, &page);
+		if (!ret)
 			goto inval;
 	}
+
+	paddr = page_to_phys(page);
+	put_user_page(page);
+
+	if (unlikely(is_vm_hugetlb_page(vma)))
+		*pageshift = HPAGE_SHIFT;
+	else
+		*pageshift = PAGE_SHIFT;
+
 	if (is_gru_paddr(paddr))
 		goto inval;
-	paddr = paddr & ~((1UL << ps) - 1);
+	paddr = paddr & ~((1UL << *pageshift) - 1);
 	*gpa = uv_soc_phys_ram_to_gpa(paddr);
-	*pageshift = ps;
+
 	return VTOP_SUCCESS;
 
 inval:
-- 
2.7.4

