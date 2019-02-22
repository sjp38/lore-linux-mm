Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B3A9C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 13:52:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1247220818
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 13:52:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1247220818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F3C68E010A; Fri, 22 Feb 2019 08:52:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97B508E0109; Fri, 22 Feb 2019 08:52:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81BA68E010A; Fri, 22 Feb 2019 08:52:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D46A8E0109
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 08:52:02 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id l8so1007728otp.11
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 05:52:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=my34Zq5qGOqx+PKBmdAJwy3V0up1XXRQioNrhZl7lvA=;
        b=VVNk03g3ZI6s5atMBRjYaMO6ha63g/yBVDHHxi1yTncg4U5Wmipr+stkIUStC3kyAv
         0MP9DfVwle6cueE4bq4f28CtTtlX3k8hvJ0BQZvLVBFEYMz+q6u7uyzPPAi4kGYWLKYc
         tW3kC3li2p7SQEZl7MVE+lHvebdIevPHu7uIzL4CXmmMebxGkQUhg3zjk2BM6NsOG87j
         95Lf4jMlVm/Wu3YCu821Vs2BAPci1q/WVneERlt1qyNQFrK6kfLZvDzt6e4hSBtjbnxU
         U5SL1hvl4/ZuRFuXLOuSd02CmGlHu8q0dl3qMsnhLWItDO92y5dyCLqSV68i1M8dETPM
         ZGyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jingxiangfeng@huawei.com
X-Gm-Message-State: AHQUAuZNT71+Dv/lKPMRxxOj4wirhutFm92IqQoiqMagNlzXQ0+1eAgz
	ig1SP+q6KRz9kP/qWdiEMlN34QK+iMdDo8wJ4GbYsckdxoF0HNYy8P5BkcCIV3dElRihqbSHAzw
	M9MWo4MfP2kVzUI+9p93XJ9maCp+f5wNPRjjoXVXpoaunV9xQVsMpIu6pzV8PHfUFtw==
X-Received: by 2002:a9d:3b65:: with SMTP id z92mr2750608otb.275.1550843522008;
        Fri, 22 Feb 2019 05:52:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbjZb9leOAMitooqbl2wEJptp5zVAGGlU12A0UldZMBhOkOEbtSpEHVTYO9IWmSlNErvYbu
X-Received: by 2002:a9d:3b65:: with SMTP id z92mr2750576otb.275.1550843521254;
        Fri, 22 Feb 2019 05:52:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550843521; cv=none;
        d=google.com; s=arc-20160816;
        b=neL0cxjvRjSecKrmRBdhZNzHJNk96peoJtKWUKxAwwR+t876vO2JNXOZ+GFQIa8a5L
         Mlqo3E/axIun4czxOX4dQ5h369yxBk+IblmnN6vE8Ruew+GHvQ3TYLVAaN5B+UDsPOPO
         67jVz+GaqGB44gKdmDw9y4AgRrc7cKvJJbdl+NQujMcWy57vwSB2k/ETZBtTf5hliYbP
         uA2h/DOQ8CueoYG97GCTw5ZVo53yFgiNC4G94NIAoMIWcqx2YCXP7Nn310EtSONX2iQU
         oSncJW2GZrh56E6ul1CITHHx2TWoUcenh+Bzme5Pn6lp1Ucgp4zzlBksQNHnExvTT4Qs
         2psA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=my34Zq5qGOqx+PKBmdAJwy3V0up1XXRQioNrhZl7lvA=;
        b=x++cCDQPZz6dw/ITkYGuu8StBXxoPITzjXIektLwTEvVecGMtGGP+ESHsKuqNgIm3C
         E/JlB89Oa2ejUwi2Me4vvZzp5JmcevZP/E36KthotG88zTGI6l98+xcb4Fg8dcp/cP77
         pPvtK8CDcEsMfpX0Cp18m+EgdGAoBKGUOwOifQckXRN6nk5Vv9c/EHL+pvQWlk+ujUsD
         Dd3RZmnIybpWN01sgNKokQbC85IhjNS7bVRNE1ky7tvd0DTw5Sd3JVXmd1iJKtutTOxk
         AlSrUe83XHIDZNDAA/6xqCtMie9FBZ5R7MoSvRNUo9bQuPMiSJoFoZ6sJdCc5nhWmr81
         euaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jingxiangfeng@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id j15si644147otq.134.2019.02.22.05.52.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 05:52:01 -0800 (PST)
Received-SPF: pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jingxiangfeng@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id B69E12F695AAFBD9DA2A;
	Fri, 22 Feb 2019 21:51:55 +0800 (CST)
Received: from RH5885H-V3.huawei.com (10.90.53.225) by
 DGGEMS410-HUB.china.huawei.com (10.3.19.210) with Microsoft SMTP Server id
 14.3.408.0; Fri, 22 Feb 2019 21:51:46 +0800
From: Jing Xiangfeng <jingxiangfeng@huawei.com>
To: <mike.kravetz@oracle.com>, <mhocko@kernel.org>,
	<akpm@linux-foundation.org>
CC: <hughd@google.com>, <linux-mm@kvack.org>, <n-horiguchi@ah.jp.nec.com>,
	<aarcange@redhat.com>, <kirill.shutemov@linux.intel.com>,
	<linux-kernel@vger.kernel.org>, Jing Xiangfeng <jingxiangfeng@huawei.com>
Subject: [PATCH v2] mm/hugetlb: Fix unsigned overflow in  __nr_hugepages_store_common()
Date: Fri, 22 Feb 2019 21:55:34 +0800
Message-ID: <1550843734-21255-1-git-send-email-jingxiangfeng@huawei.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain; charset="y"
Content-Transfer-Encoding: 8bit
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
be overflow when a user entering a crazy high value. If so，the total
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

