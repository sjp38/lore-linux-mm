Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAF9CC32753
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 746192183F
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="t5NAqE3V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 746192183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E8466B026C; Thu,  1 Aug 2019 22:20:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 273946B026D; Thu,  1 Aug 2019 22:20:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 076B86B026E; Thu,  1 Aug 2019 22:20:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C14776B026C
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:30 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f25so47044228pfk.14
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=34zW6BJN89MycamN6XZc+aPi3iIpUXsyW4mngm2d11Q=;
        b=Jd1u86ENORQ5h2XsNayKhfO/JaCR1RfBTWxgaXeBTzjOQyIOa37b5F1EWeaO3Tn1bQ
         pUlo/CnRKIUyaRFUDFiPx+xw29clA2zDwyK0QEtfI378Q9J4Vpl2nvasObUMf7j1glt5
         fC/DnMmBODdAG9bz7u0LVkCmS95HGTi10a2q8I6l86xGlTLPBhjayESjBAxImB2Pqb6x
         O1PXK1Joumx2x2PNyn5Kyy86Sp65xwONTuQkFU+TXfoNUyH5x7VLFoGeMENktvKXwH7R
         /Wt5E20NCLtpQhF94mRn2mEgJVPzAj4RkDVBNnFC3UJ0Kt5Aq0g2vydHxNjF4AUUxEQJ
         XmMQ==
X-Gm-Message-State: APjAAAVdiA8e3BcrG0py3QmttX421eKc+WGIbfK3NegTmhbcLctyJKBy
	FnFo1t/RvEK0oqtym+Nn2paOx9Pbs7JYUBVnvMp9JqDTEv5/aF8rGazyPVQOj3ls+ZCcAtqRohc
	YkS4vUeBMBW/v+mII4jQPp5gfVc9ZMVI8JAlPDccZm1IE0N0UvOSUTjLwhvgg8uT/7Q==
X-Received: by 2002:a63:4c5a:: with SMTP id m26mr119901477pgl.270.1564712430323;
        Thu, 01 Aug 2019 19:20:30 -0700 (PDT)
X-Received: by 2002:a63:4c5a:: with SMTP id m26mr119901446pgl.270.1564712429538;
        Thu, 01 Aug 2019 19:20:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712429; cv=none;
        d=google.com; s=arc-20160816;
        b=Jxey2pYIaZ3zQIqkHltqYAoc7zANqpavIZnmL90yhhlTrVquEff/lxTdcfHLT73rbY
         YIBuMltJpqpKS4mKy663WAEmibeL8mW97L9lIfm1FURSYv4V9sMddjMuqbCPg3dyFfrj
         m0WHuuxIH8oiaDTr9k8o6pPhxrbdMVHuhL0A9/E0Y/NBhYaymoW3fpo8phu44Jfcd/q9
         EuIV82KRRTIsa2hktwFE4XVdRWOysf80HHo9z69GXIBS1o1k3W8Tv+NIVBCEZXRFQUl9
         ctHDtWcOTMiR0cuIvLlxZiLvBk5Ns3/H9rbUurm5Z/XuEF7Kv3WPhJ3gwrY+QltdCnNA
         Ec9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=34zW6BJN89MycamN6XZc+aPi3iIpUXsyW4mngm2d11Q=;
        b=Krb3OQmbkrVfx3/vChbWRP9pzpmvQK8Jnd+JUVLIJCrQCjO9U1TN1Mfu1zPppMHJ2L
         V+8NLeSV9onJYuSdcImJvTWyYIOlS3twkrVCc12cDF6xv5BAuJAUv1HNIYEygdjYd1r0
         kn2GCBUQKSTIsyjo1e2HIMgDK3hfnAf5h9nq9wvIkYsY7cUEyTuOw0pErefoykqbXG1h
         xImxhIo8faSaEn3IgShawg0Bgo743ZhqGGlkySW24xdbxBP80YNRp6EjJMeE0yKrEy0X
         uwSt/SqRHSrK56pHn9uiieU4/TpqWmWwIzzyfYx+HhbE/6K8nAootyy4vn3dsp5IdwBY
         u+DQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=t5NAqE3V;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l6sor24469932pgt.33.2019.08.01.19.20.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=t5NAqE3V;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=34zW6BJN89MycamN6XZc+aPi3iIpUXsyW4mngm2d11Q=;
        b=t5NAqE3Vka8KgkTsGoLz9ngltlH4Rvcpb6lwK1UP3GX3tIbQ8zi6/BtK7Yp4TzERha
         wSeLot/t6ZWJImnvKBZhoEDQI6w3o5UiMaJgEpqqKVxcZT34GhcoUwN2IZVyDwqCPKlC
         a7Buv+1Wht5mLnbtK6+0hFPG1gydiYPwhnLgxc7zgGLfQhg2ssESYfy+n2RPvUdztRim
         jUlI8gdPL0+PZqp56ewu9yAP9JBceuh2IC1TKvQK+F/6hCHCM/byLJfkcX1hvyboPVI9
         xbVnybXy2ozmgwqFr15PYWmG4HhsZR295UWof1NeRQ0AKr4kLzhdz4MTCgaGRcNk5CYS
         eE0w==
X-Google-Smtp-Source: APXvYqzeCy+7cVID+Rr3XWOFQDSekWzD7T6/ZvL7pRVEGXoHJuKXgEeLRZGzPIVKoEslJMD2nH6qbg==
X-Received: by 2002:a65:6454:: with SMTP id s20mr122064853pgv.15.1564712429240;
        Thu, 01 Aug 2019 19:20:29 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.27
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:28 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Sudeep Dutt <sudeep.dutt@intel.com>,
	Ashutosh Dixit <ashutosh.dixit@intel.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Joerg Roedel <jroedel@suse.de>,
	Robin Murphy <robin.murphy@arm.com>,
	Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH 11/34] scif: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:42 -0700
Message-Id: <20190802022005.5117-12-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Sudeep Dutt <sudeep.dutt@intel.com>
Cc: Ashutosh Dixit <ashutosh.dixit@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Joerg Roedel <jroedel@suse.de>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Zhen Lei <thunder.leizhen@huawei.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/misc/mic/scif/scif_rma.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/misc/mic/scif/scif_rma.c b/drivers/misc/mic/scif/scif_rma.c
index 01e27682ea30..d84ed9466920 100644
--- a/drivers/misc/mic/scif/scif_rma.c
+++ b/drivers/misc/mic/scif/scif_rma.c
@@ -113,13 +113,14 @@ static int scif_destroy_pinned_pages(struct scif_pinned_pages *pin)
 	int writeable = pin->prot & SCIF_PROT_WRITE;
 	int kernel = SCIF_MAP_KERNEL & pin->map_flags;
 
-	for (j = 0; j < pin->nr_pages; j++) {
-		if (pin->pages[j] && !kernel) {
+	if (kernel) {
+		for (j = 0; j < pin->nr_pages; j++) {
 			if (writeable)
-				SetPageDirty(pin->pages[j]);
+				set_page_dirty_lock(pin->pages[j]);
 			put_page(pin->pages[j]);
 		}
-	}
+	} else
+		put_user_pages_dirty_lock(pin->pages, pin->nr_pages, writeable);
 
 	scif_free(pin->pages,
 		  pin->nr_pages * sizeof(*pin->pages));
@@ -1385,11 +1386,9 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 				if (ulimit)
 					__scif_dec_pinned_vm_lock(mm, nr_pages);
 				/* Roll back any pinned pages */
-				for (i = 0; i < pinned_pages->nr_pages; i++) {
-					if (pinned_pages->pages[i])
-						put_page(
-						pinned_pages->pages[i]);
-				}
+				put_user_pages(pinned_pages->pages,
+					       pinned_pages->nr_pages);
+
 				prot &= ~SCIF_PROT_WRITE;
 				try_upgrade = false;
 				goto retry;
-- 
2.22.0

