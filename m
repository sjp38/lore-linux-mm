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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 760CCC19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32134205F4
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="elfpTxMe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32134205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A4626B0280; Thu,  1 Aug 2019 22:21:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 704CF6B0281; Thu,  1 Aug 2019 22:21:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D1966B0282; Thu,  1 Aug 2019 22:21:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 23B266B0280
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:21:00 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h3so46429247pgc.19
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:21:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4iYkOl3aeyTERThJenFq1/3UwJx4Onl0nTT+k7YLDaI=;
        b=Wwz1piYhfFa4FiZaUIGzW8jO3Svd0kCU9RP1hEqu1meQynoYWxwlIzbkMCezVL68lX
         wzLzwlD+a9L8c7/MZvQirRWjCW23scPfmH0lFRr4ahN/PBDZZeF+5nF51XiHCai2hS+r
         yQJ+q3kO1+5F2rZ5aI7NPZwtuRxJFfnjJXBAEyijJA8h+G3XZUFxvfhXJW1uTnzxEwM6
         JggzxWZVHcAqC1udmHSDUeIRqiUQERlbxTHUIc9GAHX12g8UrU2I2OVki9hyWqa4BrVG
         wZ6fN18nxdQxKundhPS9eNjXUUrfkshPtLAu0RBbfQWAdO086wSiYl2687xxzrRfcCyO
         pjeg==
X-Gm-Message-State: APjAAAXkHHcc+ZzcIQMEFwG6LkxvHbDrXz8CObnVzbuZ5KzM3xnW7rgu
	un8+Qf7JCeMpdS6fRFF/4BFOD+IgMvJajMCRnBZCOOcOLbQ5RSg+MH/zFy4qqzcy0WSmQEzHOli
	FMeZdlOYP///ZEb1l+Rr98M8tAGzFNTSjt6xcGYnNqGcgU31XSPn7BJgmcLD/zaUsTQ==
X-Received: by 2002:a17:90a:8c18:: with SMTP id a24mr1818758pjo.111.1564712459829;
        Thu, 01 Aug 2019 19:20:59 -0700 (PDT)
X-Received: by 2002:a17:90a:8c18:: with SMTP id a24mr1818729pjo.111.1564712459217;
        Thu, 01 Aug 2019 19:20:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712459; cv=none;
        d=google.com; s=arc-20160816;
        b=dVbZoN1kgdMvCrfl0F52MQb5LQhmLHlv224EorKwQRn2bxko+KyIqZrq0usYo3iO/l
         rwtv1duanJI5jB4RuMCfAlqHx088a4WfE59qNlU7eDT0c9JX8s3UlG9QMc+gag3FkKaF
         5JWOVUOuvU4fY9hx/9oMSpRv3aXoDDK9ycc05mbOCUIjodsPSM7rURmJ3XVRaEa6fVmv
         X1OPfPOOq0dz2hjJcdKp+6KsQwTEuST4jlc4L6uCYRCwmVbTZ3y3NRSjFAft6FJkJIeg
         fRmE1EBZ6oYxRiAq3Gxk7rKp8ReVifiA6xdlaUlye5A7YUCjRgYynwzwN8zhBervZkpA
         QF5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=4iYkOl3aeyTERThJenFq1/3UwJx4Onl0nTT+k7YLDaI=;
        b=zxsLDcrNOPTvtKmF/ILUj8N8hwPv6FjuHF0n1OqJXkyq0GD9eG+y7q2kUzahKOTaFN
         e+8V2w7yPv4ZojBdbDj9H8gpdP3/Y2s/ZwU67GFz3V9j5Q4ofymCIEk2dyjtxivRe3LY
         TZXhkLpF52N2PsY//zQBxGSTmIVyvOcbvNOjhFgCYk6hW4nHARpREvqBQcGiBBVy6kiZ
         Ri90nn+bnvNgXqEPb/Sxk6GejAWPXDR1Lsk9qMCCxhIxfditIMYXe/N8vq/ztVqCbZjf
         raarGlNXGeRVjMCrvM0Pkik+Yx/i5jMoodM+q4oKpnUnb/5K77g+7YTl8YaqmO+1Y0Tq
         tkYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=elfpTxMe;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c4sor88549110plo.34.2019.08.01.19.20.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=elfpTxMe;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=4iYkOl3aeyTERThJenFq1/3UwJx4Onl0nTT+k7YLDaI=;
        b=elfpTxMe1/6j0BhX2ft/28omzWdU5w7mpxF5KS6Ry8a8zkGJScYbqAJ2NTQjOpA+gX
         oQX8NO2qfr8fQYzhkmlI2m44i8n5UA95IshiSsHQfSaUB55LfEMP8Nf6Bwly/9Em6O/v
         kb75MLzprl0H6ilua+Tsx9/J/pL9/kQBkbd23F8nfmf7/S2UoqNko9rQth0i8PtjUyLH
         QNhM+JJQO3CxcyAMQTRjV2IrQz9Ukzpv3t7kO6uUD4p+f92uGnc2g/qdEf6YIu13QPQ3
         M8XRiksoxntjoSZ9RhVKNzEdpCIwtT4CToNN39nu0gxIxKKgNM9/D3+uDvkH0PFa7iEb
         mOeg==
X-Google-Smtp-Source: APXvYqzzllbFm5p1RJ6Hv9sdYEOY7jdZkiYuzxv4vZdIzU4+gyWXMgDLOAREt7Tj2iCCice8+nHYSA==
X-Received: by 2002:a17:902:24b:: with SMTP id 69mr123385473plc.250.1564712458970;
        Thu, 01 Aug 2019 19:20:58 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.57
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:58 -0700 (PDT)
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
Subject: [PATCH 30/34] crypt: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:20:01 -0700
Message-Id: <20190802022005.5117-31-jhubbard@nvidia.com>
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

