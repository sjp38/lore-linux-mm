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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D7A9C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 562942080C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JHrYMRfe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 562942080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DCB76B0266; Thu,  1 Aug 2019 22:20:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 864906B0269; Thu,  1 Aug 2019 22:20:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 690C96B026A; Thu,  1 Aug 2019 22:20:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 362786B0266
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:24 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u21so47115787pfn.15
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=o2GwgSJoRuvPfZ2J7Awdgxw+WyrY01QvDnyFb1fV9Xk=;
        b=mlwnsEALdRsby1S2JOmRzQbifCV0qQdthJMEY1uDAeho67E3TDzCb5Vo4RHEge+nNp
         UwGhsioRe4ewPbWpJhsH56qvHC1CuJZycm5XNZTq1t5tZMq6z8nMhO90O/DYjtqNLlGW
         9O8Ky4aWgw8CcMdz94uoHUlgDSWmeGa66/aT4tsXBY4HbffbTgjbxKu9UcVr4YlDobDe
         9+6hcxrVs3psfh09+lrK68gO4mQ1imxr8Ohzo+Bps/W6yUBrWDTA336bR2iD4gqb2vLY
         4/DhnGqgPAvhR2BifjQb6uoR8/bptMexcmhpA/m9mpDPNHtG7jzO6igtC10MzsNyzpbP
         p00A==
X-Gm-Message-State: APjAAAVfTWm/zFH+bDVtRVkMto3fuKofZ82LUBmeasCsiCNMscDiPCTz
	3Jvc4kqsJ4INuZ5bSCUeeqJEcv+WAibaPg7fTHqcIE5gtFonIRz2p9VzwRBD+99eYjvVfNdBGkD
	Mz55jMz+mp6FDiEOi+iSlaGxqyg6WlO+YG6nvRh91VNT4X9uFhcHr/YI2Jcj2wCXEBg==
X-Received: by 2002:a65:5082:: with SMTP id r2mr95448743pgp.170.1564712423762;
        Thu, 01 Aug 2019 19:20:23 -0700 (PDT)
X-Received: by 2002:a65:5082:: with SMTP id r2mr95448712pgp.170.1564712422991;
        Thu, 01 Aug 2019 19:20:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712422; cv=none;
        d=google.com; s=arc-20160816;
        b=AQGCUlKMqJq5H5+AZUk3VnIkTS5bSC19IM4BBO9a9+r8GYJfzR5/9JFEyzqhiCNmVY
         6FItU7s5GRWia82UhNGMv8pP9ePjcGvSSA0QKADVAE/8qy045oWUsz2epOKXA7lVdvWq
         G7cMi0cf186/oUy3OPCj4+pC5SpjLO7kR33GJ/u3zVBbsDTnakDN7mGGhH09ounfvIFL
         0gbOeP6a2Gvd9F6V1zeHcdZoBhW8NcDSgj2V3IRqIpGxulbimFZ+BWJ0XMcdkK2uegS7
         iJlXSxW+zrGyVWbZWDjKk+HJHHHrf4m5D90dFBufn3RGFDQH/p6tA7lNmfmoj/+wp4Ij
         mzkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=o2GwgSJoRuvPfZ2J7Awdgxw+WyrY01QvDnyFb1fV9Xk=;
        b=D5BaEkdlXeivfkTw75pU5ZkKz2yQDKhrGWCt+uDVDVqvI458a1KbnVEiBMxzKINSzY
         RrRoQN1mkR2ssI3XmQ/KgEZtJbCAkFWyDBRy7veE5IOU9DNrJ6Cxw3MIIm8scLYLFj5z
         +4Rc2nu2k4+Jze5HxPFoQIhpwzXXNTRV+rtqlcwJsNB122AHBukHVZ3j5a4ASLl3AWDq
         OO4njqLHrKxY7CqGc073CJeMtMKTTfC7WnaziruNY2oLPLtclT27YYa/9ZcRjje6ZE4K
         A4nyWEJFMMKZaTpayWqSaD/v9N+6lSlljVQlb2IW+Hh8LUxdcknGBORuAqzi5s2xJEY4
         kqEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JHrYMRfe;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s13sor87656825plr.24.2019.08.01.19.20.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JHrYMRfe;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=o2GwgSJoRuvPfZ2J7Awdgxw+WyrY01QvDnyFb1fV9Xk=;
        b=JHrYMRfeJbxJPRvVu2mUWlOPSRz5X9TsMoYGj7w11YGTme72BLb2VCmJtiT1crMj8E
         WFW+MhbnbkJpTwkrKMzEtbVI7vTqXv+SI+hFx6FZWh0IsKOr81DSRZrT3ou0zge/dnd5
         EXgsdat7mGxiPUC4r8AnIJEtDvOIZL+G3eepAaSt906tZ2zy13M8CWEIWzA2V9xqXZwe
         3r8aKK6oVTx9NMfrfbSmVNdddYS2ismfu/I+qiVZNMv3LWt0KFKP68hGnbZ9FH7YXxJX
         ux6o95ZiuMx2wtoGxh0CwNNs1fyU+QkDE3uHv/C0GSypFYyOdTrFbpn3G312jKYOi/u7
         rhUg==
X-Google-Smtp-Source: APXvYqzAaZbEuJQ23N6QFJdC6uFCaO+rLm14VcZtE9+tOy9uyfg9aPHBipIj9sgNkOpEwRVfN6Xk3w==
X-Received: by 2002:a17:902:9688:: with SMTP id n8mr126124101plp.227.1564712422766;
        Thu, 01 Aug 2019 19:20:22 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.21
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:22 -0700 (PDT)
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
	Alex Deucher <alexander.deucher@amd.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	David Zhou <David1.Zhou@amd.com>,
	David Airlie <airlied@linux.ie>
Subject: [PATCH 07/34] drm/radeon: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:38 -0700
Message-Id: <20190802022005.5117-8-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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

Cc: Alex Deucher <alexander.deucher@amd.com>
Cc: Christian König <christian.koenig@amd.com>
Cc: David (ChunMing) Zhou <David1.Zhou@amd.com>
Cc: David Airlie <airlied@linux.ie>
Cc: amd-gfx@lists.freedesktop.org
Cc: dri-devel@lists.freedesktop.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/gpu/drm/radeon/radeon_ttm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
index fb3696bc616d..4c9943fa10df 100644
--- a/drivers/gpu/drm/radeon/radeon_ttm.c
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c
@@ -540,7 +540,7 @@ static int radeon_ttm_tt_pin_userptr(struct ttm_tt *ttm)
 	kfree(ttm->sg);
 
 release_pages:
-	release_pages(ttm->pages, pinned);
+	put_user_pages(ttm->pages, pinned);
 	return r;
 }
 
-- 
2.22.0

