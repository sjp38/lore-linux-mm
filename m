Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55720C31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C34420850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="FK1BE5Q4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C34420850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC57D6B0271; Thu, 13 Jun 2019 20:44:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C72BE6B0272; Thu, 13 Jun 2019 20:44:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF1526B0273; Thu, 13 Jun 2019 20:44:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 825D66B0271
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:44:59 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 18so643516qkl.13
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:44:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TdUL2Q0xcyDT6JNdu0gecxArNl/zROPizNaMNSjNgKw=;
        b=C2T+wn0jgBnhaMLPQwY+mW6YyQ9x93IQy13gUoVQ9Zplwph8aYsYfPa6UZLRU/NIM1
         BVYyjRFYAVMcaoddRVAEXEvjnoa4kX7XEikFSLzAWUZ9KF6MXnp1LLkZnzdlRyyDgbbA
         9f5OCh62aDX4l057680oSdGIXccoc6euCqLk8tF8sZewoCyY7vRAjhUCqalL0PWcoS2m
         NjZIDBzYgOmGoIHarajSCA27oqEjqRY/iSS41Ajcr0rQ1vhPJar2vD4eMSZ49qcFd3Hh
         0vsqKgySwuBBJuYB7vRFgu+9fCsAsuRemyifAcP1+/Cyfjrzvgojz3d+pTosAqYM6wDL
         2uXg==
X-Gm-Message-State: APjAAAWcVynLSPcV30FQ8DU8He0tjYettOxPEsfxiHW+Ljm/Mz7zmo9y
	qBinhSbPJQvi4UqB0QEbA+o8wMvOJM/a0vEVQdhFa4Sq1dnLiE8Tw9LW19/jUvrIzJ9gtLi5nfr
	DqjcR2l8SE6iW9Lx+zU/wMJB4vuSrG06Du1seWDEDQIBU4xQumanK8aI1PtFALMDQkg==
X-Received: by 2002:aed:2389:: with SMTP id j9mr51873358qtc.244.1560473099301;
        Thu, 13 Jun 2019 17:44:59 -0700 (PDT)
X-Received: by 2002:aed:2389:: with SMTP id j9mr51873336qtc.244.1560473098742;
        Thu, 13 Jun 2019 17:44:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560473098; cv=none;
        d=google.com; s=arc-20160816;
        b=KrPzUQITDQcapdmE9LLc6IC6+2suV84ro5p+6ZY/OKq7hYgE8OHp41Kvlp64Auqcbc
         LKgMbwg0i85uqcQ6cOOO8dllr3sA4+hFmA+bvSJCuWTWLagLNAZbYQwEAUDpasfimGQx
         TKHS1s4Z5+eA/owmDQspvhSmaNMf8p3WuPS9VMvlCoWvgWLRfqKhckF85mWoUNdJnwoQ
         5OdcQ58g6tV5OaXTjobkdoxEOrTkTSMrA2ESEImt8FFgq0aTWDjHY5NkhECipfqvAEC4
         YIblyqZyjZFyEUnQD6Tos+SRAq6cudH4X3lS1E927fZiSx84jPdcmDJUA8iaW1YxobAK
         DGcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=TdUL2Q0xcyDT6JNdu0gecxArNl/zROPizNaMNSjNgKw=;
        b=yj2ZI2Emlnn9p01x5LwInpqwqOpKxPrYwnc5uAxuFLhr7KixR5nRI7P8cyNWnEOCAq
         EGjeOfLKC82xwboiJ6uzcig7fA2vmruK8YzvQj7afdvFTbQ4bNlkWla93xJYz77+HUET
         kOd/HOTvUjoflW/LPd0oXjDQdVPFD4ytWyszjmv5zZ53WEFOMSe8blDu+F2knlbWFroE
         eqV6gkLr1cxYBbY11/ld3GQsN0Jfj7okYX6K1jDrtHuHRKElMX2/drG2uhTSmb5avqiB
         1QXHJ1Rxd5VChPJqzVQ5pxClJcNtzh6x99TEoGpS+oo9PseTVhI4Ar+tWhKEtG1XMGFx
         UJnw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=FK1BE5Q4;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4sor2370998qtj.16.2019.06.13.17.44.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 17:44:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=FK1BE5Q4;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=TdUL2Q0xcyDT6JNdu0gecxArNl/zROPizNaMNSjNgKw=;
        b=FK1BE5Q4R1zyEjUAK720jTuxSx/cyRhVSQ3jayrUcNyqoaPlGBfGmGC1CPOx43s3ST
         6RpK5IdpVUApoJZo8g1TT+C5zdvZ2TG9uTPr7XHg6jJi/A9cEPbHcheLCuTa0i1x7Z41
         Mi3bwHwKr3TrXQAMy8P4kjfKrR78HOCBwiNjC5ZDJZ0bKUEU0G6TbXkgv+rpTyv/xlcc
         dIOmYy6zgWm5Iw4sumeXpNYtGyd/WNLx1EtYDSkyfOURkacd+3GKhBbELl5JFem6hlqX
         2IL4K40Gw3ZaHhwFwAEd4IWGIF1j4HktqVkUa6VK5L2oBj8qFHmE/mdZt+ga7o2HmLyu
         aP3g==
X-Google-Smtp-Source: APXvYqzF52VUT6PLbBdFr+9hAJYSTEw5qk29kEu9lNT9XBNX8ynGL9sSdzpvwppRLNVS4ebk9QrzSQ==
X-Received: by 2002:aed:224e:: with SMTP id o14mr78885704qtc.271.1560473098488;
        Thu, 13 Jun 2019 17:44:58 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id n48sm812748qtc.90.2019.06.13.17.44.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 17:44:54 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbaKr-0005KK-Vm; Thu, 13 Jun 2019 21:44:53 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com
Cc: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH v3 hmm 09/12] mm/hmm: Poison hmm_range during unregister
Date: Thu, 13 Jun 2019 21:44:47 -0300
Message-Id: <20190614004450.20252-10-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190614004450.20252-1-jgg@ziepe.ca>
References: <20190614004450.20252-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

Trying to misuse a range outside its lifetime is a kernel bug. Use poison
bytes to help detect this condition. Double unregister will reliably crash.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Acked-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
v2
- Keep range start/end valid after unregistration (Jerome)
v3
- Revise some comments (John)
- Remove start/end WARN_ON (Souptick)
---
 mm/hmm.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index e3e0a811a3a774..e214668cba3474 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -933,19 +933,21 @@ void hmm_range_unregister(struct hmm_range *range)
 {
 	struct hmm *hmm = range->hmm;
 
-	/* Sanity check this really should not happen. */
-	if (hmm == NULL || range->end <= range->start)
-		return;
-
 	mutex_lock(&hmm->lock);
 	list_del_rcu(&range->list);
 	mutex_unlock(&hmm->lock);
 
 	/* Drop reference taken by hmm_range_register() */
-	range->valid = false;
 	mmput(hmm->mm);
 	hmm_put(hmm);
-	range->hmm = NULL;
+
+	/*
+	 * The range is now invalid and the ref on the hmm is dropped, so
+         * poison the pointer.  Leave other fields in place, for the caller's
+         * use.
+         */
+	range->valid = false;
+	memset(&range->hmm, POISON_INUSE, sizeof(range->hmm));
 }
 EXPORT_SYMBOL(hmm_range_unregister);
 
-- 
2.21.0

