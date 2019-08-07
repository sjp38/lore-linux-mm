Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C37EC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED193217D9
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KDwx8fQC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED193217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65CED6B0271; Tue,  6 Aug 2019 21:34:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DEBC6B0272; Tue,  6 Aug 2019 21:34:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39B616B0273; Tue,  6 Aug 2019 21:34:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0D466B0271
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:14 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id ci3so6849951plb.8
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kTcRkfjdEL9HxbTfItIV90QFm+wmUvO1k55I5bm4do4=;
        b=RpS8Oz5x22+eGwqXdNZ4ajuLfeT0J2QuylfjGxoHd9PAF6+sSY3xAB8TKAs+BaCOfU
         wlujqJlIdcwx2F2tUq+AgWI7Rh5rJaB23ZAM/zUfGe90jWbKqoKEfUVX4Fbxx5219scs
         p+0SUARAoOoNLDNLh5HXBiD9lPXyAIoaqj4W37IqpzM9VlHnviRnMLwXPQx5C4lZaDzh
         AORia9Yhizcby8/Hhz2W+jxvWSeKOdJ6dk1mqPz7boneHWWzQiPr8Sd1Xn7Q0a551si6
         w07//eVtgEDIzdNuhyLWP77t1LoTdAOAQ391VjwF0APrPNT7GVjH8KIUm17kEIiOCRNo
         XvYw==
X-Gm-Message-State: APjAAAXBHy+BNzWIz8uKhYvvq5oYPJwLIi3T2XV3AaHxX18oF1eVQedg
	cluBdg/+zCKl7f7VkTk9y33QRwAJaLlohVj/mS94By816dhbAwTHKIPXI0KQXZmvZWqthtkPv1K
	gl6gsG+wk/7DdizYmpE1IuGbf6X34KBeUaWm4PU0NQqBbaFfdEWm/J+SLQpNdDLwfbQ==
X-Received: by 2002:a17:90a:cb87:: with SMTP id a7mr6195573pju.130.1565141654639;
        Tue, 06 Aug 2019 18:34:14 -0700 (PDT)
X-Received: by 2002:a17:90a:cb87:: with SMTP id a7mr6195541pju.130.1565141653979;
        Tue, 06 Aug 2019 18:34:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141653; cv=none;
        d=google.com; s=arc-20160816;
        b=Sk8iDmUbgzqhW9Q+abLpxSne8Asd8P9i78noDvRJdzBhY6K/sXKe4NAJWKmbiMamWi
         MIRe5Co/dFGYioPAR6vZt8kPYFdzaE5NEP9wlgyaDsAOxvP7y6LOeoqssuQ5HkKzr78V
         5hGFJRpUP3AjDYjd50ga+Zk71s9GQjQCEmiWSY/xmI+MqhN1MmQIXCuEoM7GxCBB/Kz6
         8tsY9HXx4rmYrC0sDiPjisVeQNvdXHIezXueGOmmCpWrPyF3gO4QBiJzUNJ177rXPHmq
         puDQlY0icK7k6qWURM5g1y1m4JwRaQO1LLHMVSdH1kKc87/cXIy1AJDe9dXkZzj7iNl4
         3Pmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=kTcRkfjdEL9HxbTfItIV90QFm+wmUvO1k55I5bm4do4=;
        b=c7YqzdHflAR+0pbuY846bxEotZRgffeTIw1IzGK4rjQhjGxeUeYCd0cUl5/FvTFeps
         6gLIRzqW4dDNwTeViKgbgWy6xlllG0eJ7jH6OUBWMrX7YZzW3jO2yGqsrF7wQVUHgesq
         9TRk3ypqDScX4HsFFjhz+M5r+hCKxoE2v8K1blkCOjpKttVmlpPRP0YUaDl1/ac9e+fl
         dBNAgN5FokRy4wVLoPZNytLhTwaAVOidftoZNyqV32vgphar16QGA2q0LLbfGYEMIyNy
         IqSjOc2vCw69l/BQ++9Jy2GlhlgSYKNKmYgPzKkqc8dh6MWs+bTJN2g97k3/Ti7qu6Pp
         oKsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KDwx8fQC;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w20sor106399300plp.27.2019.08.06.18.34.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KDwx8fQC;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=kTcRkfjdEL9HxbTfItIV90QFm+wmUvO1k55I5bm4do4=;
        b=KDwx8fQCZQ/Suzu3VWi1DDiS9f3wTi5qeR5KhjjsQerQ6jWb9Bppmpi69n/V7tCxcC
         9V2HGmZDwg97QSRgi6Hzl0GWRBp4H3fcCqkNmUDvJ7PxDk1fQHC9lxTEdaxbxQEHg95+
         fmJWsxqnzJxJ030LBsGzIkf3pk8sgU5o1+lx7X7ZwO38eZaDsEUDZZ+Gf9yjWoGjqdBb
         oE7CxyrW2H4Sq40LC5GKmO3wadn0xgnPrP2IQTLB/VxU0JkFqP6vTrlLsm15L7ZnAf7Z
         6nnOQfF4c4+DtdbQKQz7daub11+4pw4UtoY7fINHO6b6C0kllebTtI7UQsSaNXpquZs/
         z2sg==
X-Google-Smtp-Source: APXvYqzTT0+13248qiTrSGNvS1mzJ345uGp41Ak44ir6kC277kEDTytzqOp0Yto6oZ69oylCJdvvLQ==
X-Received: by 2002:a17:902:f204:: with SMTP id gn4mr5916565plb.3.1565141653735;
        Tue, 06 Aug 2019 18:34:13 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.12
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:13 -0700 (PDT)
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
	Jens Wiklander <jens.wiklander@linaro.org>
Subject: [PATCH v3 18/41] drivers/tee: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:17 -0700
Message-Id: <20190807013340.9706-19-jhubbard@nvidia.com>
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

Acked-by: Jens Wiklander <jens.wiklander@linaro.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/tee/tee_shm.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/tee/tee_shm.c b/drivers/tee/tee_shm.c
index 2da026fd12c9..c967d0420b67 100644
--- a/drivers/tee/tee_shm.c
+++ b/drivers/tee/tee_shm.c
@@ -31,16 +31,13 @@ static void tee_shm_release(struct tee_shm *shm)
 
 		poolm->ops->free(poolm, shm);
 	} else if (shm->flags & TEE_SHM_REGISTER) {
-		size_t n;
 		int rc = teedev->desc->ops->shm_unregister(shm->ctx, shm);
 
 		if (rc)
 			dev_err(teedev->dev.parent,
 				"unregister shm %p failed: %d", shm, rc);
 
-		for (n = 0; n < shm->num_pages; n++)
-			put_page(shm->pages[n]);
-
+		put_user_pages(shm->pages, shm->num_pages);
 		kfree(shm->pages);
 	}
 
@@ -313,16 +310,13 @@ struct tee_shm *tee_shm_register(struct tee_context *ctx, unsigned long addr,
 	return shm;
 err:
 	if (shm) {
-		size_t n;
-
 		if (shm->id >= 0) {
 			mutex_lock(&teedev->mutex);
 			idr_remove(&teedev->idr, shm->id);
 			mutex_unlock(&teedev->mutex);
 		}
 		if (shm->pages) {
-			for (n = 0; n < shm->num_pages; n++)
-				put_page(shm->pages[n]);
+			put_user_pages(shm->pages, shm->num_pages);
 			kfree(shm->pages);
 		}
 	}
-- 
2.22.0

