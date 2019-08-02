Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 875F4C19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C9912080C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hP1EduyK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C9912080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66B3C6B027A; Thu,  1 Aug 2019 22:20:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CD1C6B027B; Thu,  1 Aug 2019 22:20:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F89C6B027C; Thu,  1 Aug 2019 22:20:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 06E946B027A
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:52 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id w5so46432639pgs.5
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XDFswRI13oGzit66yuxshlgOj+nOKd4gwJhAdxr7MGM=;
        b=faGv4B3fgnrXT4bcHPhIWq4ENyYMGFBz7ywyupfcHIg9gwniNtp/sUmAysACJXCKPU
         cfciRNM8XA+s+DDVJdZIxHRhHn3MtuzVM/Ny5PlkF2Q/L3tnFBOI6iLokmBRBumSR7Q4
         +IbFlSz1O/+vfc0VvNbLfz6bY2ssz5G3J+Wq8CVvq0tdL/bxXb6Yvu0CQdAAkJFkIwr/
         c/nyZHzPS81CvSu+DbRKISTwH4PRF/EUkQZ1aJXju4CGMIBC0aSJkFkUcSBVxD7zEjyp
         2dao5JIUXMltmocFPPwQXaJ0cIyXVt8PfeQxXxgTZeTEzRUGVssOlBDn/i34/ibNmXXW
         FtGg==
X-Gm-Message-State: APjAAAVijrHi7ENmgKurA1bRDEpY89Qfzw03D8A0PwvNxrjlhticNHFp
	dfaky68yfnu9uErDcGm9g/285qJK8zVQ7k8x2OHFa7s+aunp5M+wEWSKFTcQZskjkMf1vyKyywq
	x2iTM4LO9LrXJvzMt1SJsJNQRwlhxs7gQehUBF6N3PUUA6n7kUWIpvzeFYSag2kfsQQ==
X-Received: by 2002:a17:90a:7788:: with SMTP id v8mr1937199pjk.132.1564712451698;
        Thu, 01 Aug 2019 19:20:51 -0700 (PDT)
X-Received: by 2002:a17:90a:7788:: with SMTP id v8mr1937155pjk.132.1564712451088;
        Thu, 01 Aug 2019 19:20:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712451; cv=none;
        d=google.com; s=arc-20160816;
        b=qkIGTrv549wRCHiBWiwBqdNfij1VHJiSjdqcs2fhRad/3pVo0ValHSqYr7zTGi0BK7
         xY3aBgUcNDOLfFPFOqDwme4JYCe7T+2Q/4x91xAOefuQcqYymo6HCVTk0zyxobvIy9im
         cemSza++7SnLnsg5Dm/8oTU0Jmm9a1Jem6tCDTV2w5UZT/CHJ9AOkcQBaIQZrFhq0alF
         3kID0vv6/pxHqzPpFL6k2cJdV0LP60LINNe0amwgvc3Ngcg3Ea2aD9cPz1yqTGOpIEcN
         9548sinjdmnL1xWjmgWx7AUP5URRstUat+mHfO7NnOWH9y1u23Db2SYiv5DXoWwpYtxZ
         L0sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=XDFswRI13oGzit66yuxshlgOj+nOKd4gwJhAdxr7MGM=;
        b=UyGV0S4gVZUZXTrAZstd2YjMHgqpgr8nb4u+Z3m1/smESQ3k9zFCxkSdJ/JdFpDY0p
         9F0tQOSm1T2UGz2cmPr0Iv6/p8xYFojhlQ1akvd8oE4qiN0XsQdVuKJEg2CiTuYq0cVt
         fMrJBgTCP0hw94CUXs2G2sVa4w121O21sQueuYVkqOXgcvIwkdeIaKzCDGnTCuybHPP4
         TU0Itfl/SghrrDRuLH0QEnAwFTGZFuPpp2lXxcZ5x1R+wIqfPXpiDtHUAaNJaSZ4bEzj
         Yus4Kn47uvL5km0mA4gfSUh3Q3Qxpx8WktwbdrcHt4j5r8bTuNSNXwU1d+84pnvAXQZW
         COmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hP1EduyK;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y131sor54784518pfb.27.2019.08.01.19.20.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hP1EduyK;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=XDFswRI13oGzit66yuxshlgOj+nOKd4gwJhAdxr7MGM=;
        b=hP1EduyKMG+yuXrF7KrLXpEWytv06HPkyhEngT/TxypVjl15UFdBSQ01HK831DacB6
         y18d2lzANesimTaq9XDZY67ictckhnVqIa+djvmZG+RwwqwovWVosZPm2hXdPP8mZbc0
         0yKrCu+VZPWp1BX7LdN24uYM7pD4/H1JhmD/G5vWAzU3HcQxPlc6uryb9qFNED1nmvuy
         vlc0Xyq/DfVAu1bkczBpbXVhlvoDYp/Xx1PasljpvjsnXilMO1dGN5gCe8VOPhx84A7a
         m7JqyBz4DRJG/5S/1NCOJ5bKHp9eLh6RG6N9nPftC1UPm2sven5C2Ciggp1fXGl7R4y9
         0EuQ==
X-Google-Smtp-Source: APXvYqxrGBxtmn7yAK9mdNxfQbE+IWGBlk1o9qGDinrparVfdT4goa6Xy1ipLTWrwKQoX2yj/q+h8w==
X-Received: by 2002:aa7:8218:: with SMTP id k24mr54831158pfi.221.1564712450876;
        Thu, 01 Aug 2019 19:20:50 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.49
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:50 -0700 (PDT)
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
	Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 25/34] mm/frame_vector.c: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:56 -0700
Message-Id: <20190802022005.5117-26-jhubbard@nvidia.com>
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

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/frame_vector.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index c64dca6e27c2..f590badac776 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -120,7 +120,6 @@ EXPORT_SYMBOL(get_vaddr_frames);
  */
 void put_vaddr_frames(struct frame_vector *vec)
 {
-	int i;
 	struct page **pages;
 
 	if (!vec->got_ref)
@@ -133,8 +132,7 @@ void put_vaddr_frames(struct frame_vector *vec)
 	 */
 	if (WARN_ON(IS_ERR(pages)))
 		goto out;
-	for (i = 0; i < vec->nr_frames; i++)
-		put_page(pages[i]);
+	put_user_pages(pages, vec->nr_frames);
 	vec->got_ref = false;
 out:
 	vec->nr_frames = 0;
-- 
2.22.0

