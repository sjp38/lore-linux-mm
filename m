Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2405C10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 11:18:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FFD52063F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 11:18:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FFD52063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B3A18E0003; Tue, 26 Feb 2019 06:18:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 263B18E0001; Tue, 26 Feb 2019 06:18:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17B198E0003; Tue, 26 Feb 2019 06:18:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id DBFA78E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:18:51 -0500 (EST)
Received: by mail-vk1-f197.google.com with SMTP id s143so7169513vke.7
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 03:18:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=EICjkiEY8XeRLtx1X9VlU1I6jq925nWk8+f5DRquXRM=;
        b=GWkmYyB6v/N2yTPW9TJ/989KIs/HmSKCitX/Fd80PRHUZBMlJMFXOkJHL84hEBFNa2
         VBEgEBmybeLHRUTW9/t77k7nxL34I+IRIrfPHJorvhnPMEg98C0Q8H9nw8yjsNsIhdxx
         sQuJWQdcvcnqAMlTeE6lkiO/mtYVY1/ZAAamIWiuJOAmcbCzvW4pgbvvPZyKXvc1Y0bs
         /oqbOlcfGWb3m5lnrwyihlPi51a0G/Gh3PLbqvH2kc5RH9XarzvcIK6rZgQxXyCPVn82
         JZ9eyA11qZi1krFJ8YRdxnT0Ci7YtHjXeXJ8uewkXnj1Y6YUtF0Z2RvdQemq0Lr8db7m
         DItQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: AHQUAuZ0uMOjLLUwQKxNdC4aeNxcvSbDYNv08lGvyd36phKcDTD+qfXm
	i629lHgPSM2CcWw5+fWKcLZXpiuAhelnGVNiXbjGdajf2WhHs5C7JjQaOtplFsZ+oG3w/zRbLOk
	9U8Jmz+lLqXFrLcXBYiTlyn7AZMvW3p5t6noHg5vNl3ACcEGKGmPkejl0Vqc3KrXrqA==
X-Received: by 2002:a1f:8191:: with SMTP id c139mr12396144vkd.24.1551179931532;
        Tue, 26 Feb 2019 03:18:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZTsLPZTN2H0d6WPE9NEPcVpzbdB4y9zQA4HcV7HrXhbiCqEo369e/j1q9q8B0OTvqc86sF
X-Received: by 2002:a1f:8191:: with SMTP id c139mr12396118vkd.24.1551179930840;
        Tue, 26 Feb 2019 03:18:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551179930; cv=none;
        d=google.com; s=arc-20160816;
        b=d1cmdCfB2AqOeJM3cHBkBxDUQbwOYOke3wf/yn3lOv/2Xeq89p6zeeaT/xsYNWJuWn
         5C5phOpqlFSgnQPVoxhewD/66v/Vum5sxrLR/yR1gP4tAOIgjiYiEyTHIxayXGIl4dBt
         vcDpaatub6n+hvnF8cj6BmUfm0Gwgq8Wbi8gFrTGMTiRs5+xiuCer/YJ8M3vYeCJ6lnn
         fwTxV+9bPgaIMcUvekAa9cznxSOOZt3Dfyq6JT8c83cMYdYnBrcQGJDJ2ShbAhl9XuAq
         cK2VWMbDcYstiqw2NOlz9Ccbg2bdB11txQZzxh1zxjvDHpAZ+0x3TsciiW+3QjfLyxNl
         QlMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=EICjkiEY8XeRLtx1X9VlU1I6jq925nWk8+f5DRquXRM=;
        b=IRiPTcxC0K7PpIjb+EYuBG06798w0wEJrjQRrnT9ShimQ8wZTh1oe+7uAo4iFo9XTj
         X6g1ZiJJdj3uys4oQ2sod5himZepbbwTKkLAXbGcUjPNklfSywCG7jNG4ApYzpmQxdTB
         4FUgZh220c/r/kxJ4nny1NR42lA0tEZzTPVVWFEAMx9iuS+tdIV+mB+dO/FACmTSUgoP
         aNkeg6h/gCAY4FrydXo692bThrAAO06/4NCirxZ2IT6wcpG9X8Ne/us0ySo3hwrdBFJb
         eUUs0/MDbvzueUdYEX/ZHbYcQnVA5VAa8eu2m4XZf1w4VwJ3GsgkOBNBBUBQ0Z1PcaBs
         GpQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id v9si2154079vsp.368.2019.02.26.03.18.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 03:18:50 -0800 (PST)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS407-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 9E33340D3053976F4C99;
	Tue, 26 Feb 2019 19:18:46 +0800 (CST)
Received: from linux-ibm.site (10.175.102.37) by
 DGGEMS407-HUB.china.huawei.com (10.3.19.207) with Microsoft SMTP Server id
 14.3.408.0; Tue, 26 Feb 2019 19:18:41 +0800
From: zhong jiang <zhongjiang@huawei.com>
To: <n-horiguchi@ah.jp.nec.com>, <akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <mhocko@suse.com>,
	<hughd@google.com>, <mhocko@kernel.org>
Subject: [PATCH] mm: hwpoison: fix thp split handing in soft_offline_in_use_page()
Date: Tue, 26 Feb 2019 19:18:00 +0800
Message-ID: <1551179880-65331-1-git-send-email-zhongjiang@huawei.com>
X-Mailer: git-send-email 1.7.12.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.175.102.37]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: zhongjiang <zhongjiang@huawei.com>

When soft_offline_in_use_page() runs on a thp tail page after pmd is plit,
we trigger the following VM_BUG_ON_PAGE():

Memory failure: 0x3755ff: non anonymous thp
__get_any_page: 0x3755ff: unknown zero refcount page type 2fffff80000000
Soft offlining pfn 0x34d805 at process virtual address 0x20fff000
page:ffffea000d360140 count:0 mapcount:0 mapping:0000000000000000 index:0x1
flags: 0x2fffff80000000()
raw: 002fffff80000000 ffffea000d360108 ffffea000d360188 0000000000000000
raw: 0000000000000001 0000000000000000 00000000ffffffff 0000000000000000
page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
------------[ cut here ]------------
kernel BUG at ./include/linux/mm.h:519!

soft_offline_in_use_page() passed refcount and page lock from tail page to
head page, which is not needed because we can pass any subpage to
split_huge_page().

Cc: <stable@vger.kernel.org>        [4.5+]
Signed-off-by: zhongjiang <zhongjiang@huawei.com>
---
 mm/memory-failure.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index d9b8a24..6edc6db 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1823,19 +1823,17 @@ static int soft_offline_in_use_page(struct page *page, int flags)
 	struct page *hpage = compound_head(page);
 
 	if (!PageHuge(page) && PageTransHuge(hpage)) {
-		lock_page(hpage);
-		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
-			unlock_page(hpage);
-			if (!PageAnon(hpage))
+		lock_page(page);
+		if (!PageAnon(page) || unlikely(split_huge_page(page))) {
+			unlock_page(page);
+			if (!PageAnon(page))
 				pr_info("soft offline: %#lx: non anonymous thp\n", page_to_pfn(page));
 			else
 				pr_info("soft offline: %#lx: thp split failed\n", page_to_pfn(page));
-			put_hwpoison_page(hpage);
+			put_hwpoison_page(page);
 			return -EBUSY;
 		}
-		unlock_page(hpage);
-		get_hwpoison_page(page);
-		put_hwpoison_page(hpage);
+		unlock_page(page);
 	}
 
 	/*
-- 
1.7.12.4

