Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC9E3C31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 08:51:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7101220848
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 08:51:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BX24XRnD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7101220848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 120D78E0005; Mon, 17 Jun 2019 04:51:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 081CD8E0001; Mon, 17 Jun 2019 04:51:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8B0D8E0005; Mon, 17 Jun 2019 04:51:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3F618E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 04:51:28 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y7so6668627pfy.9
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 01:51:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=L8mWMJ9jILM0VSdVVzcyHa6WZylZDmRmVi1FUCOSEVY=;
        b=TknkCCUMCcygScojrqxNcZatzrlU1ugJqULnOi/O3zQa8zM6RvHD3Ko4zOCfm4PhH7
         Jl39FDJr7l8PMFN+5QYAyGhGUeXz7/Fzc2ujaMvblFstVUO9bTUnvp9N6fftw4chH8wp
         nICylAQXOVChEy6q4eWXinF21NUi8r+sbj06xS6zV3dZytjfuoGdCHkh7+ooNSwmeEgD
         aKCAQa/EjLSnHOIMjAwHVFqWujL6w+bq7Zn6hZiRxidz/i00DLIj+nAPZ5+2v8BYU88t
         aeLAvOGGZEdSDILkPeHlYhGPyRHV7KSRUnQJIX4U5PAVnYasnlBySik3ukvhm2MsKVDX
         Ru8w==
X-Gm-Message-State: APjAAAV+ZX9KVULxVd1B3gppqd4Yih7s/sCE/8WjoNNjaM1jpNmHYfsf
	XobI6ghdHgyaF0U0PfHUWb8HzyoidI4M9lyr87JJCnNqYUm3qicZn9Lnmg8rt7G6Th6pYJ1cRcf
	5Mw3SXGOnxJJUACupqbFQkhZIo4+iCcrexsGbZ6Xio4o0jVuvKquGVKAHHPujMuc=
X-Received: by 2002:a63:29c2:: with SMTP id p185mr19030032pgp.216.1560761488295;
        Mon, 17 Jun 2019 01:51:28 -0700 (PDT)
X-Received: by 2002:a63:29c2:: with SMTP id p185mr19029970pgp.216.1560761487006;
        Mon, 17 Jun 2019 01:51:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560761486; cv=none;
        d=google.com; s=arc-20160816;
        b=b0WCnL4LG21Qb+lBi0mhVJl9ZEcj4XO6IUbZ+iRg5cTllH3K6pvb9DeD12A5m3JuEB
         ZT0rLW0IeABbvVZITiA3jUYwydi3KTqQ++XhHu++D3ExPKkLz+Q/F+OMoA32yH08o7X/
         xmjD4lp4ZBwmyCIA7f1+a7qTGx2onNZc/X91TmU3u+129F2CL6XaiDyqcZp/WtU9NyiW
         xwLYPrMXFAHG9uldu86CO9TIKajcLp4k1f0lVJhBR+L15luOS7J4vX3AE+3VXuwSKWRL
         M01Bes66/BcXSanLpsI58lsLO+Hf0ppkQzWnP4wQ4ipaEIEA/+0RQ+RCiZeQXMQ0U0uw
         gfxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from:sender
         :dkim-signature;
        bh=L8mWMJ9jILM0VSdVVzcyHa6WZylZDmRmVi1FUCOSEVY=;
        b=vl/ik5wziLe4QlXmHbZiARsbtMjtgVZzRVV8HvIGWH9hkg6jhdB1cis+dBk+TrKhLq
         84t99uaQD5bLRvehHFq6sxRcHeDxaLf/NiTgaSqRrxCs+aV+JdqtpBTgTzlWLOJfBnwo
         X7S6A8bRuAct4n+7XvemNAupm/BJNxE2tb0vQEeA/ZdUUNakncsrCmL1Bwp69DW0oyOQ
         juSpveyrc8J2coR21RKkpDKwrD/NH3zs5gTEaBdOfb3X8lQJHcVLYJOcQIh2m1/qCChn
         KlmvxKNok8sfGn5CnwR3+UedCx0NhnLj9Um8k5qyCKZnoBpPgutZbuHSja4YZobiNoKi
         e2gA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BX24XRnD;
       spf=pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nao.horiguchi@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h63sor12791443pjb.6.2019.06.17.01.51.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 01:51:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BX24XRnD;
       spf=pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nao.horiguchi@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=L8mWMJ9jILM0VSdVVzcyHa6WZylZDmRmVi1FUCOSEVY=;
        b=BX24XRnD9mcuxU5y8Oa30zqFIc5pDvtwSfb7rZGmpl3imko20lYhU//Bls+Zloo2y5
         nxMjyClpkK8fjDyizpK7Jvcys6+zr4O7u1rsBPeQb9aC85PkA+qGhdTvSvqQ3yTnU8NQ
         MzDTKxJ3m5Bp4rKftQoCYUNPPoDv3hpaT5AlsaA8f6atLoo3HBA7of+OxJJj/xxTM6ii
         hyM7jJgRct8/DwZKm7UZp4PrQ8jHR3B4qHz9cnERywIvc+poTqpaGNeGpTJXL5j9Ezro
         MQSWz3P0qgJFYLArRvOO1ftRTcJ2sfw8G2mXj/+xgMJic0iYtQqU0Im4lg2swjBn+aRB
         uArQ==
X-Google-Smtp-Source: APXvYqzHCOPshltv7hAFRfCkbOCP9mHhWYQ8Pjr/OptiujEWUn1vBUKUu0mplvCVt9MCeghIvwqnsg==
X-Received: by 2002:a17:90a:30e4:: with SMTP id h91mr24031628pjb.37.1560761486527;
        Mon, 17 Jun 2019 01:51:26 -0700 (PDT)
Received: from www9186uo.sakura.ne.jp (www9186uo.sakura.ne.jp. [153.121.56.200])
        by smtp.gmail.com with ESMTPSA id d4sm9443514pju.19.2019.06.17.01.51.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 01:51:26 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	xishi.qiuxishi@alibaba-inc.com,
	"Chen, Jerry T" <jerry.t.chen@intel.com>,
	"Zhuo, Qiuxu" <qiuxu.zhuo@intel.com>,
	linux-kernel@vger.kernel.org,
	Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH v3 2/2] mm: hugetlb: soft-offline: dissolve_free_huge_page() return zero on !PageHuge
Date: Mon, 17 Jun 2019 17:51:16 +0900
Message-Id: <1560761476-4651-3-git-send-email-n-horiguchi@ah.jp.nec.com>
X-Mailer: git-send-email 2.7.0
In-Reply-To: <1560761476-4651-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1560761476-4651-1-git-send-email-n-horiguchi@ah.jp.nec.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

madvise(MADV_SOFT_OFFLINE) often returns -EBUSY when calling soft offline
for hugepages with overcommitting enabled. That was caused by the suboptimal
code in current soft-offline code. See the following part:

    ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
                            MIGRATE_SYNC, MR_MEMORY_FAILURE);
    if (ret) {
            ...
    } else {
            /*
             * We set PG_hwpoison only when the migration source hugepage
             * was successfully dissolved, because otherwise hwpoisoned
             * hugepage remains on free hugepage list, then userspace will
             * find it as SIGBUS by allocation failure. That's not expected
             * in soft-offlining.
             */
            ret = dissolve_free_huge_page(page);
            if (!ret) {
                    if (set_hwpoison_free_buddy_page(page))
                            num_poisoned_pages_inc();
            }
    }
    return ret;

Here dissolve_free_huge_page() returns -EBUSY if the migration source page
was freed into buddy in migrate_pages(), but even in that case we actually
has a chance that set_hwpoison_free_buddy_page() succeeds. So that means
current code gives up offlining too early now.

dissolve_free_huge_page() checks that a given hugepage is suitable for
dissolving, where we should return success for !PageHuge() case because
the given hugepage is considered as already dissolved.

This change also affects other callers of dissolve_free_huge_page(),
which are cleaned up together.

Reported-by: Chen, Jerry T <jerry.t.chen@intel.com>
Tested-by: Chen, Jerry T <jerry.t.chen@intel.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Fixes: 6bc9b56433b76 ("mm: fix race on soft-offlining")
Cc: <stable@vger.kernel.org> # v4.19+
---
ChangeLog v2->v3:
- add PageHuge check in dissolve_free_huge_page() outside hugetlb_lock
- update comment on dissolve_free_huge_page() about return value
---
 mm/hugetlb.c        | 29 ++++++++++++++++++++---------
 mm/memory-failure.c |  5 +----
 2 files changed, 21 insertions(+), 13 deletions(-)

diff --git v5.2-rc4/mm/hugetlb.c v5.2-rc4_patched/mm/hugetlb.c
index ac843d3..ede7e7f 100644
--- v5.2-rc4/mm/hugetlb.c
+++ v5.2-rc4_patched/mm/hugetlb.c
@@ -1510,16 +1510,29 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
 
 /*
  * Dissolve a given free hugepage into free buddy pages. This function does
- * nothing for in-use (including surplus) hugepages. Returns -EBUSY if the
- * dissolution fails because a give page is not a free hugepage, or because
- * free hugepages are fully reserved.
+ * nothing for in-use hugepages and non-hugepages.
+ * This function returns values like below:
+ *
+ *  -EBUSY: failed to dissolved free hugepages or the hugepage is in-use
+ *          (allocated or reserved.)
+ *       0: successfully dissolved free hugepages or the page is not a
+ *          hugepage (considered as already dissolved)
  */
 int dissolve_free_huge_page(struct page *page)
 {
 	int rc = -EBUSY;
 
+	/* Not to disrupt normal path by vainly holding hugetlb_lock */
+	if (!PageHuge(page))
+		return 0;
+
 	spin_lock(&hugetlb_lock);
-	if (PageHuge(page) && !page_count(page)) {
+	if (!PageHuge(page)) {
+		rc = 0;
+		goto out;
+	}
+
+	if (!page_count(page)) {
 		struct page *head = compound_head(page);
 		struct hstate *h = page_hstate(head);
 		int nid = page_to_nid(head);
@@ -1564,11 +1577,9 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order) {
 		page = pfn_to_page(pfn);
-		if (PageHuge(page) && !page_count(page)) {
-			rc = dissolve_free_huge_page(page);
-			if (rc)
-				break;
-		}
+		rc = dissolve_free_huge_page(page);
+		if (rc)
+			break;
 	}
 
 	return rc;
diff --git v5.2-rc4/mm/memory-failure.c v5.2-rc4_patched/mm/memory-failure.c
index 8ee7b16..d9cc660 100644
--- v5.2-rc4/mm/memory-failure.c
+++ v5.2-rc4_patched/mm/memory-failure.c
@@ -1856,11 +1856,8 @@ static int soft_offline_in_use_page(struct page *page, int flags)
 
 static int soft_offline_free_page(struct page *page)
 {
-	int rc = 0;
-	struct page *head = compound_head(page);
+	int rc = dissolve_free_huge_page(page);
 
-	if (PageHuge(head))
-		rc = dissolve_free_huge_page(page);
 	if (!rc) {
 		if (set_hwpoison_free_buddy_page(page))
 			num_poisoned_pages_inc();
-- 
2.7.0

