Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0F88C282DD
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 08:18:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A2512082E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 08:18:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cyT9+FXV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A2512082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C2E76B026E; Mon, 10 Jun 2019 04:18:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 150B36B026F; Mon, 10 Jun 2019 04:18:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBA5C6B0270; Mon, 10 Jun 2019 04:18:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B0BD76B026E
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 04:18:17 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i26so6707880pfo.22
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 01:18:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=AUEXYFdzqEkxEy/SrRksCebP4SkLARCEQIzpXvm3TGE=;
        b=ja9s+xOmpoii6ZvqRgW7GbHcnDK1zh3/dclrb0Pu0WleCPG5+Vs1JqdiVvqLPXsW9a
         uGBilUhEOsVz0nMGVSgQ9pGSFd4jS/fdKZq9O/OzzSDGtIH0AYniuj0YXyjz/oeeeG2F
         gWJ6s5Q2VT3n5uj5xae3PqaTc4W2UlPUh4l90D1/BYhUc7IdaDq4nTt5333o2gymaz4/
         zLV/MH/O66UwF9GjHMy6DMuX5QODRq/CIEekwJoVEoVXRqGn3QGZvceiS0j7dCr0eeuj
         PQrAdS417PVqpizXrrFxLvooP4yZgJe3bUre8RG8wCpHgEZ5VATLo1XszAs6gVCWHkxI
         AwbQ==
X-Gm-Message-State: APjAAAXy0gcqQIsAB/L0hxuToW4SK0Et8xsiFGzMw2YzTqD2AGSX7bD2
	7QbItwOE+zV0g15pBlKC2N1SNKV8LI/i6pgXwY+WDdxyLF/Lw8hHI+pvUMbnGQ963x0daP9ZVND
	fYQ9us9JNzR1LHNW3d2X52G+geqSU5P7hinxvG255TV52htAr9Ovp7A/rjQ5KWGQ=
X-Received: by 2002:a65:6543:: with SMTP id a3mr13743940pgw.300.1560154697229;
        Mon, 10 Jun 2019 01:18:17 -0700 (PDT)
X-Received: by 2002:a65:6543:: with SMTP id a3mr13743891pgw.300.1560154696296;
        Mon, 10 Jun 2019 01:18:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560154696; cv=none;
        d=google.com; s=arc-20160816;
        b=uvqrwiBLsypTat7qwco8JS/T0J7fZ+/1Y94J1KvxrcwAv35jWz0jUZkc28fb0RwWg0
         8XhNgqDDrzaQqMFKFuSqwj3TVjT5kZIVZEf7Roit60E5kAbyjBWGbT1BNMTGCTjOuSZw
         nrX1DBifE0nu6W4TLy9X5D/oWeHc3UfgyWVghy5iYTqiv7iKvlENlH44G8r6U+sY8aOt
         +1JeVMLZRLxFwI0Ea8rQDPjstTak8c+XoXcMO8ExNzd+mJ77wkHNT56NlqrCMPB6kwSK
         isR0cr64Lt5nX7AQ1+Wg/E5yC+RSLnFD9FREL08g5h0Ltdp8c/9WTBUywLVJHYJAYMdY
         a3rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from:sender
         :dkim-signature;
        bh=AUEXYFdzqEkxEy/SrRksCebP4SkLARCEQIzpXvm3TGE=;
        b=FwkrVHMmiXUATmJofzmTfB9psZF1/BpZ5RHShYLtVsZZnRQthvZHo16VJdwcp7X9VG
         EaRGv2yMckEgg90rCZoKpi4yt69JA+sLF/Pdo5M3+glNb+mNOc7ffzozk4e94ScSCRjT
         tqroJzPXT5C9SsvCw1DwdjIY8UjLI/ns9kFsUuP8BZ7OoEtULw3ydmFuCe/pjMNbsRbc
         SeTe1nHBSr9Vos6mIK5YW4+5l7OqTHwTA2MtjstmuZLAfp99wdqrzAI90Q921lMr7Wvd
         HuZym5mWTzFzhL+XPYs1h7I2r+47MxzHsO5/t4SG9vJDeA8Aod8ws/qG1ay3Tw+64Ptw
         3VvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cyT9+FXV;
       spf=pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nao.horiguchi@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b7sor11289216pjc.14.2019.06.10.01.18.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 01:18:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cyT9+FXV;
       spf=pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nao.horiguchi@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=AUEXYFdzqEkxEy/SrRksCebP4SkLARCEQIzpXvm3TGE=;
        b=cyT9+FXVxPoRnYYM8NvG7UpT1wnkiyplF8ecf3XPY/u/iqmkqnAAnZdWqNjLriS4zz
         DUdqN/LhfFSR8pCUIZfJo3MtBe9cBnLzQLwOKqZNmC+R1uzGgA0p0x3M6lmox17kn8Pu
         yLw+iT04RtIlyY/CwHAO+BI0jY/bNRZzg5683q5N717NtzHnBxUtDRRRGZEK9W3+kcNg
         QB3bMXVVpC2s5RuTVAETr1E5R7YdWUqROVDoZTFil92c5xHZSHAP5fM6aOMluEw9nUyI
         zpAur0kHuMojjNVkk6i+wRivdxWSYnTyOG4FjIZsXSCXzEu+xXGrUSOa8ghSoVG65hTL
         I/Ag==
X-Google-Smtp-Source: APXvYqyTdzkDJdmW8uNKjt3L6e7/xcwf7fBS/5gUCPV86PSF7LWpuZOi0KDU65PjDXzRwVj6GfgwHQ==
X-Received: by 2002:a17:90a:8982:: with SMTP id v2mr19823294pjn.136.1560154695802;
        Mon, 10 Jun 2019 01:18:15 -0700 (PDT)
Received: from www9186uo.sakura.ne.jp (www9186uo.sakura.ne.jp. [153.121.56.200])
        by smtp.gmail.com with ESMTPSA id j7sm9525014pfa.184.2019.06.10.01.18.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 01:18:15 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	xishi.qiuxishi@alibaba-inc.com,
	"Chen, Jerry T" <jerry.t.chen@intel.com>,
	"Zhuo, Qiuxu" <qiuxu.zhuo@intel.com>,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 2/2] mm: hugetlb: soft-offline: dissolve_free_huge_page() return zero on !PageHuge
Date: Mon, 10 Jun 2019 17:18:06 +0900
Message-Id: <1560154686-18497-3-git-send-email-n-horiguchi@ah.jp.nec.com>
X-Mailer: git-send-email 2.7.0
In-Reply-To: <1560154686-18497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1560154686-18497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
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
 mm/hugetlb.c        | 15 +++++++++------
 mm/memory-failure.c |  5 +----
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git v5.2-rc3/mm/hugetlb.c v5.2-rc3_patched/mm/hugetlb.c
index ac843d3..048d071 100644
--- v5.2-rc3/mm/hugetlb.c
+++ v5.2-rc3_patched/mm/hugetlb.c
@@ -1519,7 +1519,12 @@ int dissolve_free_huge_page(struct page *page)
 	int rc = -EBUSY;
 
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
@@ -1564,11 +1569,9 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 
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
diff --git v5.2-rc3/mm/memory-failure.c v5.2-rc3_patched/mm/memory-failure.c
index 7ea485e..3a83e27 100644
--- v5.2-rc3/mm/memory-failure.c
+++ v5.2-rc3_patched/mm/memory-failure.c
@@ -1859,11 +1859,8 @@ static int soft_offline_in_use_page(struct page *page, int flags)
 
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

