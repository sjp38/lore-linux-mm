Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB3DAC32753
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 938FE2183F
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="S3jwFjBv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 938FE2183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 312446B0007; Sun,  4 Aug 2019 18:49:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29C666B0008; Sun,  4 Aug 2019 18:49:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F0216B000A; Sun,  4 Aug 2019 18:49:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD4A76B0007
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:24 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id z1so52154169pfb.7
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WGaquJbd5n3vWHVjzVcVo6+uSZsjc3dg9cLGAnxVc2E=;
        b=kG3TxRmsbti85XwnTM+0wptuRu4u/9RlJtbZqHLiVXD5SILN7ZrBp5SVmD7XKzne2T
         p1FcJ9l2b2nRuFr7NMtN3RO3SklEgeCCCDz7GM2t40/YtNeQt178xxa0+sGtobq4p6mS
         3Azj7PbFiRWogshlA2jqECILv8wkowPkUxjGWReZ/sh9WezepcCkVsWc1+6bq39t3Bd5
         DXcXFiwOdCsCpxrtcuI6m0UbgppNVSrqKB5HW3+8NdIp01i+/+lgtFG9QQzXh61VsgHC
         jaqtGoomDsVqG9cNwLsU2bM0JrMY+HzzM+j9q7mFtVAKXlKZTIea6zyiFHeDQtqTQrsU
         WZOg==
X-Gm-Message-State: APjAAAUsnqbW/ULUFoaLPj6/SPPhM2UEeCi3j4syFh1eoMXVpkHgPok0
	riTCfKnqtcxVwdWgHlLYWitBrcqEMhQcGxnAB/cHhJo5SZ/ZPKiBp71nRtedYdLYz2lvi9eMJJT
	fdjzBOgF2uXyjM8/x3ZLEPmM0ARgOd4XXbbBfZUC6PmQrp3lEP2zWWdAIRoe7ggGVgQ==
X-Received: by 2002:a17:902:aa41:: with SMTP id c1mr140676933plr.201.1564958964548;
        Sun, 04 Aug 2019 15:49:24 -0700 (PDT)
X-Received: by 2002:a17:902:aa41:: with SMTP id c1mr140676908plr.201.1564958963798;
        Sun, 04 Aug 2019 15:49:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958963; cv=none;
        d=google.com; s=arc-20160816;
        b=gTgacN1jugYbefDP/AARJiOJsduHtDVjNupxHfDP3u0/Hs+WF8caDG9BzS8uKuidNj
         EGBRF2cHTg9Kd5JJsP2uRnn0KzP3AdJdMkC+ZDQH5QlTUrzDtTUUej3qEiqwKeR647LW
         JDD7C9/bnBwD832nLZMNg7oeJM/ZdNs1+UBJhBL8or1zcDfVp681EvBcuQIg0iGlcF9c
         rXM2N/2Nw7d6nF+NGf/JpWm1rUptYIKPHkQsQeP03sp+1LnzHAre3LOPxxPsu1DDi6V8
         ftVqBS0jIGudzlWb43tm7Cti8ZaJj81RMrBmdzggZ7qYVuFgwdYk8koAoLPpN3kcgAEp
         AxMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WGaquJbd5n3vWHVjzVcVo6+uSZsjc3dg9cLGAnxVc2E=;
        b=J+XqYIXTVsZBbzAMxu7Hxu+VgeGlY94XZ7XRLIfKa+S34ARCzH0Q07mUfBjdvxEUx3
         0CiTIpdiCx8/iczYVSt2fonxsgtLNgPhX/BNW7enNrErWtY6XDJn8z9GxnKGOxlWvNJC
         wclFkFkvltxSIqE+Nc5gGSM6uh2MPeAQdGDC45Y2dGjK3aoDsyVFrjvJ3yoK+aQq7vKM
         8kiCc0TW/2/M91QrTzn/zsDy3at+QqXZaiF4Ut6ri2iEZgww9QoeocXhBSMjDT4GYlxx
         LW1ol4qSkZAEgbSukSgQ2VVCY8zRAETEG3Jkwnu8Ew4wVmbIVYU/j13NwciBPr+zuRQP
         bKrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=S3jwFjBv;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x18sor57187084pgx.37.2019.08.04.15.49.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=S3jwFjBv;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=WGaquJbd5n3vWHVjzVcVo6+uSZsjc3dg9cLGAnxVc2E=;
        b=S3jwFjBv5vti4GSNOLl7usS2vDqH0Q9mdQIeQBRHCABbXZXQSp9OsVY/w2xyL7nTP8
         ZYecNdZYrgO7L+BkQcVPzicUza9nsgbAymJTn56ppaJJ1MbzTKSlKgcZSuVPBHENjv96
         hkgFAzqYxwazXKgNX9N/DjLopqfptr24zOfeivm8zYWH/Y75M1kPiFzhZPYTKsRYejq8
         i/m0sGMLE0jqJ3DENlV+rsSfWOzYUSK0mHJPDAK/WyMC/O+T7ek80SstkS2+jwGF+2aN
         2FgMJxAUKbEXaB1QNjEZ05NRrBMlTBOCQS3Bubk6f7+zHMTxlbMDQcuH/aK8PZQ95vOe
         ii3g==
X-Google-Smtp-Source: APXvYqzMm6zKD1x+1cfVe8U+T090I2azs0Ee52Xlzl7grLFlv9DOqy91TsDRd0lMc4ZI9h+s7gPOKQ==
X-Received: by 2002:a65:41c6:: with SMTP id b6mr76655023pgq.269.1564958963508;
        Sun, 04 Aug 2019 15:49:23 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.22
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:23 -0700 (PDT)
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
	Jeff Layton <jlayton@kernel.org>,
	Ilya Dryomov <idryomov@gmail.com>,
	Sage Weil <sage@redhat.com>,
	"David S . Miller" <davem@davemloft.net>
Subject: [PATCH v2 03/34] net/ceph: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:48:44 -0700
Message-Id: <20190804224915.28669-4-jhubbard@nvidia.com>
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

Acked-by: Jeff Layton <jlayton@kernel.org>

Cc: Ilya Dryomov <idryomov@gmail.com>
Cc: Sage Weil <sage@redhat.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: ceph-devel@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 net/ceph/pagevec.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
index 64305e7056a1..c88fff2ab9bd 100644
--- a/net/ceph/pagevec.c
+++ b/net/ceph/pagevec.c
@@ -12,13 +12,7 @@
 
 void ceph_put_page_vector(struct page **pages, int num_pages, bool dirty)
 {
-	int i;
-
-	for (i = 0; i < num_pages; i++) {
-		if (dirty)
-			set_page_dirty_lock(pages[i]);
-		put_page(pages[i]);
-	}
+	put_user_pages_dirty_lock(pages, num_pages, dirty);
 	kvfree(pages);
 }
 EXPORT_SYMBOL(ceph_put_page_vector);
-- 
2.22.0

