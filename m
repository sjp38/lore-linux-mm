Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B510C32750
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 20:57:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 099C120693
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 20:57:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XPofLF/P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 099C120693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43D0F8E0007; Tue, 30 Jul 2019 16:57:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C9358E0001; Tue, 30 Jul 2019 16:57:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A49B8E0007; Tue, 30 Jul 2019 16:57:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D99BB8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 16:57:13 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 71so36045507pld.1
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 13:57:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zIg1AeRgD/CqkmVywbx+SzJM6fRrXplz7aYhAvptzng=;
        b=Lb06agBKR5Ogp/ZPHWUJoeNRPBUZ9VGzn6rC1OFSUXSMUVY8R2iBrGMe2HrvnId2xP
         u7WEC3HtR06MrjqRTSsJfliN98Ng117Vml1mhBagfP7kJVKccIxHcN+fjW2cei4Bipfx
         I7c3GJomlJmlpSNm8S3zqkMrcj4yW/1BBOdq9sGWR1/PHZBe59KksDLioL+0ESxrFPkF
         HX4cESemipcBtvUUpcCp9mwNtmSIYEfDQZCEST3JoXSFLMhWgGvWSmSwzgD5VMhhQvut
         glCwVv+Rh7kY1jKFA4B658wITDW8ZTRsZ9aCf+/YpS/UdBPtMOQQFJ1tG6iVPC3aGj+V
         II1A==
X-Gm-Message-State: APjAAAXTGGQiIy4NZqtgJDF0kdqLoy7kOCrSh7tQ14QPBlA0RB04vdtv
	J/okeq+GF6NAxOkXueHfBwL2BFZQuWn9DMurWcs8HdhIPgkyb0eI8JDdT3VBpi7lFe+7UWVkFbP
	JMm3hcOr7hW7ltB2biViTdLaMMCFA+htNsJz0wn6WWEBCTGv70HMC4gQGmX88Uj2oKg==
X-Received: by 2002:a17:90a:20a2:: with SMTP id f31mr117573271pjg.90.1564520233529;
        Tue, 30 Jul 2019 13:57:13 -0700 (PDT)
X-Received: by 2002:a17:90a:20a2:: with SMTP id f31mr117573237pjg.90.1564520232700;
        Tue, 30 Jul 2019 13:57:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564520232; cv=none;
        d=google.com; s=arc-20160816;
        b=RHR+TlWKWvP8godTRmsviWzZXh+Y+UvR8oTmPGWW1LDHkA76AajXDHYnK9mJ87PVft
         j33Q9TlR26vhci99wSU8lQz4YiPNzNaWFCYbO6DYCb98c9qCVJQS1OuVIRXGWWu/tc3D
         ywrMebkt3yM4D2OVbqi8NBpP3qQ+yQIOnSfhvR6IYAWqqcIzQq3k4SRMktSDpTovmg0m
         AJhibDeaGpOHLBQQOK96Ob8b2m56LfcdA1Y/he9YbFP56uLwMKDDX8mlZA8+JuhRlESA
         hymgcK6bSuFlVuDxgGBwDy3YHRDTUmQYtidtK52rv+SO0L0GDdlL/vgZKITLZCaQGSOG
         XEXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=zIg1AeRgD/CqkmVywbx+SzJM6fRrXplz7aYhAvptzng=;
        b=aXyuPlSnEVEompm+ovWtrHxevd3ejYryYUtyvzTV7JpIvH99Y4vUa85SDYjryE+Mnm
         pY35mYOZYoF2nygJRFGFqtxXB17iksnBWQE80YWc0c1CaCzSTwRLw/BviyYOgTkXIWVN
         RBxQXY0DJuQZ8iXYhrb58b61IS854YqrIDBN1Bxw7RKQZv/dM2sMeAg324sEDUacgYKp
         lvsWvQlcsocWF2anN597MQJypy5LC7u8VUPyO13y+jGxR0lqeleJD9fi+bh3NijyAtBX
         iaLIv6aQXHHNM88Wa/IeEjoAdvOIRKCGjGx/jUXzLo/5nEAlvMH+MX3dOIaMO7HdUOec
         9OHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="XPofLF/P";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k65sor43351453pge.18.2019.07.30.13.57.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 13:57:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="XPofLF/P";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=zIg1AeRgD/CqkmVywbx+SzJM6fRrXplz7aYhAvptzng=;
        b=XPofLF/PHutz4HRxq81cl690l9JazNX7DE9Sz1LHW56Ma+PaWewPn4NCX7vVDtKrug
         q4GYLQHOLbQNIyzRjkilYec92LYHDHYE3s7umnjLyHZVoR8ACBwShBGZlhCQzJ0e/K9n
         G7PcNQdBdB1MIJeCd9Jz0A5GyrPYQBkVdaffdydfOlpBLG3dhqUxeiCBrG1LWqTE7Xqy
         zmL+9yVwrhVt2Kz5wb2SR2RniJWXisEJMoF7R3sZthPZBIVjkuCkP3ahQg4hWjCzfAjS
         HmJSUf3TZqxLbfGjRtE0Yjx4i11cxdEwGB/Fo/WLx+/qENW7fbOiVLgn4HM3pHlMEDwz
         K+sw==
X-Google-Smtp-Source: APXvYqxsCn2vX6p1aDH+4gab5/zzeAvDw245fAqNqTfAzQelWKMC8Rw1mqVzx4xsB8ePETum3mpINg==
X-Received: by 2002:a63:121b:: with SMTP id h27mr95395492pgl.335.1564520232325;
        Tue, 30 Jul 2019 13:57:12 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id 137sm80565678pfz.112.2019.07.30.13.57.11
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 30 Jul 2019 13:57:11 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Dave Chinner <david@fromorbit.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jens Axboe <axboe@kernel.dk>,
	Jerome Glisse <jglisse@redhat.com>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-xfs@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
Subject: [PATCH v4 3/3] net/xdp: convert put_page() to put_user_page*()
Date: Tue, 30 Jul 2019 13:57:05 -0700
Message-Id: <20190730205705.9018-4-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190730205705.9018-1-jhubbard@nvidia.com>
References: <20190730205705.9018-1-jhubbard@nvidia.com>
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

Cc: Björn Töpel <bjorn.topel@intel.com>
Cc: Magnus Karlsson <magnus.karlsson@intel.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 net/xdp/xdp_umem.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
index 83de74ca729a..17c4b3d3dc34 100644
--- a/net/xdp/xdp_umem.c
+++ b/net/xdp/xdp_umem.c
@@ -166,14 +166,7 @@ void xdp_umem_clear_dev(struct xdp_umem *umem)
 
 static void xdp_umem_unpin_pages(struct xdp_umem *umem)
 {
-	unsigned int i;
-
-	for (i = 0; i < umem->npgs; i++) {
-		struct page *page = umem->pgs[i];
-
-		set_page_dirty_lock(page);
-		put_page(page);
-	}
+	put_user_pages_dirty_lock(umem->pgs, umem->npgs, true);
 
 	kfree(umem->pgs);
 	umem->pgs = NULL;
-- 
2.22.0

