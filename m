Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 456B0C43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 03:27:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EABDB2075B
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 03:27:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mbSR1UNa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EABDB2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83F6E8E0004; Fri,  1 Mar 2019 22:27:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F3D58E0001; Fri,  1 Mar 2019 22:27:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BAF08E0004; Fri,  1 Mar 2019 22:27:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 243808E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 22:27:34 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 17so19093409pgw.12
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 19:27:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=leaxPvy1d10f5W6h1jZANHHaMuetimQOji2p2Tbvgzs=;
        b=c96a6cow9g9nHoWrXSv+suP7IWN4niGvf6LLawBbgF8d7ArTqKOM1kQd74YMLo7rDc
         a7aGJ7EInWAqgE4WMjXKigh4RX/dU9yFTg0WyhW7SIcC4bx0uTBHirxVaqgFPKc0eGRu
         9gsu/m1TQRDfVzcc85t8feOMhgeZbDyICVFY9z7ZV+1vPHYGVcHXxiTs2YovBvwv5B+8
         erXr1Dza+3pNjlg/13XQxhiqLfBTdBFS1UunRu56WJ68oFgC1M3skcD6pv/bY4IGLp7Z
         hqJvVDDjCDMzURmN4hA2tD+Ty2AIS0t3311AcghutdQ/6pCEsl9LMj64b4etIL/ySQ9b
         4O5w==
X-Gm-Message-State: AHQUAubyVEf80Q2yv+ztEwwWvS6yfroOadTjZwzMDwSI/Bziood1kkZ6
	UOSlK2mRehA3m2kyvvFtu4X+Ww4FEgjTMX0/+vm/6wCtTISHUj55bRhmiN9YpSXDklTps7KexEP
	hLgBXFm2BUZwJH+mJZ8dq0n+qR4Pi/wbZv5GNYAM+JYv1a67VIMTt3KU2XhKeUHTKuFzsq9Us3F
	+die9Ub4209NyKPjajTwd0E/Fr0d7cCs3L9VLFxzllKA/cyO+1dEoI7pPM0IDrSz5SDJxX3BGE4
	elevQLY/lZwlMzvuAY5eNZE487p4voaoEnNikfCuaICVs+rSrAHo5m8PJp4G4PaQ1j9JnnKWwMs
	yuphmng+7eL3nU4Xf4XjPYk/WSJxE5BtyLtkfwgIxl7elrc4krn1IMXgIQDG2ze1BLBwXcZ3/hN
	l
X-Received: by 2002:aa7:83ca:: with SMTP id j10mr9103045pfn.50.1551497253823;
        Fri, 01 Mar 2019 19:27:33 -0800 (PST)
X-Received: by 2002:aa7:83ca:: with SMTP id j10mr9102974pfn.50.1551497252318;
        Fri, 01 Mar 2019 19:27:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551497252; cv=none;
        d=google.com; s=arc-20160816;
        b=EzyKj4zSVWM59198RlqRLnIRMTOMQqPruLOKl/BS9oJCO30H8TSvGXu01VmCfZY270
         8N1Slu/WkJCyj1HUzwFKgNXTLuqdrrqKZ1onYw86g/D+Tw98aDjqbu/j8qNlnpgCD7fY
         ZSnf+hnthVDytmgusQLW1RoFcP8i1NjHmRhV5U6ojcKoB5LWYKqdI90dC81JZAhPQdsz
         mphLJT2aw2vXSkk+ngpJQ+UZswHMV2LdlkTjV05IzvWJ70hfmQjKLIFzq0QJuIjwC1Kk
         tEwi89ZuD671nP3iXmjD4SaUoxrbEPc6vVGr51klPvU3EPaBt1cbn+3P+oPz2nED086M
         bV1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=leaxPvy1d10f5W6h1jZANHHaMuetimQOji2p2Tbvgzs=;
        b=ktQKaJNlKr4btF0DEB4SLT/792p3HABb2Jikc9ninyZj0CTQLawceG3naXZ3VV3nnd
         ytRAQ3TeqshL7UXHk2Yxd95YdHYoQn4Yj7KtbAIo05iV06UK8HoWc+R9iJYCYEPTQx4j
         R1sQJIUjgQxS7v/3p37NEMK9fzfW5cU5iuxMzioYZnfpUO8ByyAI/g4ML1O/H6Xaor4g
         OOCt6YhRJCDmI+hRD8kRCtKjhKFhNfMQ1RnHHpPtSFjc+Scnvhr9Q7HGuj5146Xh1m3L
         M3Fu6kw2BKJDCXKjlEGJyQYCwJZqjc6Mwu+VBMdYf2o6YYfvMwOs+70zAa8XnXd2OhJV
         dsYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mbSR1UNa;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t124sor36767320pgb.63.2019.03.01.19.27.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Mar 2019 19:27:32 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mbSR1UNa;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=leaxPvy1d10f5W6h1jZANHHaMuetimQOji2p2Tbvgzs=;
        b=mbSR1UNapIwRC+fCHjf6h75XOW390JwACBb/7lMvP3BzO/AkNyzsGtkot9QZ9G9JDi
         z13H/ihcHnkfWqVqaw8/VNT6JRFUebEed5MfQQrvOpCLPEwrkdLVbKQwi1SJdS7Uxsww
         LifOUHa/yPLAkAxZCXcM+xotqcieiTcInAfKOhSjrFfGH7VCDvNmZUt9bFBgfIEOgb0t
         3+WK6Did+cdpohTeSy2rk0aT5Ap/2HEVSjDQyAXdh3ZmvkgdzdVeU5tFAcps5U1cj2OI
         9do0o5EK0P7jTJR+a9nTFsEWM/mPDPiv9wINswIG982u/dDV1GsUtolwnDC3une2tL6r
         /+5A==
X-Google-Smtp-Source: APXvYqwec0QG9bvbCYGlNaj+o05RSOIfNS7zXmMPVGDD4XkfdS/FRM7bq/V49Yad0E0UgIfZOhlOzQ==
X-Received: by 2002:a63:9246:: with SMTP id s6mr8006076pgn.349.1551497251660;
        Fri, 01 Mar 2019 19:27:31 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id 63sm42312273pfy.110.2019.03.01.19.27.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 19:27:30 -0800 (PST)
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
Subject: [PATCH] RDMA/umem: minor bug fix and cleanup in error handling paths
Date: Fri,  1 Mar 2019 19:27:26 -0800
Message-Id: <20190302032726.11769-2-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190302032726.11769-1-jhubbard@nvidia.com>
References: <20190302032726.11769-1-jhubbard@nvidia.com>
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
 drivers/infiniband/core/umem_odp.c | 24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index acb882f279cb..294bf6676947 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -648,25 +648,17 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
 
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
@@ -684,9 +676,11 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
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

