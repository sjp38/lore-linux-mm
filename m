Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9087C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:48:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A0182084E
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:48:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="nDY82R10"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A0182084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 348E36B0005; Tue, 14 May 2019 10:48:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F8B96B0008; Tue, 14 May 2019 10:48:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E7196B000A; Tue, 14 May 2019 10:48:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id ED1F86B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 10:48:08 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id k6so16147424qkf.13
        for <linux-mm@kvack.org>; Tue, 14 May 2019 07:48:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=v9eQGAXN/pUrwyhsEw4eGQ0SnWi81FsI3CN7zGHdMUY=;
        b=R/Iixo4YJzU1WixcNeIgnKD4NuO6JsdpurbrztU9tIG3vMenO9oewLxnprh8gKZAN5
         zxQhGHVagrheodPmOtIg7gclgs199H81E6ePUlrUWzNDrR7bnnQBbVveY9LJPGIDuJ0E
         xfLUGX9Bpx6qgOF6lnZXm5XZd36OqAPEq/f017OQKQb0ztaYJKp2CY6ks383JUBdKgbO
         qs8laDi/Bh0ppgnxl23ILrsVKBj3LpsKzmM494SvfJB8w0FxJ1yyDQGGiSW3pAKTx7cR
         jAA5W0GZblj55QWPEIay8dQn+jMCuS8NEUOvf/5wCzhVw7qNKLfZRe5gmYfFQrwGsKwW
         9CFg==
X-Gm-Message-State: APjAAAWgYEPLIVHzVaLMuEl62yvjE+O5laxsuyqn9RHagfUWycNXpVnM
	Zzzoa3CfI58nZChEEVo9nGx2mYv1GxR6DYPGPP8wpaLTO523VAWPWMGfFRzPnbLSRFxY+EL9Fc3
	7NA47YZ/HcIVaz6YCIYCx7qhev79jM+ljRklEtVnXy0XQnvezOyIsIUs9sayMdVqWew==
X-Received: by 2002:ae9:ef45:: with SMTP id d66mr28490846qkg.313.1557845288592;
        Tue, 14 May 2019 07:48:08 -0700 (PDT)
X-Received: by 2002:ae9:ef45:: with SMTP id d66mr28490739qkg.313.1557845287365;
        Tue, 14 May 2019 07:48:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557845287; cv=none;
        d=google.com; s=arc-20160816;
        b=OL/WJZCbCd+iot2wXXtGXDhJy1Hwz/gqOFBzlGpjyfpbGXDKSwGrSum8XCXNjDTlVb
         Ckb2OIZYD3Jqtl576jn+jQFpVRodi3U/yvXvdxRvchvce0ymOU7Lx5pfGVLu4OUqoNqc
         T8hBTM+S1wQTcTfq8bFn3E/IR6P2Br8+QWNkQ3dyECnvr+RGvDY3uT2qDhA1DnMvwTJ2
         25veZSEHgGO7b+CsFV1Efr/N/tKyVvgmw27yaDWunCBo2qrmHnrAHD1VZIl7DKSFXp89
         jgTTI+15hEI1lKL09v9lioultxBJGc61HNSN+KoxdCaHhvVd5LoFPwmQJvW46p+y6R5s
         Oghw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=v9eQGAXN/pUrwyhsEw4eGQ0SnWi81FsI3CN7zGHdMUY=;
        b=r+t/8CUyD6Pn/0lUkP9Xpki4io0KqVoyR0BjdR1+2VZGF3Og3DQDWG8Yxwoo/SJ2dk
         Xfyk+5+kd5Gm+xVXUFKFBm8b95F+goVJTKck49X0OVEPms7D+b6tKy4SN6xQeM+NG8pg
         imw+q+bfSijzse3YePapRuILbWorimksLQoFZQi3Z7+t+a/WCx/IcwYRIcrQzVg0T+sC
         3WUBHxp1vw+h9dHYRX1HhrIQ3+2Up423yqslnHa50turzx3l+tEvhbc2WXwYtFsOEW/4
         0XJ91MjnoZKVBLNK757rz8cjnEZnBRVU+JVZC1CSCtshbExyD8ohraZPgVlFTGmgeJyj
         Cfjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=nDY82R10;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n13sor1563077qtk.35.2019.05.14.07.48.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 07:48:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=nDY82R10;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=v9eQGAXN/pUrwyhsEw4eGQ0SnWi81FsI3CN7zGHdMUY=;
        b=nDY82R10ZFExPQ1BFRb0cIsRXMz1+Mbb5gLhwYj+P7wenw+vz2PGDVO3MW1ll4xmEs
         gzrdZELS8S8hCF9KgzMJiVhBrijLGGB98FkA8+R5fQM4kS6TCVEKcnjnmqEENZNN2g1i
         MIaN+82TeYtLkyYogEUBZJs5wC36oh/Lrj/mtbiGyb+InmfWr6WcxZ5AUVWPFFlrvyBG
         4/pj6sdMf1+RGHBtb7Fzr/WKYFSZbUrM0e04VzB3MN1farriSoCrf2lrxWkXLgFkKwSI
         ++gDxtWGnByHUiyi82arM6CP8Kw0joJB6gqMxBIk3ySoeP2uvbbsfusBhTd61y/daTbz
         mYOA==
X-Google-Smtp-Source: APXvYqzApoMig2QGgNA/X1ddscMp17wEIujDVgwIUcQLacZ1b7Qm2pChC9VvoBo44rkmkDMamq2H4Q==
X-Received: by 2002:ac8:2e38:: with SMTP id r53mr30002293qta.192.1557845286967;
        Tue, 14 May 2019 07:48:06 -0700 (PDT)
Received: from ovpn-120-85.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id 124sm7905551qkj.59.2019.05.14.07.48.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 07:48:06 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	catalin.marinas@arm.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [RESEND PATCH] slab: skip kmemleak_object in leaks_show()
Date: Tue, 14 May 2019 10:47:41 -0400
Message-Id: <20190514144741.39460-1-cai@lca.pw>
X-Mailer: git-send-email 2.20.1 (Apple Git-117)
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Running tests on a debug kernel will usually generate a large number of
kmemleak objects.

  # grep kmemleak /proc/slabinfo
  kmemleak_object   2243606 3436210 ...

As the result, reading /proc/slab_allocators could easily loop forever
while processing the kmemleak_object cache and any additional freeing or
allocating objects will trigger a reprocessing. To make a situation
worse, soft-lockups could easily happen in this sitatuion which will
call printk() to allocate more kmemleak objects to guarantee a livelock.

Since kmemleak_object has a single call site (create_object()), there
isn't much new information compared with slabinfo. Just skip it.

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/slab.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/slab.c b/mm/slab.c
index 20f318f4f56e..85d1d223f879 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4285,6 +4285,15 @@ static int leaks_show(struct seq_file *m, void *p)
 	if (!(cachep->flags & SLAB_RED_ZONE))
 		return 0;
 
+	/*
+	 * /proc/slabinfo has the same information, so skip kmemleak here due to
+	 * a high volume and its RCU free could make cachep->store_user_clean
+	 * dirty all the time.
+	 */
+	if (IS_ENABLED(CONFIG_DEBUG_KMEMLEAK) &&
+	    !strcmp("kmemleak_object", cachep->name))
+		return 0;
+
 	/*
 	 * Set store_user_clean and start to grab stored user information
 	 * for all objects on this cache. If some alloc/free requests comes
-- 
2.20.1 (Apple Git-117)

