Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA541C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 13:57:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55B992075A
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 13:57:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55B992075A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92AC38E010B; Fri, 22 Feb 2019 08:57:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DACA8E0109; Fri, 22 Feb 2019 08:57:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CABB8E010B; Fri, 22 Feb 2019 08:57:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6005E8E0109
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 08:57:34 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id s18so854344oie.19
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 05:57:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=YkWH4K5VcPjMX2f4AlPcZxC/sb6moBeW35rNuwTyr1M=;
        b=CKfeCdc5+UEkpw0dRXBYbD4KeY1MSpHBuBX+YBbk1egH9nSwBpQeCLC9hqU6isO2pm
         YAZttRVf4PVhbXAnGGPxomCwFKJL5WzOZ7O5/Es+fbXAUtC4BcS9aA4qwv1iYmAsyXaj
         E+STAbk1FrpoZx4KQ1iwf/PFjbNAlKvAIqEbADAEARe50Np8zZKObF0ReA6VIeepYAbE
         8twMCWlOEbac7zDFknKaAEGUOs25fqkRGB7hwcE1SxtGeUCzWg2ak/7W4booB9z002X7
         16s7QkYkuhCZAQa41nx4/qygLcXwl52c1JulzKCgSwKb9etNwfN+R395E2pB5jBpbIoE
         XRyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jingxiangfeng@huawei.com
X-Gm-Message-State: AHQUAuaitFxDi/yAcHPAT7TN1f3Cq25ZIdPbOBAsBn7FzaxjuSLW2x3x
	mXTZTDP6KfSK8bk8oD99hEA5C7GiK6lwW3lkrVBiuo+0wlyI1qEABT0mY5gMektxUIzhqYqD6+q
	VOK7wLwv4RY2ekvKlcOblhGodfZRtXBZpSs5rezySYZl3RLg05OjBEdTJmE7WGfDEzg==
X-Received: by 2002:aca:aacb:: with SMTP id t194mr2673647oie.129.1550843854055;
        Fri, 22 Feb 2019 05:57:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibexerp8f3ZPbKgzQnxUBUbXlG1PeJvL0JaLaYLG+SMlLQqxiSonMPlA726D8qfosiHOm9/
X-Received: by 2002:aca:aacb:: with SMTP id t194mr2673606oie.129.1550843853364;
        Fri, 22 Feb 2019 05:57:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550843853; cv=none;
        d=google.com; s=arc-20160816;
        b=iGlRX7Rzg9PO094r/Et/waacRDUZH57fU98070N3iejIZV5IaOGSFgizP9Jy33x7oi
         O0dPNNfgKpLYFRyA6xvhaXDjNjaEw1lb7TzeJ1Fts0iUwqDYGSlELfIjsDjQrCXnUAvd
         xN/dkXKEo9mBUhJ7L2nZieYDERYattKVTa4B7OHOY+1dupjFlX3TIsZOfbkdun+Md4am
         K3Ca1rzV6CHqP+2WZFBwRO/szeKIbwVmB1Lxzprgbkq7Wgjgyu0XRorKpjgeGQUuvEhe
         XQ8y/HOY7fZssdjVW7Ru9vV41Re5qJy9ODeRrYYe6VJcijSelbcbnpzEd/ZGwE1agOu7
         DYNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=YkWH4K5VcPjMX2f4AlPcZxC/sb6moBeW35rNuwTyr1M=;
        b=ZQrPd8xAODTAtZDPvIJttw7ta5I+dm860HB+Cmq0v3H2ADW9LjunlXVhuJhnIQf7RH
         VArYycTvIOl8Q6SeUGs+C89C6e8z+iYZO/3gEpuQK0W+6TsV2PuGVYaCU/bh3+bFabBP
         ORi1RGQ5zTfPo/hhUnqsYGWe74NPO/ws5WIrBrflYDOTY4zc3cDhYtapj1f9VxAUhJKJ
         /7N2Beq81ncMihsdzsiYItGsWOuV1orbH96ckvMF0VJIduauPmAd//rO6knVzZerh17C
         pkiPvE6w6hI+NS62CDj8+6UJ6NS57OZ13gifgUKxPsmzkOgNpILRe1YGZD42X7JTmQY3
         wzIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jingxiangfeng@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id a23si708594otr.230.2019.02.22.05.57.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 05:57:33 -0800 (PST)
Received-SPF: pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jingxiangfeng@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 90B873D0B5CE584C8DB7;
	Fri, 22 Feb 2019 21:57:27 +0800 (CST)
Received: from RH5885H-V3.huawei.com (10.90.53.225) by
 DGGEMS402-HUB.china.huawei.com (10.3.19.202) with Microsoft SMTP Server id
 14.3.408.0; Fri, 22 Feb 2019 21:57:17 +0800
From: Jing Xiangfeng <jingxiangfeng@huawei.com>
To: <mike.kravetz@oracle.com>, <mhocko@kernel.org>,
	<akpm@linux-foundation.org>
CC: <hughd@google.com>, <linux-mm@kvack.org>, <n-horiguchi@ah.jp.nec.com>,
	<aarcange@redhat.com>, <kirill.shutemov@linux.intel.com>,
	<linux-kernel@vger.kernel.org>, Jing Xiangfeng <jingxiangfeng@huawei.com>
Subject: [PATCH v3] mm/hugetlb: Fix unsigned overflow in  __nr_hugepages_store_common()
Date: Fri, 22 Feb 2019 22:01:28 +0800
Message-ID: <1550844088-67888-1-git-send-email-jingxiangfeng@huawei.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

User can change a node specific hugetlb count. i.e.
/sys/devices/system/node/node1/hugepages/hugepages-2048kB
the calculated value of count is a total number of huge pages. It could
be overflow when a user entering a crazy high value. If so, the total
number of huge pages could be a small value which is not user expect.
We can simply fix it by setting count to ULONG_MAX, then it goes on. This
may be more in line with user's intention of allocating as many huge pages
as possible.

Signed-off-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
---
 mm/hugetlb.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index afef616..18fa7d7 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2423,7 +2423,10 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 		 * per node hstate attribute: adjust count to global,
 		 * but restrict alloc/free to the specified node.
 		 */
+		unsigned long old_count = count;
 		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
+		if (count < old_count)
+			count = ULONG_MAX;
 		init_nodemask_of_node(nodes_allowed, nid);
 	} else
 		nodes_allowed = &node_states[N_MEMORY];
-- 
2.7.4

