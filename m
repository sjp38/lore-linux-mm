Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D33BC04AB2
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 00:16:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 470BE2085A
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 00:16:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 470BE2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2F586B0003; Thu,  9 May 2019 20:16:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDDFE6B0006; Thu,  9 May 2019 20:16:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACD226B0007; Thu,  9 May 2019 20:16:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 745086B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 20:16:46 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o1so2765797pgv.15
        for <linux-mm@kvack.org>; Thu, 09 May 2019 17:16:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=kQcAB26OKDmQZCpxfRv57kduaPGhS8fCw6twnIJnydg=;
        b=XoIuIdxLTrF3nldlZHhXa308GTsVEprEDMAJhV4HrMM/5NdEOyJPVUY3T3/PnW/2Wm
         1grn1F/inU+91C6rzubd6BDPZrdHT4ZdqTh75qIK92wc9H+W2n0SvlYyP8he1YUKiX/y
         5D9LJKnIQhE8jMArTSm+SGJEmszzNwz4GnPF+6jw/eZjiaCQEDJ0N8SNC8kXTqjBtzhf
         zF/jX4EK1pguzNfuBpOtMnUuewxEgCU3SgGH1uUTCub50zgnmaYcJ326UDZTaO2Q39Yr
         9v84hoqEOfEovD/xD9A3TlIihUWaJdBbNB8DENhyO8X54xEsK+bRwnXe1sXS9LZLNvW0
         vUhw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAW0fybh5yD4NVRY2Fi1s3/cYw3zLysEqWvesPS1L5W//1pihoq9
	9Aoa6ESmqOg86OXTSHNWVG1MFhx7ifZYVsvdnUYInI0XocS2Gq5cnCURxaRRnz3/Izkhe7aVag6
	6i7CDvLevXUcC2O0ULvrOVwgdJMS8oTPpuetEewrZ5k39JpqZiXO0M9MdzbMyk8+SEg==
X-Received: by 2002:a65:49c7:: with SMTP id t7mr9584401pgs.324.1557447406137;
        Thu, 09 May 2019 17:16:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqTzWpaJbz/oZ4tuH8bqEq21va4dT50hegi+nWsqqsRrlFsRz2LoQ61tnRwgjB51VsDF9G
X-Received: by 2002:a65:49c7:: with SMTP id t7mr9584288pgs.324.1557447404801;
        Thu, 09 May 2019 17:16:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557447404; cv=none;
        d=google.com; s=arc-20160816;
        b=K1gHC2h0pNo32ALjmYgT1Cup+IN57dZIJ0TIbZ+RlJASjK4x03I0u5YTo5xY5PQKKo
         ZFhB95UtBbT0P4YZMMwZkTYDe2BJdvFFQSnfqU8q/YvhksW7j9DAxwUCUtHbdpHQlGx0
         M0QbhlQn7vSfyVUxNU4qfPRHxUfyCTNRHUmK7glYYWHLXKiWNAuXJwnBQRuSFNFMYJeC
         qzg+gxalLcYCzO052864xlODWeXob1CaP0JbizuLiq3rpmKZXonfa2/LU0HCAgTQK+Qz
         g6YnRzRneqkOGSG4cA3M1sul6WeJKac/Ti+WNfIAza/wKGxXB/0EgTfHeMvsKBo2ltWt
         XPcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=kQcAB26OKDmQZCpxfRv57kduaPGhS8fCw6twnIJnydg=;
        b=LqDoV1VUuY502BQiSNfSvMtl36Y/vh7NWqM6CeD7bpKrmtxOLudmmulMaXXkzMk21P
         NJsFBV1vWAXjM+y5cB5hx7xLKmlOXGmRn4oDQ9uGZIWMZ27HCYekY3wY3aXaFK+2+Hc3
         h1z+HnBeyVyXkVJ3kNzLiybtSJPLn78dSAJFQAtrf1jCXitnhp1QmbuNGSwahTaNh0To
         CBfp1les32WxaMffHvsHzy7jzjdHSn2Gn4CqiWpPnGdxb/2/IqDpchCPM2ouZSntDC8q
         bz7rLSN+gbRgXDwaScKvZPr/qM08rZDBed+DRxg/CokRbfT95vAzZ/93qkhVIk9D3VRu
         NIrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id cf2si5431551plb.50.2019.05.09.17.16.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 17:16:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R211e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TRHy6CV_1557447393;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TRHy6CV_1557447393)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 10 May 2019 08:16:39 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: ying.huang@intel.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	mgorman@techsingularity.net,
	kirill.shutemov@linux.intel.com,
	hughd@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm: vmscan: correct nr_reclaimed for THP
Date: Fri, 10 May 2019 08:16:32 +0800
Message-Id: <1557447392-61607-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since commit bd4c82c22c36 ("mm, THP, swap: delay splitting THP after
swapped out"), THP can be swapped out in a whole.  But, nr_reclaimed
still gets inc'ed by one even though a whole THP (512 pages) gets
swapped out.

This doesn't make too much sense to memory reclaim.  For example, direct
reclaim may just need reclaim SWAP_CLUSTER_MAX pages, reclaiming one THP
could fulfill it.  But, if nr_reclaimed is not increased correctly,
direct reclaim may just waste time to reclaim more pages,
SWAP_CLUSTER_MAX * 512 pages in worst case.

This change may result in more reclaimed pages than scanned pages showed
by /proc/vmstat since scanning one head page would reclaim 512 base pages.

Cc: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
I'm not quite sure if it was the intended behavior or just omission. I tried
to dig into the review history, but didn't find any clue. I may miss some
discussion.

 mm/vmscan.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index fd9de50..7e026ec 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1446,7 +1446,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		unlock_page(page);
 free_it:
-		nr_reclaimed++;
+		/* 
+		 * THP may get swapped out in a whole, need account
+		 * all base pages.
+		 */
+		nr_reclaimed += (1 << compound_order(page));
 
 		/*
 		 * Is there need to periodically free_page_list? It would
-- 
1.8.3.1

