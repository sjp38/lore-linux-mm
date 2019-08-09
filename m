Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 506A5C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D3792089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D3792089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B84BE6B000A; Fri,  9 Aug 2019 01:49:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B38796B000C; Fri,  9 Aug 2019 01:49:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A25DD6B000D; Fri,  9 Aug 2019 01:49:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 858696B000A
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 01:49:11 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c207so84603693qkb.11
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 22:49:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=DkgRyBFTw1NOJeXBoWug970nIMArpHVJngzRV71MoTc=;
        b=MljaEvdc2BcGsVhzcTXxO1/5leP3NFTroGkLQfvK46RtXmXPr3EeYOxkQEtLxSQJ+i
         tYONRgF80KiZWDiiLGKBSLFa3Lb9yhAAWLzGzLquSYTjZBCjWdNESdjLftQcdAUo7NCM
         wz8D9FepjnxxPO40bnrDuaRJOnab/HoldKho45lbhG2E0ZMyE5xBiwLd6elVBT1vIEHY
         vXxGZlRwIWFwz1maLnGlydgHt34RB85YVCAmVpu3nh/Maub0xeUx/JlRCRHmB6o7s3iY
         JXbjXKanuopT8PZ2jtrGXazNkQv/AvckruS1gKqaU8PTzNuwOeKZsq15r3cHOGeSPnDr
         LlBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXwHqH5oy4XFM/WgQ4rpjmAt0aMqc+2EY/LOyYoGdLpJo8YJpwg
	Oi7CSfh2jlMI+0cNZRVrC7LzGt13hVMgRFcdqxqqPWE8tQAHwpQcVnkllN78rqhYVefGEK3B7aP
	VaB+9O+ynMRYJlNCvmxrMjAMOWLZOszJeDlmqkaZZucvKzl7788KYDmM6hPpJKBJwIQ==
X-Received: by 2002:ae9:ed94:: with SMTP id c142mr4531928qkg.70.1565329751302;
        Thu, 08 Aug 2019 22:49:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzz2XUIbHS0Vo8UtbN55sjomKBaUlDG7Pexfa56+5M4qVzf4swG+t+rSNreKStgIA7NMdau
X-Received: by 2002:ae9:ed94:: with SMTP id c142mr4531903qkg.70.1565329750743;
        Thu, 08 Aug 2019 22:49:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565329750; cv=none;
        d=google.com; s=arc-20160816;
        b=kX33KnfvTSO0BkLrYNNpYrg/jM9r67sdxsXHgpV2DLHI1d/aPNLPattb+gBm+l25ky
         nWOkTVGmAUsWkyEdToQdd6165dAZPVuHA1vCpLtU5gJ/1IKUJI660oEFuc3p3RKeV20p
         3Wn0C0xWGEiJhvFNWAIY+r9o4hcsQkxyrlIeipUy7Ywpxp4OPslJnFnTFGvuFtdoD5I1
         1kQAjhIws2NlWjS7Xmp+p+mGp3Nh3thL5jYFEKm0fCG1z230aRBczpa5sgFXDLtmNiNk
         lASMycrz/ZMy6TzeUnW5d9wJRDnKr0naQ/jbajRVf5fb9wLNR7Qw+nZVmbsGMxeshtZu
         YLbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=DkgRyBFTw1NOJeXBoWug970nIMArpHVJngzRV71MoTc=;
        b=BNch3S7jzpPWBM/Okh5JpTS2DAnvL5oea0+O6KjKEsWWxFkQXX/qyBrOTe9cuMsk3P
         iz3HQ6lSDmiE2xjH2HJBOioAZ1Ix9nE0bfTQWC3LxhLLVWoa4Xz2ezZhqwYGVg1Odi/P
         9W/syUUlsg7qecb8vc8msP1qwpNRubvwS6b3BtCIHhMxPB7ZUPTa0EQQtYPOWrbBuK55
         DstSuJR7vJ4ZrZjKKYhyzCksmtNq7Bjl2juMoYqrUCUEUZp6Z7uLY27Te3wYkUMAivVs
         KXqutJGtF1h56GPBmomyrEMNor6e5jtdz9NaU0kHm3eRZjjOUIHQ7GtYHQipXuZtn2jA
         ZEZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h19si10975611qkl.44.2019.08.08.22.49.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 22:49:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F0353970DD;
	Fri,  9 Aug 2019 05:49:09 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7596C5D9CC;
	Fri,  9 Aug 2019 05:49:07 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V5 3/9] vhost: fix vhost map leak
Date: Fri,  9 Aug 2019 01:48:45 -0400
Message-Id: <20190809054851.20118-4-jasowang@redhat.com>
In-Reply-To: <20190809054851.20118-1-jasowang@redhat.com>
References: <20190809054851.20118-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Fri, 09 Aug 2019 05:49:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We don't free map during vhost_map_unprefetch(). This means it could
be leaked. Fixing by free the map.

Reported-by: Michael S. Tsirkin <mst@redhat.com>
Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 17f6abea192e..2a3154976277 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -302,9 +302,7 @@ static void vhost_vq_meta_reset(struct vhost_dev *d)
 static void vhost_map_unprefetch(struct vhost_map *map)
 {
 	kfree(map->pages);
-	map->pages = NULL;
-	map->npages = 0;
-	map->addr = NULL;
+	kfree(map);
 }
 
 static void vhost_uninit_vq_maps(struct vhost_virtqueue *vq)
-- 
2.18.1

