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
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5C6FC32751
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 610372089F
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="amp4rnRk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 610372089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2F0C6B027F; Sun,  4 Aug 2019 18:50:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A65A36B0281; Sun,  4 Aug 2019 18:50:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DF1C6B0282; Sun,  4 Aug 2019 18:50:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 55B236B027F
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:50:08 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x10so52215911pfa.23
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:50:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4iYkOl3aeyTERThJenFq1/3UwJx4Onl0nTT+k7YLDaI=;
        b=Sld7f9dF/7XTDxzuLpM36ACY5nXDpeuL5HAoG11nQa8ju8q7HyPet5VBzt9AIxOjMg
         l3qOEI4mBq/ZnxfgpIjp7PV9qwDmZ6T9iT4aVTdSLnEPscoxXroemek1l7pSs+vatYEj
         +e+CHgllp3INSW5Qhj4nURRz4eRv/jeQKfQk9JAjdQa4P8u0T7cqr5UHizA/npxQej3m
         Q+Y0lA/kP9W0M3/cq3GLrZzmKnAywGFa8a/vkAhLOxACJt3hK8hBXIIcrOsoy7sM0FNa
         FERwY0z+Yx/2fsRKSaBbWpgif0kFdhmcbfHNACLwaaKi3WzXc+DPVG2OXjFRXwn15EVn
         TQ6Q==
X-Gm-Message-State: APjAAAV5UArWXCpbi0t2e9jnLA+hpu4WAr3n+O8q7GrqMWdPuGOUTKEd
	jQN39QRu2cLbV3l7SYomO5V4vJXuP2BiN6gxWkgiXcq4Cz4F5UgH9KNWpOuB7ytaHVrOVDCeBc0
	Rv3mvn6HPG7I5JkB55cd1EaAe6uWiNgmkHdvJQWTQlf6hfcPEHEkW2lS+Ri5O+fubtQ==
X-Received: by 2002:a17:902:86:: with SMTP id a6mr55251522pla.244.1564959008057;
        Sun, 04 Aug 2019 15:50:08 -0700 (PDT)
X-Received: by 2002:a17:902:86:: with SMTP id a6mr55251492pla.244.1564959007238;
        Sun, 04 Aug 2019 15:50:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564959007; cv=none;
        d=google.com; s=arc-20160816;
        b=gg7dH30raIrQi5sMwv/ascbVdkWbNf+oUm2RLiEQXbGKmjJTeEg5JkKpX1DSemFu5v
         rlsjQrDsz16FdT6sGL4Fg6Y5nCaRFTXGCE4EnjdBFKshn5sedqUHfb9JT4yS7wOXssHm
         rFbB8aGirUJg9kdMbL5ZACJQucsHZlG4EaAiDvxxn8MdZm2dohQll+VHrYQ6jFH5gEWI
         YsZA+0H+3rlJiY5/zIjsSA8R0WTLrnGCjplg9CfRyHEqN4D+zj/oG/hGE6iMijX9jtBB
         O9VYsFZkV2aQrzFJyLG+iKi5GSIK8tI8MaMOW46ybwnshsCImWxIV4BK9LDOJFxViuOb
         WTSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=4iYkOl3aeyTERThJenFq1/3UwJx4Onl0nTT+k7YLDaI=;
        b=Sqm40VygBjmk9fijmGA2wCHPb5maRrz0A6we/m6p7p6qvtBCoByEXKQxCfURP//usw
         Ai+pwDOhX03xiuJbxhEAqUrtiKGzouF0kGAGzk4RDI2+9aKdcHi8WPpu7K4D4ZgiQaiP
         IGMg7bKCgtF3MucgMWNfTxo3BLt+PbLLJowKX/OrxUG6wRP7AaYnmvrjvWjgq6cKUyCH
         NXPc/nCBB1I6Hss80Ay1CBxscyddqKIbQd/W1P65xAeR8OXhU6Zeyt3DNhbdWnXKdBSk
         Pvcfa8d5I+XDE+Ytm9UFLJ9HuUeUqO8K/EqjC1gm6/OZrZI86t7e2rw0Ed3TICZFxLXU
         OvPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=amp4rnRk;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l10sor98020234plt.10.2019.08.04.15.50.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:50:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=amp4rnRk;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=4iYkOl3aeyTERThJenFq1/3UwJx4Onl0nTT+k7YLDaI=;
        b=amp4rnRki7aZFblJwd+WR3AEEzT5jM0SqyuAgEV5CpAXAAopEM+ITm1VpHO/SXfmvR
         bo3NeFkBoHD+nAtlrBJ99G13P743PgNgDEkm2beH5ytNMeAvvksIb5/nFkswd7I26BcB
         Cu1H5Ec5GdgS9K1iSW46QqjiHGOk9ncTBdveqncGI12f820ka+y3wAT0qtpPsphaALcE
         KARWU4xHW0EFsjyrCk3ygT7cspgIvwlFXf07QJTASmi0+CbMzKJ+WTLfULPC2/v9VrXO
         To6FnxsBZLTmhG738lrtTmoKuXplA6aK9GPBNooGQXp1H7hHSJ+TLir+Hjd5setkxK8q
         WV8w==
X-Google-Smtp-Source: APXvYqxMhyr2kFbHr1O04Zbn2AO0Z+HHRdZeT7lsPwl/97dZ/e7++C1RY1spQOQBhYkgPZq+HBfy0Q==
X-Received: by 2002:a17:902:20e9:: with SMTP id v38mr45178412plg.62.1564959007040;
        Sun, 04 Aug 2019 15:50:07 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.50.05
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:50:06 -0700 (PDT)
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
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S . Miller" <davem@davemloft.net>
Subject: [PATCH v2 30/34] crypt: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:49:11 -0700
Message-Id: <20190804224915.28669-31-jhubbard@nvidia.com>
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

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: David S. Miller <davem@davemloft.net>
Cc: linux-crypto@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 crypto/af_alg.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/crypto/af_alg.c b/crypto/af_alg.c
index 879cf23f7489..edd358ea64da 100644
--- a/crypto/af_alg.c
+++ b/crypto/af_alg.c
@@ -428,10 +428,7 @@ static void af_alg_link_sg(struct af_alg_sgl *sgl_prev,
 
 void af_alg_free_sg(struct af_alg_sgl *sgl)
 {
-	int i;
-
-	for (i = 0; i < sgl->npages; i++)
-		put_page(sgl->pages[i]);
+	put_user_pages(sgl->pages, sgl->npages);
 }
 EXPORT_SYMBOL_GPL(af_alg_free_sg);
 
@@ -668,7 +665,7 @@ static void af_alg_free_areq_sgls(struct af_alg_async_req *areq)
 		for_each_sg(tsgl, sg, areq->tsgl_entries, i) {
 			if (!sg_page(sg))
 				continue;
-			put_page(sg_page(sg));
+			put_user_page(sg_page(sg));
 		}
 
 		sock_kfree_s(sk, tsgl, areq->tsgl_entries * sizeof(*tsgl));
-- 
2.22.0

