Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B1E3C41514
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2B8B217D7
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="L6PrjOsr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2B8B217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A9B96B027B; Tue,  6 Aug 2019 21:34:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 633AB6B027C; Tue,  6 Aug 2019 21:34:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45EE46B027D; Tue,  6 Aug 2019 21:34:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 085F96B027B
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e20so57212349pfd.3
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uQGOdku7Vl3REPvOJ8nTMNJxS9zoi9IIquO7PYdcYIA=;
        b=EUvLkdJVcCQtoyHFyY/6HVjbQ1C0lbW8g83yy7TfvHHxZAse76BixmkrAAKN7AVxgz
         Jv4A4RE6NrvgXNKEalLEGul50UMr7BpRDWcxLYzuqjiLD0qeBYt0OvY4WAcW8Jaiou+X
         UY823QAy2kifGiAPtYVgtEBsNK1RWYFt5fSZZjMxpCTn1xyNdsUQhIPMOV1q+Q60I+um
         O7afXLyGh+H3AmJ85iq1j1kjheyJyLCFxa/TOEK3ENO1Vz+r8N7H8OZVNHTOIn3a0JXc
         jhgHAaauK/uxUAVngDF1bE8CvZe5ppyWJjjGdsrhCkAYtzvQmq7AAAwEOSpFu4HbUbEU
         LAUg==
X-Gm-Message-State: APjAAAXSunm88xQAxGGUKAaQXOIWDvMG6ot42iBNT2EkWUYyUFVcF869
	YHZ/tiyBPb9FdrUB3CkSF1iIEpzzIJSSPwm3FXJGxeSDPXqCJNhDETaGUbNaXmd9nkm58mMiV1n
	2fYJKbWBJEDLZVbtZgz9G5mmVoLUwKKnRrCz1YOcewk1Ug3V4ktzwZj2L/KONPehSQQ==
X-Received: by 2002:a17:902:44a4:: with SMTP id l33mr5842287pld.174.1565141670711;
        Tue, 06 Aug 2019 18:34:30 -0700 (PDT)
X-Received: by 2002:a17:902:44a4:: with SMTP id l33mr5842260pld.174.1565141670085;
        Tue, 06 Aug 2019 18:34:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141670; cv=none;
        d=google.com; s=arc-20160816;
        b=JnOPus2EImpm49JM4cQPEuyLMlZ1AcXoEozKdyPp6BIOlrk1J3T4TJt9L1LCJuWwig
         UbSYyiTsl/DZyNTj4IdFgKghEHV8UyOcgKZ7KqkOiy586+V+pcFjlagY9kKibc+q3X4O
         2/KGBLF8jyd15LiHpVJsz5RupTGTjgsYRmEU61ZncdXEN3OPghHyzsMIzWIl3lXc5lCF
         WxBSijKi75PwHYGYhcoFO2X0GJai4qk5IRgSuJqv0bFT0S2l/G0MgAaO1Uldvi+sbuJj
         O0pBfyWN+8vdRwYYkWZp8nqrAKIvW4PFTDlQMK69RDazTi+5EqkbqUpPdUY13gkrZn7E
         KGGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uQGOdku7Vl3REPvOJ8nTMNJxS9zoi9IIquO7PYdcYIA=;
        b=veQIgpcXfObERLe5aBCCI6Z2qzNKVhKTxTzEywB5mrrVHbfvQ8CMpski39R+n4Q7Xe
         dijJP7tj+dD0GbT5GvCobMuADzhYOP1mbt0Dx/6ceb5+yjVNaVQMtTqQUQOYCuQDIHZO
         hAwG38fVhFZ7MPNqAdlFq5vqm/ZRw54GbQAe3UhMlif3u7tH33Z8YfZ53FMluc7U3jzu
         kJ9zZI63S3MHSMS7EoL5qNpVFC5WqRxbvzANAsZ42t2ylnkuDVcDZx8MQ6hcEq7KmtkC
         C0jNpz8ihVsfpNdGPSSdFLGvoNQs5ukhtwvj0cSMMz0EGHLy3ExCXYV4KEDbHd1V4L9G
         CQ+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=L6PrjOsr;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r202sor70503881pfr.51.2019.08.06.18.34.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=L6PrjOsr;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=uQGOdku7Vl3REPvOJ8nTMNJxS9zoi9IIquO7PYdcYIA=;
        b=L6PrjOsrS6boUIN/DOymS83vV7YlAKPpT9Xdrfk7ax1OcCgE7PAsCiB8I3wTJde6P0
         jWSZSVN0MQGqPFzlI9I6nQdqRL1oXS8MVgrMBG2RUC/9SCRR/2JXuxH0Bc1AbFhAasOV
         xWwwBWKfNUqmzHZ9usEoeFIoZA0TFhsqfa1vxdEBmkB+UHsGh6j98UqgUEfpOkZ8azEw
         XctfU3/I30ArTXSEYH2C9KRaAbt0v2hqFYnx8WGIkLVSjGqesnYt/lo+Nif4WusFAWAo
         kwn89YnMjOOYX9/SsgW6zCkgnnE6VjyidKN7erx1BI5f02v6uid8cXohhKk4FwCmi1FI
         cYgw==
X-Google-Smtp-Source: APXvYqyaoKmDNdUJQD7xvZFSQjCmYuVY+zKJwqcOsFMJXKJ76CQxjmhpKXdBBVyw94JCP/lkY4QWYw==
X-Received: by 2002:aa7:8f2c:: with SMTP id y12mr6988234pfr.38.1565141669837;
        Tue, 06 Aug 2019 18:34:29 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.28
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:29 -0700 (PDT)
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
	Keith Busch <keith.busch@intel.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	YueHaibing <yuehaibing@huawei.com>
Subject: [PATCH v3 28/41] mm/gup_benchmark.c: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:27 -0700
Message-Id: <20190807013340.9706-29-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
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

Reviewed-by: Keith Busch <keith.busch@intel.com>

Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: YueHaibing <yuehaibing@huawei.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/gup_benchmark.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
index 7dd602d7f8db..515ac8eeb6ee 100644
--- a/mm/gup_benchmark.c
+++ b/mm/gup_benchmark.c
@@ -79,7 +79,7 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
 	for (i = 0; i < nr_pages; i++) {
 		if (!pages[i])
 			break;
-		put_page(pages[i]);
+		put_user_page(pages[i]);
 	}
 	end_time = ktime_get();
 	gup->put_delta_usec = ktime_us_delta(end_time, start_time);
-- 
2.22.0

