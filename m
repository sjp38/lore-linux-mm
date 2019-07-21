Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E3A6C76191
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 15:58:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BB012083B
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 15:58:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ODLroZ/h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BB012083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C85C8E0011; Sun, 21 Jul 2019 11:58:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0796A8E0010; Sun, 21 Jul 2019 11:58:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED2088E0011; Sun, 21 Jul 2019 11:58:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA3E68E0010
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 11:58:31 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q11so18289472pll.22
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 08:58:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mu8trQVZC3rHCOtMYrCUpgRKCETCP3JlFKLgFP5GMsg=;
        b=qRAIHoyHfPv8n7p0l/ZhmZP8dbXr1UjQXdTlMZkdaIIZNtwrjF9R+82/adWFJME07i
         V8zS2MQ0wuOcu+DbkZM4kilad2B4mkTb7YLg16KvDgnUb8MaFoCvWZgoaWtoWfxZaq9y
         blt3zw/qt/8yfTLhjFOSzEBjP3+zMYUfE1PwgMNEWNBtNeraco9KsMQMbTFszFCEsi2k
         iBJVS6V7Rm5+cfsipkjEq0ykVJGdWYwM7xvXuQsZqqWn1S/zdW2us09AOSpmZwNu7kID
         /g/zgMbXg9L0v9hprqArk7k1DtFGG/pDwuPOkALpXi5vWitGC15uFKhdQGY7pcJwhe1q
         POcQ==
X-Gm-Message-State: APjAAAUxdxpJ3sl3VYPg2VhmGcjX8PowXnIMiw+MrPx23Y2Y7CKtvfKQ
	5i0IsWDYyc9PEjNVeJmEHxbt03yLdXCovxlKlMyUHKwGq2bBgrHcJBXQhR4izUFxeWJRroK0Nnk
	B7YeuN03zZgm3elB1TfqomQL6SuBH3jnmbrUZ+fm57KcskDj5qHQFoJMdtGhc3/d7dg==
X-Received: by 2002:a17:902:2d01:: with SMTP id o1mr72098477plb.105.1563724711340;
        Sun, 21 Jul 2019 08:58:31 -0700 (PDT)
X-Received: by 2002:a17:902:2d01:: with SMTP id o1mr72098392plb.105.1563724710351;
        Sun, 21 Jul 2019 08:58:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563724710; cv=none;
        d=google.com; s=arc-20160816;
        b=vZy+ydC+5K9omXjiH8ihSfG/OUHVbpNCIX/iKzHh4uJKxnVYcSW26xl8dUMGwxzEdO
         QaDWaVSLNdMnQric/UwUt69hBCnbB/XWLK8piq4aLBK1sTpGUEyKj9I+JVdXnILBN4oS
         dHOzqZOrT6NWimbqVga7lODbHF3m9Y1Xq/Z9AXFF3lHM9ok/V1tf4jw9y5xFXBM9+Ipa
         k6yVdaT2HK41rQe9JmrQ4JsVY8wbGgU3sy1aw+36vt4Oozy7LbVMCyPrD+LBf4SqCmdq
         eTa8Vuu+TW7e0UQe1Vp9P3AlX7YVCAmd0w0hHTigOrptXMOQglW1sJdSz2vCkmC5l7uB
         F41Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=mu8trQVZC3rHCOtMYrCUpgRKCETCP3JlFKLgFP5GMsg=;
        b=OLgFBKM6Eflmlp5Yz8sYZhO+9o4cZNVzDNt+G3yPnWWEFqYJ+xURUdDzdp22b8UuFI
         U6dXAXqqedSkO6JhDwS9+LOWIwhm/MKW8Dg+tz7xdLebBjlT+Rc2/HxtXUZOEAHxu3FC
         NzYwRpS+ny31qZlgEtiJ7+uiUF8UjU3WSICC6S7AFjM72ASFceBuBPgoOitQEkxDEuSz
         TX7vp8AbOLlwqb9pa1GA3Mzf8qi2hcoPVGUiRzX+cg1HTYLdDzMSjJtBzNZvcExTTZJA
         OSlhO0C6RJmZtveqxN14VuHaFUtSBSMqSzH97b+EcMDh2kKiXY8HxuKezvbyG9pSecv6
         yTiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ODLroZ/h";
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cu6sor44426656pjb.22.2019.07.21.08.58.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 21 Jul 2019 08:58:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ODLroZ/h";
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=mu8trQVZC3rHCOtMYrCUpgRKCETCP3JlFKLgFP5GMsg=;
        b=ODLroZ/h+hP6Y33PcgSXD4q2Uc8RcP/LdSQozj6vnDx90z1Mq6K/foEe5nz7ZE2BPd
         yYZAMSLyYG3vQ0iOmeXcDLNnWfNQH4g6AMONx5mDjWIdel6bpziU1NAHYdyK2pZ378Rr
         FZ2ZeYBK/Uor03e7IT/JubBVBKBTHhPcV8cRRS95AnmkWrOA5HCwpl5IfUJ32bAZkYFy
         kLT059ALWFeHtBbDtT1ZXSm/q583gn6n+Z++Kw7Pm61/vOy0/vDZ6m9Jy6b1Uk8C8yb2
         wMujseQCu+jXWT0qW/n5t4vm67DuuywYUODpEzZ8ow7y4QxZPfogWyGgMHcWonCunkUn
         phfg==
X-Google-Smtp-Source: APXvYqwC3lbzN6ZeQmPUeK90Wp81J3UzSILb/l6kA0SmEh/tiLeanHZIQoe+bvHFOO1ZCx7hgtXRQg==
X-Received: by 2002:a17:90a:bf08:: with SMTP id c8mr71922342pjs.75.1563724710070;
        Sun, 21 Jul 2019 08:58:30 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id w22sm38827754pfi.175.2019.07.21.08.58.28
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 21 Jul 2019 08:58:29 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: arnd@arndb.de,
	sivanich@sgi.com,
	gregkh@linuxfoundation.org
Cc: ira.weiny@intel.com,
	jhubbard@nvidia.com,
	jglisse@redhat.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Bharath Vedartham <linux.bhar@gmail.com>
Subject: [PATCH 3/3] sgi-gru: Use __get_user_pages_fast in atomic_pte_lookup
Date: Sun, 21 Jul 2019 21:28:05 +0530
Message-Id: <1563724685-6540-4-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1563724685-6540-1-git-send-email-linux.bhar@gmail.com>
References: <1563724685-6540-1-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

*pte_lookup functions get the physical address for a given virtual
address by getting a physical page using gup and use page_to_phys to get
the physical address.

Currently, atomic_pte_lookup manually walks the page tables. If this
function fails to get a physical page, it will fall back too
non_atomic_pte_lookup to get a physical page which uses the slow gup
path to get the physical page.

Instead of manually walking the page tables use __get_user_pages_fast
which does the same thing and it does not fall back to the slow gup
path.

This is largely inspired from kvm code. kvm uses __get_user_pages_fast
in hva_to_pfn_fast function which can run in an atomic context.

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
 drivers/misc/sgi-gru/grufault.c | 39 +++++----------------------------------
 1 file changed, 5 insertions(+), 34 deletions(-)

diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index 75108d2..121c9a4 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -202,46 +202,17 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
 static int atomic_pte_lookup(struct vm_area_struct *vma, unsigned long vaddr,
 	int write, unsigned long *paddr, int *pageshift)
 {
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
+	struct page *page;
 
-	pmdp = pmd_offset(pudp, vaddr);
-	if (unlikely(pmd_none(*pmdp)))
-		goto err;
-#ifdef CONFIG_X86_64
-	if (unlikely(pmd_large(*pmdp)))
-		pte = *(pte_t *) pmdp;
-	else
-#endif
-		pte = *pte_offset_kernel(pmdp, vaddr);
+	*pageshift = is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
 
-	if (unlikely(!pte_present(pte) ||
-		     (write && (!pte_write(pte) || !pte_dirty(pte)))))
+	if (!__get_user_pages_fast(vaddr, 1, write, &page))
 		return 1;
 
-	*paddr = pte_pfn(pte) << PAGE_SHIFT;
-
-	*pageshift = is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
+	*paddr = page_to_phys(page);
+	put_user_page(page);
 
 	return 0;
-
-err:
-	return 1;
 }
 
 static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
-- 
2.7.4

