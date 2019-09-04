Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A5E8C3A5AA
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 07:22:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2B3F22CF5
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 07:22:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="E3u/RtT3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2B3F22CF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7232C6B0006; Wed,  4 Sep 2019 03:22:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D4286B0007; Wed,  4 Sep 2019 03:22:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EAA46B0008; Wed,  4 Sep 2019 03:22:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0244.hostedemail.com [216.40.44.244])
	by kanga.kvack.org (Postfix) with ESMTP id 3D55F6B0006
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 03:22:20 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id BB30DAC02
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 07:22:19 +0000 (UTC)
X-FDA: 75896394798.19.mist87_6b9414dbb6401
X-HE-Tag: mist87_6b9414dbb6401
X-Filterd-Recvd-Size: 4686
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com [209.85.215.196])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 07:22:19 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id n190so10751471pgn.0
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 00:22:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=k5iU7vWPjCKUNszLjo1EIEgwZ0+VgslA2cRZaOoMdXw=;
        b=E3u/RtT3z0ejfdWGzoAwlpOd3pFC+iFylvsxbFkIQG5Mk6lIrZFqAxY/wzfukTZab4
         IlCc9iZEZth6OuNubGQNJrjIH5thuTE4jo5kuW7zcMnGChwRSC/H/Buwf9yugb0rbVht
         kMscYzGT9e/V0v0yPDjBt1mfX+Z2GQvGhPYy7tHvR8ypFt3CgyVUBrR0HUAWSPggtc3Z
         m7jfVT1jVDT3YgxP71iC9aeu9BOpvLt7hAvuMqNliX+XUIzPJ5pDDZquxZNPDZVu76cD
         l38fu0wg10M3nUq7d01NNdMGuakN19VcglJzVR8etxln+4ZTk8mKV7/2f/FkhswVK2On
         CxMg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=k5iU7vWPjCKUNszLjo1EIEgwZ0+VgslA2cRZaOoMdXw=;
        b=P4CHU2j445K7cRDugp9/anxg3INjUnZIf83MhUtTLCMnODFse04ivcJKg7kyshgRjG
         I3rPsBp2fpR2hQiakjhQT+Kh6k2xgB4hvhkf11zd+DzyItZUIL3r5/DPqzt5Xa//4ryo
         T0i8SZcx1dfblKd6ld492mZE5Sx2lXkJZLmsqJPutojoZs5BlCUf2YMt2ltEDYLQa3JF
         jfxu+c6INanlIYrUbB3JB4dvAXWKozf/FS5aZoYo41nfVxPLBgGXp9OjuCuoKSJK31XF
         wdS0XaSgRm4qEjyV16l3dDiNPHSzA0iiRCPr0xcrDkz5lygLA6x1QV75q7FaDpEDjNtD
         Kd2A==
X-Gm-Message-State: APjAAAXo2/dT+XqQNGqbYLLq1sP4VSiI6+aV3SK1EmIfGTI/WNOYS9xw
	ZWleU4RT/SaTOdSGLnF4ulQ=
X-Google-Smtp-Source: APXvYqxLCJ/mi+WEi6Hizyc8n+UGDgwDe+iBmNMTCCrPk2L2yLhgzlweZdQeKPuU7rt4Jv/8s4pLdw==
X-Received: by 2002:a65:6294:: with SMTP id f20mr34883435pgv.349.1567581738039;
        Wed, 04 Sep 2019 00:22:18 -0700 (PDT)
Received: from VM_12_95_centos.localdomain ([58.87.109.34])
        by smtp.googlemail.com with ESMTPSA id x24sm17102188pgl.84.2019.09.04.00.22.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Sep 2019 00:22:17 -0700 (PDT)
From: Zhigang Lu <totty.lu@gmail.com>
To: luzhigang001@gmail.com,
	mike.kravetz@oracle.com,
	willy@infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Zhigang Lu <tonnylu@tencent.com>
Subject: [PATCH v3] mm/hugetlb: avoid looping to the same hugepage if !pages and !vmas
Date: Wed,  4 Sep 2019 15:21:52 +0800
Message-Id: <1567581712-5992-1-git-send-email-totty.lu@gmail.com>
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
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
Acked-by: Matthew Wilcox <willy@infradead.org>
---
 mm/hugetlb.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6d7296d..a096fb3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4391,6 +4391,21 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				break;
 			}
 		}
+
+		/*
+		 * If subpage information not requested, update counters
+		 * and skip the same_page loop below.
+		 */
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


