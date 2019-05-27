Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 585ADC28CBF
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 06:06:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12898204EC
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 06:06:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OlkrPsci"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12898204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A18116B000C; Mon, 27 May 2019 02:06:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C7746B0266; Mon, 27 May 2019 02:06:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DF2B6B026B; Mon, 27 May 2019 02:06:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5645F6B000C
	for <linux-mm@kvack.org>; Mon, 27 May 2019 02:06:48 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 14so11106478pgo.14
        for <linux-mm@kvack.org>; Sun, 26 May 2019 23:06:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id;
        bh=J+flJg4D+B292+R0mjnCGOvi2ClGFqVNzhwfO4APIzk=;
        b=QDwP0A0fannLsfsvg27gaGDyoGz4yL/EDl4n8LQRe2SKMWLGTek86E++XAh9kfEMtG
         R3fM/SFGHwzlKORXWSSnevyV006MMDmFfCDEkjudUhUFR5DpvALto692UTzZLkz82l9e
         SPTC07e4cqFu44IyXiG0OynASMOlgIui48FqDSQy0p2cj1qkP8XE/pnBsP5BUMJ9Tzv4
         nOnWGm3qJOEezlBOz6CsYLJRoRla6cNsPXEq1JzBbWgAXxCvk9IxfXK1usUPqoOMhwvV
         J6moGnwZ3n4Gf13d+L5mptNh36IqGBRMFvCGES8MIz+81g5l7/aEFCG8PhXZID0nF3EK
         HWxA==
X-Gm-Message-State: APjAAAVo4qNAKDGWTPvWAMZtSig83RLXFQSZGWQ+ItKf19kkm7KkPfWz
	IOQi8s0god8tikB8hBOmTBSzfyFbwMEUIQZyW37FMRkLNljpqtuYZ3c1OK2rckl49L3XfLdXADs
	ZNV0x45Pkf26TorT3BUoze20UanPzFLLbGmhTfhJKIicaqJxUrGWXHaa4NVYKvzM=
X-Received: by 2002:a17:90a:cb82:: with SMTP id a2mr14672762pju.80.1558937207849;
        Sun, 26 May 2019 23:06:47 -0700 (PDT)
X-Received: by 2002:a17:90a:cb82:: with SMTP id a2mr14672653pju.80.1558937205883;
        Sun, 26 May 2019 23:06:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558937205; cv=none;
        d=google.com; s=arc-20160816;
        b=Bx0XR157RTRdweiqImU+HvNdLMGHe6ZLY44gkG8DJHpFRSJb7fRv/BjXUD7swtFPYt
         0u0ZZkVKj9nQswGlRGc1gVAVvleb+OdVFQpKKGnU8N8J36E251BcJXroT44EioiEJ8M2
         qXMbKTMAkEOEz1AzfI2mgS7w9YlM99q01QLyIo2JQWEZCztKhgPwYHM7IJeRYvUnUykf
         stQEx7WAkNSEWAfukwGHdJBfiQjojp+gK44SQH2Jvql5+B7nj47Ek+XnjP6XCFbFiPwi
         6+GGJYdGRScn/kFjAjA1ZLiMQGdMbFZ9WTTYMXobNBnkd2VmDvhH52UKWgOjwwmZ74fw
         jN0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=J+flJg4D+B292+R0mjnCGOvi2ClGFqVNzhwfO4APIzk=;
        b=D6Yr3ZshvZVXzDHtf4f3yFlfFFTqtKU1gPMC6KJRnfygRx6HpIVGX56tiRVN4LgwSj
         8FiODzYOEpSEe3yFmPN2hBi0qcsrdgrLS+niVMLMA/ea3kMTIFq72W+71QnsVgLH5H16
         5jgZCapnVV8OLQEGuUZhDNyd0C3zD8luc1PT12iKB9JRAG99TAnFWWKSyXi7BBJ4pO8Y
         SqwdOM9cpa3q5cfcLMI/qHGf6SW5j0mL/VsZikilV/YM1r8sPB9wV5m35VP16OQwdVS3
         2m2cUS7e/VpA0jsH/FSyPvducSb0ydMiEDzqp4r/Ay7byDaytT1yNGnnngyrdQtXT9qX
         4Qug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OlkrPsci;
       spf=pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nao.horiguchi@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ay3sor10774128plb.20.2019.05.26.23.06.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 26 May 2019 23:06:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OlkrPsci;
       spf=pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nao.horiguchi@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id;
        bh=J+flJg4D+B292+R0mjnCGOvi2ClGFqVNzhwfO4APIzk=;
        b=OlkrPsciOkbhWZp3PP44UreYr8KL5SZwPqqMfrHRqMPhAIRFfzi8ZkB26S4HuYnWXf
         eL/2+2N+Ct1wjX1UiIPfIe29z48HiAE2LS0lX+Tv362vNKl/wkXZYhh4Ym5kTUK0YmiP
         Ht1PEIMm9bkr6Wd7JTRmdqTfGesPel0ffT/ILlMLbUBvKOVXFoWlXe+lRTMbJNwBmoZ0
         5HlvHblnBsRhv/7CxEKdnLRDjcNugmUknRqpexNkhwq8Q5H0+EFwbGhf7wVl2yzEnDds
         RTcGgj3AQRwXjhWuCqq9yGeQW7qlongtT5ABvk5WRKh8cMmv4++nywV0CY13wjDO20ki
         5bgg==
X-Google-Smtp-Source: APXvYqwcJ9eOvwbIDlqK3f4QPizo7yl9wzvO6W3lyPysMIRbzpS6HwEeDl/L8G/QTThaFCHQWOAOmg==
X-Received: by 2002:a17:902:2ba7:: with SMTP id l36mr29760193plb.334.1558937205300;
        Sun, 26 May 2019 23:06:45 -0700 (PDT)
Received: from www9186uo.sakura.ne.jp (www9186uo.sakura.ne.jp. [153.121.56.200])
        by smtp.gmail.com with ESMTPSA id b4sm9939550pfd.120.2019.05.26.23.06.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 May 2019 23:06:44 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	xishi.qiuxishi@alibaba-inc.com,
	"Chen, Jerry T" <jerry.t.chen@intel.com>,
	"Zhuo, Qiuxu" <qiuxu.zhuo@intel.com>,
	linux-kernel@vger.kernel.org
Subject: [PATCH v1] mm: hugetlb: soft-offline: fix wrong return value of soft offline
Date: Mon, 27 May 2019 15:06:40 +0900
Message-Id: <1558937200-18544-1-git-send-email-n-horiguchi@ah.jp.nec.com>
X-Mailer: git-send-email 2.7.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Soft offline events for hugetlb pages return -EBUSY when page migration
succeeded and dissolve_free_huge_page() failed, which can happen when
there're surplus hugepages. We should judge pass/fail of soft offline by
checking whether the raw error page was finally contained or not (i.e.
the result of set_hwpoison_free_buddy_page()), so this behavior is wrong.

This problem was introduced by the following change of commit 6bc9b56433b76
("mm: fix race on soft-offlining"):

                    if (ret > 0)
                            ret = -EIO;
            } else {
    -               if (PageHuge(page))
    -                       dissolve_free_huge_page(page);
    +               /*
    +                * We set PG_hwpoison only when the migration source hugepage
    +                * was successfully dissolved, because otherwise hwpoisoned
    +                * hugepage remains on free hugepage list, then userspace will
    +                * find it as SIGBUS by allocation failure. That's not expected
    +                * in soft-offlining.
    +                */
    +               ret = dissolve_free_huge_page(page);
    +               if (!ret) {
    +                       if (set_hwpoison_free_buddy_page(page))
    +                               num_poisoned_pages_inc();
    +               }
            }
            return ret;
     }

, so a simple fix is to restore the PageHuge precheck, but my code
reading shows that we already have PageHuge check in
dissolve_free_huge_page() with hugetlb_lock, which is better place to
check it.  And currently dissolve_free_huge_page() returns -EBUSY for
!PageHuge but that's simply wrong because that that case should be
considered as success (meaning that "the given hugetlb was already
dissolved.")

This change affects other callers of dissolve_free_huge_page(),
which are also cleaned up by this patch.

Reported-by: Chen, Jerry T <jerry.t.chen@intel.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Fixes: 6bc9b56433b76 ("mm: fix race on soft-offlining")
Cc: <stable@vger.kernel.org> # v4.19+
---
 mm/hugetlb.c        | 15 +++++++++------
 mm/memory-failure.c |  7 +++----
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git v5.1-rc6-mmotm-2019-04-25-16-30/mm/hugetlb.c v5.1-rc6-mmotm-2019-04-25-16-30_patched/mm/hugetlb.c
index bf58cee..385899f 100644
--- v5.1-rc6-mmotm-2019-04-25-16-30/mm/hugetlb.c
+++ v5.1-rc6-mmotm-2019-04-25-16-30_patched/mm/hugetlb.c
@@ -1518,7 +1518,12 @@ int dissolve_free_huge_page(struct page *page)
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
@@ -1563,11 +1568,9 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 
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
diff --git v5.1-rc6-mmotm-2019-04-25-16-30/mm/memory-failure.c v5.1-rc6-mmotm-2019-04-25-16-30_patched/mm/memory-failure.c
index fc8b517..3a83e27 100644
--- v5.1-rc6-mmotm-2019-04-25-16-30/mm/memory-failure.c
+++ v5.1-rc6-mmotm-2019-04-25-16-30_patched/mm/memory-failure.c
@@ -1733,6 +1733,8 @@ static int soft_offline_huge_page(struct page *page, int flags)
 		if (!ret) {
 			if (set_hwpoison_free_buddy_page(page))
 				num_poisoned_pages_inc();
+			else
+				ret = -EBUSY;
 		}
 	}
 	return ret;
@@ -1857,11 +1859,8 @@ static int soft_offline_in_use_page(struct page *page, int flags)
 
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

