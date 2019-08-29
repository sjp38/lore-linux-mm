Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4CD6C3A5A6
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 13:51:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73DE72189D
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 13:51:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="a3zJNkLb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73DE72189D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3DFA6B0003; Thu, 29 Aug 2019 09:51:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC7316B0006; Thu, 29 Aug 2019 09:51:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8E936B000C; Thu, 29 Aug 2019 09:51:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0192.hostedemail.com [216.40.44.192])
	by kanga.kvack.org (Postfix) with ESMTP id 81CAE6B0003
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 09:51:24 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1BCD9181AC9B4
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 13:51:24 +0000 (UTC)
X-FDA: 75875602488.30.pin68_637ae0fd32f3e
X-HE-Tag: pin68_637ae0fd32f3e
X-Filterd-Recvd-Size: 4486
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com [209.85.214.194])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 13:51:23 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id 4so1601056pld.10
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 06:51:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=fW3k8zWPWk6FVp5QrWdqwjUBdQ4RebiwFEy2lJKDFrw=;
        b=a3zJNkLb0Tq4GidOYWeFBl+BOSSAnzsk8SKjd1/mq6SDr0Bi28W3HnkIm7ZP9qZERZ
         PJDjnROIewGZ3HWRr68Q1bMrWF9HikksxywFuLri5Tt+xcCyRIdaZ8zAbPZwkEVkKEtS
         kWNhJojo3SH32dQLAgUzUmTnM9Eulr+lV2PhDaRxaw/cGI0UA5y9T814yEIPvANy0QQB
         jqM5SzZpgwH0S5XYSM8e+ZL+7ev1Ygu7DQwiVvH/1+t+mYLqBz65cXFC0mj1t/q1Zh5w
         sdhSGQZdbP3ua0iAYc4Tu2tbuKEbbGDceYIZrmkubnB68pTXo9ZHMIc8NJGpepjA/lmk
         PUtg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=fW3k8zWPWk6FVp5QrWdqwjUBdQ4RebiwFEy2lJKDFrw=;
        b=POBJLDZYpa9PXf3A0cZCtaikFhoX8aqLvyixYwLPp/xz00Jq3Y1JfYJi7OSDvgurCE
         uaXlqJDZuIWPQ+U2MN80Y0XaSy2h3AZDWbkqGZNjHCZim4RNG+LE35dorjJEOagTrS3d
         pe+uDoz8wi9fHBt+Z22DujcKRFi4mNkBgspXnsVJJ8Ydi0vRQ5716DPv9Ktg+SojVmD8
         cjfBmz+q5Sj4nmyABugQXrQbx2TmaAEJ2T5QVO/m3GDSJGOvHzPtXCiHmAaQOL0TlcO8
         ms7sVFo8VCr6sBpdZURoL3yU993V4HqcCYtfE7K+O3A+uqR6RJNqxoC3TNaRdMJWErZw
         SGEQ==
X-Gm-Message-State: APjAAAXY8ezbe00guzRcTXs0W3gS7yzG58Nnbmd/uZBSpyq54dh5CTSw
	pjoHotWAryHeQP1mA2LhBfw=
X-Google-Smtp-Source: APXvYqxtmbM6WXnKoiaNk54ZgSjFsVFn9WynUjYzmF6o52O3dElyrmgEaX2U+RxbfprFvvaJ3DRfdA==
X-Received: by 2002:a17:902:fe0e:: with SMTP id g14mr4519162plj.307.1567086682624;
        Thu, 29 Aug 2019 06:51:22 -0700 (PDT)
Received: from VM_12_95_centos.localdomain ([58.87.109.34])
        by smtp.googlemail.com with ESMTPSA id w6sm2950630pgg.2.2019.08.29.06.51.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Aug 2019 06:51:21 -0700 (PDT)
From: Zhigang Lu <totty.lu@gmail.com>
To: luzhigang001@gmail.com,
	mike.kravetz@oracle.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Zhigang Lu <tonnylu@tencent.com>
Subject: [PATCH v2] mm/hugetlb: avoid looping to the same hugepage if !pages and !vmas
Date: Thu, 29 Aug 2019 21:50:57 +0800
Message-Id: <1567086657-22528-1-git-send-email-totty.lu@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zhigang Lu <tonnylu@tencent.com>

When mmapping an existing hugetlbfs file with MAP_POPULATE, we find
it is very time consuming. For example, mmapping a 128GB file takes
about 50 milliseconds. Sampling with perfevent shows it spends 99%
time in the same_page loop in follow_hugetlb_page().

samples: 205  of event 'cycles', Event count (approx.): 136686374
-  99.04%  test_mmap_huget  [kernel.kallsyms]  [k] follow_hugetlb_page
        follow_hugetlb_page
        __get_user_pages
        __mlock_vma_pages_range
        __mm_populate
        vm_mmap_pgoff
        sys_mmap_pgoff
        sys_mmap
        system_call_fastpath
        __mmap64

follow_hugetlb_page() is called with pages=NULL and vmas=NULL, so for
each hugepage, we run into the same_page loop for pages_per_huge_page()
times, but doing nothing. With this change, it takes less then 1
millisecond to mmap a 128GB file in hugetlbfs.

Signed-off-by: Zhigang Lu <tonnylu@tencent.com>
Reviewed-by: Haozhong Zhang <hzhongzhang@tencent.com>
Reviewed-by: Zongming Zhang <knightzhang@tencent.com>
Acked-by: Matthew Wilcox <willy@infradead.org>
---
 mm/hugetlb.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6d7296d..2df941a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4391,6 +4391,17 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				break;
 			}
 		}
+
+		if (!pages && !vmas && !pfn_offset &&
+		    (vaddr + huge_page_size(h) < vma->vm_end) &&
+		    (remainder >= pages_per_huge_page(h))) {
+			vaddr += huge_page_size(h);
+			remainder -= pages_per_huge_page(h);
+			i += pages_per_huge_page(h);
+			spin_unlock(ptl);
+			continue;
+		}
+
 same_page:
 		if (pages) {
 			pages[i] = mem_map_offset(page, pfn_offset);
-- 
1.8.3.1


