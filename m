Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE063C43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 20:25:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA55720836
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 20:25:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="I4YA8t1j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA55720836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45A9F8E0003; Sat,  2 Mar 2019 15:25:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E4678E0001; Sat,  2 Mar 2019 15:25:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2857D8E0003; Sat,  2 Mar 2019 15:25:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D6DA88E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 15:25:20 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id s16so1092650plr.1
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 12:25:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NAstCI9WUM1BZ9yvnnEDKypv2TcIjD9mYfs4G8Ype8w=;
        b=MxSnRgMuLqwe2khcwLt2XJgRIfzQbbo4FeNnL1lkH+E4YnGf7vyKoMnR4FSRF7geg7
         lhJkf1BE0o2vXieGQv2Y1BdpkiFVSmX+0OQiIE2egVAJPciImI254jUh4S6fMBn8f3yb
         1xM47eV7Y4XrSXx45NXBVzwyyCUqgSyaet36K3SSt3goMFbwEPyxeveeX3BaS9JvTGZx
         Hr1b1bqnQ4iIVnx2pT0dpfxkVFr54U1wT062GYKPzB1rp7nO4kfxyeqYaNZ52oerrWlV
         R+sQBz/tPVFNddoJJnAYirKLQAmWTQN/oJLhLD8jml0NDaKuRdElWxObvMk2IB8cYDU0
         FZCA==
X-Gm-Message-State: APjAAAVD04Erxs3fdn1nEXFiqZ1nwvwKxSa2S4U3mPgSF8YiFANqOIpy
	xLH6e+3bP6dSTfu9CQB9dkj6uV/+bx6vfc/JLIi8o+b6xSKJ84rZhhB9cyRYPrdtZLi9rPoneeK
	yoHkN2OVrCJSKhFmu0irQwfcVV/zUr1lCB+hHXuE1QflLvjcJXthsRe3BVPn11HOlExdDuupWvs
	Qtgls9Z6gx5j9xswn60E2Y2J5um0oeHW8XaTt9Sf9wfrjV5K/5HeZlChLt9ID58a+0PlA7TA4aT
	B4wCvF0O3OXToibTDj9cR9Zn7SHbj8YHanngTmvqR30ct5FscIQh9z8OQUorPn4v7E0+206qPuH
	Y1kOmaGDU2XRXXscvBt3SkgLzvvI5XVRUZ5rxtgEuPGVtyxn1w2uVC8/Wq9ZdVIQTEj3m5mXif8
	s
X-Received: by 2002:a17:902:4c08:: with SMTP id a8mr12352148ple.294.1551558320541;
        Sat, 02 Mar 2019 12:25:20 -0800 (PST)
X-Received: by 2002:a17:902:4c08:: with SMTP id a8mr12352098ple.294.1551558319784;
        Sat, 02 Mar 2019 12:25:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551558319; cv=none;
        d=google.com; s=arc-20160816;
        b=eGKkPRSrMCs/2P1MKAx1CVccg0SQU8M45z/GWNKD1/aPRMKW+e0f/TYVC4V+XARkNC
         WuAQKcfhn0zR6EHE5vVucsu1MZ1FaX8rgWo7dAArabZ9R5OAHwk7/3T/S1BTgca18DxE
         t6xjAVThuAlC40ZfwRtRMNHmxmnJdgqWZrX63acghotK740u39+ddOiz/n3Snozeot/m
         aINt9f4qeIVX9qYAXnWKyAmv7yqsbeS3nqHO7Iy517RCir4tZTBXBMELec6LHZiaC4RD
         XIpqi6rXCKYt42HtNJPDpGevbRXOm+QYD1opci+5V3qIO+kSH8XJr27Bct2uSlvihSZb
         JMmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=NAstCI9WUM1BZ9yvnnEDKypv2TcIjD9mYfs4G8Ype8w=;
        b=xKgf+bldrmsCGRRB9w4hfJeSuFlpOl7Lad/V2qZYEnHKEUrRAWTO8hWcEPEKUcdYqO
         H3xHYZIgWutvnguMF8ON9rU2n42lSgIi0tuTm/CH7iQS/LjBLcwdkYocLxzogjaVkpgB
         nlQXk7Zxq16/QmwOf/FYTFu33RQ/2WiI5eT1WrVEnU0N8tcjZj7n6ppxLXVqltYk2OHy
         QFGUAh8tlUBOCv9HvwZ1hLS5uav9iXblu+7lTGloUkfR7FXROxy1Z0LaISbVWVDJqihC
         AMiXrOGYAoimA9P+jNK0u+T9QsAY7iy+KPN8QBdWxlLHnrzo2/vBhtTpIhdgW6ejz/Tu
         eRbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=I4YA8t1j;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k7sor2625340pgj.62.2019.03.02.12.25.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 02 Mar 2019 12:25:19 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=I4YA8t1j;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=NAstCI9WUM1BZ9yvnnEDKypv2TcIjD9mYfs4G8Ype8w=;
        b=I4YA8t1jCSWhFsenJgtBcCq+YIK854Gn2iZM/3QvyIQ8jwaWEXMMZcPJCMJVs343gx
         yZOVlKsKSAuBMEPjk9YCPKmH2TRHvXMnQs86Bvv0ZjonZkhqInGempHqSf3gfsfNNkTH
         yVdOkkDtUi6yWsbvZ1eb5CTbjlKGg5GGGnm+BwYNoEK9qgzKg6raz/7uF+ssV4r78bXf
         5la40mAOZgljqBewBIGp6QCI1W8jG706RIWwxckVC/jNfrwLM0F75aQIvANTCuaigVF+
         I2wwSPXhdklyI1r0Mc2yZ3mOxXrAY5738QRX6JlPQ2Suf5whh9c44IEe/lFiAhd8xU0I
         dcEA==
X-Google-Smtp-Source: APXvYqwwXbu391RmebamDrgmsn+pVrn+KR8N08pQ8ggt54fsIW+jDiM/bzSALjIO1rvNX1hosvu2RA==
X-Received: by 2002:a63:c04b:: with SMTP id z11mr10935545pgi.135.1551558319010;
        Sat, 02 Mar 2019 12:25:19 -0800 (PST)
Received: from sandstorm.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id p11sm6045568pfi.10.2019.03.02.12.25.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 12:25:18 -0800 (PST)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Doug Ledford <dledford@redhat.com>,
	linux-rdma@vger.kernel.org
Subject: [PATCH v2] RDMA/umem: minor bug fix and cleanup in error handling paths
Date: Sat,  2 Mar 2019 12:24:35 -0800
Message-Id: <20190302202435.31889-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190302032726.11769-2-jhubbard@nvidia.com>
References: <20190302032726.11769-2-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

1. Bug fix: the error handling release pages starting
at the first page that experienced an error.

2. Refinement: release_pages() is better than put_page()
in a loop.

3. Dead code removal: the check for (user_virt & ~page_mask)
is checking for a condition that can never happen,
because earlier:

    user_virt = user_virt & page_mask;

...so, remove that entire phrase.

4. Minor: As long as I'm here, shorten up a couple of long lines
in the same function, without harming the ability to
grep for the printed error message.

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Doug Ledford <dledford@redhat.com>
Cc: linux-rdma@vger.kernel.org
Cc: linux-mm@kvack.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---

v2: Fixes a kbuild test robot reported build failure, by directly
    including pagemap.h

 drivers/infiniband/core/umem_odp.c | 25 ++++++++++---------------
 1 file changed, 10 insertions(+), 15 deletions(-)

diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index acb882f279cb..83872c1f3f2c 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -40,6 +40,7 @@
 #include <linux/vmalloc.h>
 #include <linux/hugetlb.h>
 #include <linux/interval_tree_generic.h>
+#include <linux/pagemap.h>
 
 #include <rdma/ib_verbs.h>
 #include <rdma/ib_umem.h>
@@ -648,25 +649,17 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
 
 		if (npages < 0) {
 			if (npages != -EAGAIN)
-				pr_warn("fail to get %zu user pages with error %d\n", gup_num_pages, npages);
+				pr_warn("fail to get %zu user pages with error %d\n",
+					gup_num_pages, npages);
 			else
-				pr_debug("fail to get %zu user pages with error %d\n", gup_num_pages, npages);
+				pr_debug("fail to get %zu user pages with error %d\n",
+					 gup_num_pages, npages);
 			break;
 		}
 
 		bcnt -= min_t(size_t, npages << PAGE_SHIFT, bcnt);
 		mutex_lock(&umem_odp->umem_mutex);
 		for (j = 0; j < npages; j++, user_virt += PAGE_SIZE) {
-			if (user_virt & ~page_mask) {
-				p += PAGE_SIZE;
-				if (page_to_phys(local_page_list[j]) != p) {
-					ret = -EFAULT;
-					break;
-				}
-				put_page(local_page_list[j]);
-				continue;
-			}
-
 			ret = ib_umem_odp_map_dma_single_page(
 					umem_odp, k, local_page_list[j],
 					access_mask, current_seq);
@@ -684,9 +677,11 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
 		mutex_unlock(&umem_odp->umem_mutex);
 
 		if (ret < 0) {
-			/* Release left over pages when handling errors. */
-			for (++j; j < npages; ++j)
-				put_page(local_page_list[j]);
+			/*
+			 * Release pages, starting at the the first page
+			 * that experienced an error.
+			 */
+			release_pages(&local_page_list[j], npages - j);
 			break;
 		}
 	}
-- 
2.21.0

