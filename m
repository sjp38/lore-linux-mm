Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6927C41532
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A3BB2183F
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dM/IGJPK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A3BB2183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C5EF6B0275; Sun,  4 Aug 2019 18:49:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D5986B0276; Sun,  4 Aug 2019 18:49:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 251A76B0277; Sun,  4 Aug 2019 18:49:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E2DCA6B0275
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:53 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i27so52223278pfk.12
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6GC3vp7Kgk6wrS2t1aIFSliRmKpmpPmHRVTf1Sq+2hE=;
        b=QY8Ek0+7mfcyLOGqjTNP3tG6xzs1Jey2Ss6Y5Nf6PPArWzQgJMfleY5WOeM+6f+t1B
         WqF5M2ol9vHo+/imlFOg/od7kIT8i/jvQCSbNN6I85YcbH+B6IZgH/0qpjMoApG++rOH
         tAdcgt68rWM71659n4fc8B58erXzHUSAntYqRDIUB3g2lDDHXkJ1m6A8OOGNhloH5Zk1
         HyG4LDKqMS7rVmMlTsoujkzPDVfs1KtKIBN4iZXb8qycN3twuPNxpd7uW0qV4UJbqjYD
         nCSSMcsWMU6/fA/HDuqgUow725Lch6dmX1aCb5kELhVZ88W3kspc9UwS/ND2T0lAbJSM
         j4Fw==
X-Gm-Message-State: APjAAAUOsQpxG5ekKRq0zbE/o2v/EGc+wLBdF1sr1wylCYBzY9jSGjlt
	k61xSOvAvBKTVVaroBF8cCt974wABVEa+2qqTr+/N9ydV24TV0yYxB14gS2UHxo5+H34WCVT/fA
	/CXdH4OKgJEq9P9G0z5jQ/priuR6K0X8smoVVR6JgV62N8dndZ0D2kYm3/HQEvLuLqQ==
X-Received: by 2002:a65:620a:: with SMTP id d10mr87508963pgv.8.1564958993507;
        Sun, 04 Aug 2019 15:49:53 -0700 (PDT)
X-Received: by 2002:a65:620a:: with SMTP id d10mr87508936pgv.8.1564958992715;
        Sun, 04 Aug 2019 15:49:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958992; cv=none;
        d=google.com; s=arc-20160816;
        b=xHzqas0DtBmPI6eCldgU3hH2CGRs8RHZ2rCVSxripr8bF2i2V3bxgHWEEwW9wMGjII
         3GKzb8Z+PiDHsLv6uES+FBNujnWxU7tatz4My739EcZTfHgRmC3s3qMBxlH+uxALZmRt
         GqTgICxz45kyvaclt6j2ZLblbhCz5DKq5xlUpg2MLLriNknfsa5YzQIG7ruJRAHj44N5
         ORXdLqP0khLcfglvi60p0NSDZXPEjB7a3/KxBcGgAovfbwsHZXAPIyGOL/2PVXAdEWxC
         t+EVJ+WV87o32TPHL0UuQuYzxGAGW4KkAM05PRTfi43viYtFRBmf0Rc65fixL6Usgu4i
         JR6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=6GC3vp7Kgk6wrS2t1aIFSliRmKpmpPmHRVTf1Sq+2hE=;
        b=I56Ek6APxdwu8RVJMtlLiZPUny6vb8t/7Ndci75LswdNZY2NvJ8xNRnt/mnRn8lTSz
         xx23v78FOhyCRPTLq/CQBP+l1Xsdnz+sXhEL4KaljEukxMLmiXN+lXIUCqcsSYtRfal+
         vjRNq4737tlA8w08qzpNpCMWr3MsCBFsHafMsqRSpAg80gqdYWw5PERNbkJtbn0cjpPN
         zLxeXyNVDrBXZ8U/V2mHaxf0SlaDmSbNbrgznYYU2GYW5ADbkQWa/vr1LH5c6gpIYYWs
         4RzD+hdSALY6/97U9VtKesBkdg/01mEbTsizov2v5MN4mlGomWk3pehUQgYCtwdAi/AE
         nmUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="dM/IGJPK";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3sor18517705pjm.3.2019.08.04.15.49.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="dM/IGJPK";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=6GC3vp7Kgk6wrS2t1aIFSliRmKpmpPmHRVTf1Sq+2hE=;
        b=dM/IGJPKx3vHMSaH2jjH8cddB9IjzpJgXXKkO7CuRXnxMJrRMmXVqwBAlQ88WzjX5h
         dPH11zKs16Cup5MqaIdJ1qgQ5dnUSJO3TyirSMdWy1ehRY6u0fAfZaZVJnTvSLI1QoSZ
         1OPtp46Njt0JJnUOBtfou4qDlL/RKFcmnKhvrMMghCphBN24qaIVDJrBrmeB7g2Z62x7
         9z4wjKe5TgqpPsxN1F6MtFwbERWIIYczU3Vlcoi9Bn6Io4pS8zl9BxvD7OfIkvOk2DHe
         bKWOTx3ItGlZJtYz9ERx5/QSr4d6lkRb9ThyPESwSqEPXbfdWPFzLZ85HYqnnwwoanPc
         GvtQ==
X-Google-Smtp-Source: APXvYqwq/YfHOhrmZHkD7vjJE2TMWCM5ZcaZGqo7qwngyLyrDMEmQDpJGD3vf7HiLmlT/OfJiu4DXA==
X-Received: by 2002:a17:90a:360c:: with SMTP id s12mr15495527pjb.30.1564958992495;
        Sun, 04 Aug 2019 15:49:52 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.51
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:52 -0700 (PDT)
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
	Alexander Viro <viro@zeniv.linux.org.uk>
Subject: [PATCH v2 21/34] fs/exec.c: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:49:02 -0700
Message-Id: <20190804224915.28669-22-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804224915.28669-1-jhubbard@nvidia.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
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

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 fs/exec.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/exec.c b/fs/exec.c
index f7f6a140856a..ee442151582f 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -227,7 +227,7 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 
 static void put_arg_page(struct page *page)
 {
-	put_page(page);
+	put_user_page(page);
 }
 
 static void free_arg_pages(struct linux_binprm *bprm)
-- 
2.22.0

