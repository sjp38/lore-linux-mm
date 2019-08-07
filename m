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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 333FEC32756
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEF7B217D9
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hGadGekT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEF7B217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6342C6B0283; Tue,  6 Aug 2019 21:34:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5969D6B0285; Tue,  6 Aug 2019 21:34:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C6A56B0286; Tue,  6 Aug 2019 21:34:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBA8B6B0283
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:38 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id l11so34611346pgc.14
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=66nLgLSrAAtLnk7heFQOXwTIycZbzywZGh2gpdUQtHA=;
        b=bg2o2oC6zNeYIQxZpa+aytXAVRBVDS8JlS/47ZohBb6g3DKRJchG5XtOSFt7NCESWs
         L4zNsikEoc90oMObfBg0dZNpFesFWhgu3VAtVDs1eHC56IKY/YQCfp5dGC7a+PZqe44z
         PBE2U5zPucFGjY/D2C4KdR/p7glSAdIBQ5omXtXoInADntRe+jCx2bTZRNS3E0bgh+k2
         EexpBQHgdHaeAdv74jlA00UT1plog4E+KkX2eRkNIAq7USvEZ+xZOl1qhhQBg0fHC4L3
         5BcH5J2h2h3nuwEi/FjH7xNA4aA/089Njy+rjY9Q4iyNyCH9nKhxWOCdPQYl9diZii4M
         wzCw==
X-Gm-Message-State: APjAAAWK3w0JYutFD8pDfACRLO38pZM5L/ztb1uhigSITTmQvQ5JGNvo
	JDZEo6kw1Phevg8zvCxWj0EKcbi1zsVyckvwhkgjfDYqc3Gpr2pYg6s9Q9MGojru/4hFqfKs2UT
	DD/K/PlLKS9JU8U38sQQiugojgC/Vv6seVdTUk5StUcVi0mPE7S2OVAbTt5hTIeLUDg==
X-Received: by 2002:a17:90a:b903:: with SMTP id p3mr5869463pjr.79.1565141678635;
        Tue, 06 Aug 2019 18:34:38 -0700 (PDT)
X-Received: by 2002:a17:90a:b903:: with SMTP id p3mr5869432pjr.79.1565141678007;
        Tue, 06 Aug 2019 18:34:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141678; cv=none;
        d=google.com; s=arc-20160816;
        b=u3L4WKxOA/aoytEUeEP+TZZwTb2xLckao9jxnO2/mr2JnV74lC4Ga00dE3/+spy/UN
         rngQ0nWd7UCPRBlU4l1z5H0KN3axtmlNQEymPg3rgHw1b1B4eftZURm/yTZHjQpQ1V8w
         rAjmHeP9kiI3Z3ngVgl6rC1f512g3wHBSo13x7bItvVXiekGrmuG9VlxWjAoN8PATp4P
         0LDHRc5pwtTNZQ0vL6JcqyBbIZDWVItURjpWh1jGUbYHbyBbbKlTfpX6T30XOCY/rfau
         5RSSK6hQgAjOqjdBGrOVRX37xsZQtHm2woHvoycfNjp2K5QpWJvLj9P8Kv07F9lpdNJ+
         B13g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=66nLgLSrAAtLnk7heFQOXwTIycZbzywZGh2gpdUQtHA=;
        b=W1RP7JeK/d0ikrKg6ZSpS5+ZWVI7DmJrO0Pxjk3myu0PmRRcr/F42Yl9g6TzV+dbv5
         hqquPmVbIdLsoEFfZDNx0pl29mIaJWV3W4tQzBoYx3jQAWH9ulRHkUO+d72My98L5oD6
         rFvHrXPLpVaWlsorrcuGQUjHoXQ0VByY4XEFk6ewDmImQJFJBA5LpcEngCwMjGhek2a+
         iEroXi+o+JM5Xs6JuswyRCitJgIA5pNkB8oaF201gn1g0wKiGPbKflajRB+pKz3guAKM
         QTiKo3ywb9uYMaqT+vC8WOTldwOHkU/da4XxisFtV9NKZIGGYNydgFz+z3ARehcHlXof
         r0gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hGadGekT;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z23sor70193873pfn.3.2019.08.06.18.34.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hGadGekT;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=66nLgLSrAAtLnk7heFQOXwTIycZbzywZGh2gpdUQtHA=;
        b=hGadGekT36tWWF2x+rPXatg5Phju1cJkPhVohpTnvU9xcLgSYz3c/H9JfBuvb/eqpQ
         gJm9ULhd1h25PBFy4ZlpC+tAGAEAzuKiPxwK1X6/dMDelBe1FYe+sUe691h23Hpm09qn
         NtkXw7G9BBhwySB0UzQpKOHO5RlAvdX8JQycevy+XDQPWxcX8dLLfHqYFlfiIf28POCQ
         XQLWbzezNK3qTnHI7eGrMbtyoSKY/W2T3jkcfT5nC0QYcZ+CMjkTw7ZL3pOdyAZGwJLx
         tXBADMMsq1ukRK67JdNPKq0uGvf0IBEzyL0wmcyHhzZLuqxNXwAHA+z0PFrP2wNDYOQy
         6sYA==
X-Google-Smtp-Source: APXvYqxVqy6uPNA5pMhiCuVlDYKPDVYd5IZkwA2Cp9U8q1WFZ9BX6VmEjp+QCN9e6zqU7bkXXXxyWA==
X-Received: by 2002:aa7:9197:: with SMTP id x23mr6650509pfa.95.1565141677758;
        Tue, 06 Aug 2019 18:34:37 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.36
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:37 -0700 (PDT)
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
	Calum Mackay <calum.mackay@oracle.com>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Subject: [PATCH v3 33/41] fs/nfs: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:32 -0700
Message-Id: <20190807013340.9706-34-jhubbard@nvidia.com>
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

Reviewed-by: Calum Mackay <calum.mackay@oracle.com>

Cc: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 fs/nfs/direct.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 0cb442406168..c0c1b9f2c069 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -276,13 +276,6 @@ ssize_t nfs_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	return nfs_file_direct_write(iocb, iter);
 }
 
-static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
-{
-	unsigned int i;
-	for (i = 0; i < npages; i++)
-		put_page(pages[i]);
-}
-
 void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
 			      struct nfs_direct_req *dreq)
 {
@@ -512,7 +505,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 			pos += req_len;
 			dreq->bytes_left -= req_len;
 		}
-		nfs_direct_release_pages(pagevec, npages);
+		put_user_pages(pagevec, npages);
 		kvfree(pagevec);
 		if (result < 0)
 			break;
@@ -935,7 +928,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			pos += req_len;
 			dreq->bytes_left -= req_len;
 		}
-		nfs_direct_release_pages(pagevec, npages);
+		put_user_pages(pagevec, npages);
 		kvfree(pagevec);
 		if (result < 0)
 			break;
-- 
2.22.0

