Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62EBAC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 02:00:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08C9220663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 02:00:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FvtbdvTg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08C9220663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97F548E0003; Tue,  5 Mar 2019 21:00:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92D948E0001; Tue,  5 Mar 2019 21:00:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81DCB8E0003; Tue,  5 Mar 2019 21:00:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 411288E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 21:00:28 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id v68so10626945pgb.23
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 18:00:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=D+PN8m2YVa0N7XL/TnONPCDNFSnqtW8ebbB1OmsGckw=;
        b=qCuX/VRjlE3oypi5Y66VNcHJSYxo5FHEhSGJQn/6x6ixllJuNhwLWup2BbHfbAZU68
         QX5nJKoWNq2Dubdo+J4uaVIzHXkmhd7ryhDbNFnOL2prBE6o8cORNQfaEE0dewX3bCLw
         yHPR0nXeXGEEJThsxTpUVsa1dW5wzlPEf6BKhWr3mQQNRyBE+yA67Tmh6CLi+aJpOj1u
         7WRfTEowyuNod9m6r6PQhQ9pXc4itHQOOvdNQk+Fekpaxcpc5f/zauM+AYhDzFqFMFnS
         bDa6beQd+nTcobgDMCRaek5Eqil0XNXTpTGER4eDESI3Dgbsk8QW4BWYZcCEp4QBhtfN
         zMug==
X-Gm-Message-State: APjAAAW2aes+m0elyD8r9omPMgCBYsPDD++A1cAc4pFQ4qi6KsDq1pyb
	otRtWtCbP0nhUaPZz00DXxOgZewNfnmaZZu0nvuzJRsBuIeZtV4Y2cywd3pjrn7g2PdDyqnHpuk
	n6WW0rprYPgLsr6HzRpDrZTEoRxxQQyHimk4nMMKp5CenA5EQSQhhYRlUEz34H7JJnEHkj16hvx
	w3Shsl5AetkuJR7UmfFjiJY+OaezPTE9VG+Uvxz94l6nmXNIIZwVqx+Q4Hv3VtZupqu192+PVlO
	ufrK0EDRKYePJr/V1QZcthDWCo6o9TeXX1oUVtCkc0pKE09S6AyAZ/5/mKlyqQyYq/30Bf1Ugir
	GDd9HtLwpL1xTATT6r0egMDPYsQ/n9FPV978M9u6GE01Zc7U6ltECkCo1+J/VhD9HxgqV3UdHrk
	l
X-Received: by 2002:a17:902:20eb:: with SMTP id v40mr4436247plg.20.1551837627927;
        Tue, 05 Mar 2019 18:00:27 -0800 (PST)
X-Received: by 2002:a17:902:20eb:: with SMTP id v40mr4436154plg.20.1551837627007;
        Tue, 05 Mar 2019 18:00:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551837627; cv=none;
        d=google.com; s=arc-20160816;
        b=vHhjbBgDH5x3SNXHd/W85F3R8RvArppQEWZsXb4A6NsaJFGsWvrRPjTNjeMbp9Dqck
         n+nhuImaa+M7SXI27tozjI/kvHSIL3u8MCpJ00eoaHe8a28OKjsJWh90dAnRR4gi9Bjh
         sCu6xds30P4bnL0o60bAI1ojkPY8ZCj4Dvg7QgUVzCOOBBfK1yh3x3ucUjhENrnd5EQd
         4Bses4nucSVIiCp++xYpTeAnBT07Mb9UuBuZNrSIkL7NE/tNiOFNOryufW+JIl0XB+vC
         SEC8yRZJ89+vgTaMvEMqH4s8oj5fLSO0NAZQc2/JDI2K4D0uXAU+qznw6sra31dDgDE8
         7G1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=D+PN8m2YVa0N7XL/TnONPCDNFSnqtW8ebbB1OmsGckw=;
        b=M0U0gYBR+LREkcG0Fw0sYqaIpSHnZjqt/DP5Hh6+YTmY1FxoctRauA9L80Yhid/dAk
         UzXw34tgutFq2VWbom/owhLE1lFuwS4Ta1avT0aTbzu1QxN/THfrovlB+JUrmOcM+naU
         wrAouoUsqj50nHMy3fKCyzYnggS3Unab7XYcYlHiLdAvJZtr19IHaz/223ZtpLmJNo2D
         9kwGzUxaNFir5d/U5q6azBMJqT+IiFfxqV5kYqBuW8IWh+cQrzHZSvIChBW2McQs6uHw
         Zb5wAblq2j3xzls3irm2WYwEi1q6mL2VdBvwjuHT1y6uEKS+FyK6q8sgRDPeJLsS7Oi6
         0gIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FvtbdvTg;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s127sor471625pgs.7.2019.03.05.18.00.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Mar 2019 18:00:26 -0800 (PST)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FvtbdvTg;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=D+PN8m2YVa0N7XL/TnONPCDNFSnqtW8ebbB1OmsGckw=;
        b=FvtbdvTgpfHdFkdX+WLO6Xd1lowrxw9s511yqqKq3fjBBj0S+s9nrJ9h1JuplPqGhD
         Rzn2CfpE+zP50Q2jzZG+rYevfwsRK0dYn8jRsyqpDBm/9JodrPtqybI7z5WGggyAZzI6
         v7DcJGIkyCTz4+GA79e8SDbQwv8o3rlAVSmodpCnzqNzwsc+xhPN/RDU9JRfNkdYxGo3
         zSpY5QDQG/yP2ebvnAQyDm5Zk5nSi+ZM7bIg+zmFDByETCdHvcVqLLXop1GAJU5/96/z
         0vmVBEBdtSt+OLE3MVrI6ZvLK+W1NUT6L1dVKWEfSr0IyF1MOfeJCROLVagSt4sOsyel
         MPoA==
X-Google-Smtp-Source: APXvYqzoNlzJO9Bizk5jNh2RcZ/nitsPFjEhzbR/xZKiQYe4ghH7GVIM8KSBW/LjKo7U87AhO2EeeA==
X-Received: by 2002:a65:64d9:: with SMTP id t25mr4128904pgv.244.1551837626253;
        Tue, 05 Mar 2019 18:00:26 -0800 (PST)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id c10sm396882pfo.19.2019.03.05.18.00.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 18:00:25 -0800 (PST)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Leon Romanovsky <leon@kernel.org>,
	Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Doug Ledford <dledford@redhat.com>,
	linux-rdma@vger.kernel.org
Subject: [PATCH] RDMA/umem: updated bug fix in error handling path
Date: Tue,  5 Mar 2019 18:00:22 -0800
Message-Id: <20190306020022.21828-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

The previous attempted bug fix overlooked the fact that
ib_umem_odp_map_dma_single_page() was doing a put_page()
upon hitting an error. So there was not really a bug there.

Therefore, this reverts the off-by-one change, but
keeps the change to use release_pages() in the error path.

Fixes: commit xxxxxxxxxxxx ("RDMA/umem: minor bug fix in error handling path")
Suggested-by: Artemy Kovalyov <artemyko@mellanox.com>

Cc: Leon Romanovsky <leon@kernel.org>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Doug Ledford <dledford@redhat.com>
Cc: linux-rdma@vger.kernel.org
Cc: linux-mm@kvack.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/infiniband/core/umem_odp.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index d45735b02e07..c9cafaa080e7 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -686,10 +686,13 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
 
 		if (ret < 0) {
 			/*
-			 * Release pages, starting at the the first page
-			 * that experienced an error.
+			 * Release pages, remembering that the first page
+			 * to hit an error was already released by
+			 * ib_umem_odp_map_dma_single_page().
 			 */
-			release_pages(&local_page_list[j], npages - j);
+			if (npages - (j + 1) > 0)
+				release_pages(&local_page_list[j+1],
+					      npages - (j + 1));
 			break;
 		}
 	}
-- 
2.21.0

