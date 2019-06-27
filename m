Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A22CAC48BD9
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 05:16:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FCF6218A5
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 05:16:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hLjGSXHQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FCF6218A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72B196B0003; Thu, 27 Jun 2019 01:16:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DC4A8E0003; Thu, 27 Jun 2019 01:16:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A3758E0002; Thu, 27 Jun 2019 01:16:22 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25CFE6B0003
	for <Linux-mm@kvack.org>; Thu, 27 Jun 2019 01:16:22 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id e95so766734plb.9
        for <Linux-mm@kvack.org>; Wed, 26 Jun 2019 22:16:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=dLHMpSvXQSD083tckUaqr5lCc43yf6mebuGn+jSw2ow=;
        b=Hzzp21idDK0Xdjr784NNHdjZ1GwT2mB7AkddEVZ9EBHtVPVhtgohP0037ubipRXzeZ
         tOok9LOxTbaCDuBxw3HYlE/lesjqqLnDK1g9I806zMdT0scqHyYhQcyAwMXWWQ8opYpr
         bGXR7m0eHL5fjoTZzanfJyO4/vgVj2cK5oVHztCHTdEEnTxt7SmY2Yup+QqHo8hP31h3
         M24o1MfJ4mc8qvf3HijgNRXdL2UiC4SGiy9evMwa38JNJO5YMeR3sqkjR9ZMRL5xaovY
         m20jJkX3EGBjyxqMK/8wU9xatUfrv0vYC1FsEpYXsgC2v8q5bjyV3zxiinFjypJPx6kk
         HUYA==
X-Gm-Message-State: APjAAAU11S7m/dArZI4ttfaGGhT6sFaTCHAfAJH5wGwPg3P1SctGQTkU
	IxSyMeAi7iS2OSKNuYwc1KmrLf4LqO02j8gR+W8KzbT4mhdUtLqUzAqP3iqOoaYKqIXKBlE9cRW
	Gef7rKfjQCouEgYjZj7xyEmNT2SF4eb0rKZxL0vxvZRONoVHOPqFzYAoUeD0rKAc6sQ==
X-Received: by 2002:a17:90a:a601:: with SMTP id c1mr3572745pjq.24.1561612581703;
        Wed, 26 Jun 2019 22:16:21 -0700 (PDT)
X-Received: by 2002:a17:90a:a601:: with SMTP id c1mr3572685pjq.24.1561612580775;
        Wed, 26 Jun 2019 22:16:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561612580; cv=none;
        d=google.com; s=arc-20160816;
        b=mcI24fQi44kk6d6X1vW2f7vYAMtNki4NImKX53SoSAutdypo+vF0PIgqOaMfWB/n0x
         +WouMiEam9xxnkclp26L8b1uVKK5togWrQI1AQuowYiRrcc5nboEbnvlmabd1lxcjuS+
         4mZZ4BKpx8xfngbwynw1FqboBiGe2wdu92PWwXNSv1GcoPZfzmabGZwNvlTvAdNhQl0Z
         2wIAgFnvp0a/Xgq38kUbhgyaKNha+QWSsl6bIXJ7uwCf4TRat3304AQu4PVPU6fDucZE
         xZftF87Og72D3c4gDH7Ot+tity776bYseH8vYpAbqsDN4WNo/WeLKlVm//9qEWSbU6Vo
         mAAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=dLHMpSvXQSD083tckUaqr5lCc43yf6mebuGn+jSw2ow=;
        b=rtO55f6zbI+3+MEyMtiLz0+b/+zE55OHYCfv6im37OK+F350QXcIdxehx+oLaK0WwE
         xg/Agrz2dyIrEH4hnYuHquBF2QBvInpW1VTPvfccEPg43+fKaNClxnFQSZnvDU+dQdt5
         FFb1q5ghe9kr0tu3eSevwDV9XK/5/5C70uZ9hlnnIU876UqJAitmQVLW9VlwPGj/dFkF
         yyj+E7Rjc0ZDdD7PUxjJBIbYWxchUaG1+IVcWwDhRvNY2DFCMIhpCItcvxvybda5Okfr
         HBgAFyW+2nBAa5k99NQzNSscy3es0OjTHmHDbvCgNFUyw7vWM/AEA5oCwLGYqedeQJZU
         uylA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hLjGSXHQ;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r3sor1152982pls.29.2019.06.26.22.16.20
        for <Linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 22:16:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hLjGSXHQ;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=dLHMpSvXQSD083tckUaqr5lCc43yf6mebuGn+jSw2ow=;
        b=hLjGSXHQ3ZySmpg9L0hRhXitIUKUzmq5ycHBXmG8iserze4xv8lurnOhm95Qx/T8+0
         TrfKvR4p7nH6HbcWLxlQULke+4Muh+7TxjjsXB5cUtr61SaAsy4RczXGK/vLuRj8HHWQ
         XGBJTBwp+7kLH4CxfebhqThEtaPZnnG4C7caDEkq+lCUAINs0hP4ZDyxiHqy/0Q1R1Xm
         mLaOU6xmRlcFBlqyyWww7OKiCbbMQSPtX4sFrK+aUht9grjZMeNNp9WPjnr3Up8arurO
         IA5V9kSJUJRHNtLPAA0FhRFxJ2qaenwf9uXIxmsktgVde0aBfje4RNAV+NRwLKomINdu
         R9eg==
X-Google-Smtp-Source: APXvYqykoHphjYKkFLbMk8cRKv9nNo4OG3LontM4l5mWgAo0zB4rw4ZWsU/+nRm5s9kiLMS7f8GAwg==
X-Received: by 2002:a17:902:2a27:: with SMTP id i36mr2307823plb.161.1561612580340;
        Wed, 26 Jun 2019 22:16:20 -0700 (PDT)
Received: from mylaptop.redhat.com ([2408:8207:7820:4fb0:dc47:8733:627e:cd6d])
        by smtp.gmail.com with ESMTPSA id k3sm812688pgo.81.2019.06.26.22.16.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 22:16:19 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: Linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ira Weiny <ira.weiny@intel.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Christoph Hellwig <hch@lst.de>,
	Keith Busch <keith.busch@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Linux-kernel@vger.kernel.org
Subject: [PATCHv5] mm/gup: speed up check_and_migrate_cma_pages() on huge page
Date: Thu, 27 Jun 2019 13:15:45 +0800
Message-Id: <1561612545-28997-1-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Both hugetlb and thp locate on the same migration type of pageblock, since
they are allocated from a free_list[]. Based on this fact, it is enough to
check on a single subpage to decide the migration type of the whole huge
page. By this way, it saves (2M/4K - 1) times loop for pmd_huge on x86,
similar on other archs.

Furthermore, when executing isolate_huge_page(), it avoid taking global
hugetlb_lock many times, and meanless remove/add to the local link list
cma_page_list.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Linux-kernel@vger.kernel.org
---
v3 -> v4: fix C language precedence issue
v4 -> v5: drop the check PageCompound() and improve notes
 mm/gup.c | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index ddde097..1deaad2 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1336,25 +1336,30 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 					struct vm_area_struct **vmas,
 					unsigned int gup_flags)
 {
-	long i;
+	long i, step;
 	bool drain_allow = true;
 	bool migrate_allow = true;
 	LIST_HEAD(cma_page_list);
 
 check_again:
-	for (i = 0; i < nr_pages; i++) {
+	for (i = 0; i < nr_pages;) {
+
+		struct page *head = compound_head(pages[i]);
+
+		/*
+		 * gup may start from a tail page. Advance step by the left
+		 * part.
+		 */
+		step = (1 << compound_order(head)) - (pages[i] - head);
 		/*
 		 * If we get a page from the CMA zone, since we are going to
 		 * be pinning these entries, we might as well move them out
 		 * of the CMA zone if possible.
 		 */
-		if (is_migrate_cma_page(pages[i])) {
-
-			struct page *head = compound_head(pages[i]);
-
-			if (PageHuge(head)) {
+		if (is_migrate_cma_page(head)) {
+			if (PageHuge(head))
 				isolate_huge_page(head, &cma_page_list);
-			} else {
+			else {
 				if (!PageLRU(head) && drain_allow) {
 					lru_add_drain_all();
 					drain_allow = false;
@@ -1369,6 +1374,8 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 				}
 			}
 		}
+
+		i += step;
 	}
 
 	if (!list_empty(&cma_page_list)) {
-- 
2.7.5

