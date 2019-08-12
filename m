Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08B5BC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:33:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9FC320820
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:33:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tcfg65az"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9FC320820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 713626B000A; Mon, 12 Aug 2019 17:33:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C38C6B000C; Mon, 12 Aug 2019 17:33:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B3686B000E; Mon, 12 Aug 2019 17:33:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0253.hostedemail.com [216.40.44.253])
	by kanga.kvack.org (Postfix) with ESMTP id 3D33D6B000A
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 17:33:53 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E7214181AC9AE
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:33:52 +0000 (UTC)
X-FDA: 75815078304.08.dock84_5c06f02987131
X-HE-Tag: dock84_5c06f02987131
X-Filterd-Recvd-Size: 5545
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:33:52 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id p184so50354699pfp.7
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 14:33:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=N1FHoD6ZMNB/7wrUWG2IW6DScPoWU0//Swe9DNcA3ZM=;
        b=tcfg65azcnEOcAutLjCvNZczVJUNMSDMM22VOiQH6xAp2XF9FMR39o5JF5QZ+k3fZN
         UsYAExWzvam4SnvfjYbjqR5Os9bPK8cLarFAT2zfnVRIkUZHkoGBPnuemqxkOcZ+uODy
         LMqNJomcnrG8mTyJ5LG1xdc+WTAfaIliYA1eakM2CCpO1/yy4rP74lkJFkmjNFJBQCzV
         mDD77KiPxIz6bW8/WeTWXo+PHg/i0fvAcOqg7HSDkxhW963eneZxINqg7uqCV+GQPpS2
         s2Mo2ErQ1ShcUV1Mg59dGDPgozPyqZqurNkonaPeNTf4sjwmwtRl6vaGtk4wvVbZO2o8
         uk/w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=N1FHoD6ZMNB/7wrUWG2IW6DScPoWU0//Swe9DNcA3ZM=;
        b=I7RByQr7b0uia669/CJFZNFLIrkfpiAREeJ9jjcyJiChLsfCxa3TVIpuUWbywXlW43
         gHvei8inP4NmDWM/LZNWUheJXv9pRrbpnEYYEZEEVAeBu2mNDrUY9PbMBDFvkT3JFyP3
         HFjXKGGJmUKXtn1zn6Gg4LK6qoo3LNSkW4+hC8yxDqWbA1BYbC2DIxNpc/Yv39ZbtN0t
         WTdjzp47CsvVeLg+6QEzSyiW0OhY4v0c9RvE9mKY97v0gVD3c7l2pCz81Fl6RpsFRVRp
         4fk/UsMhzpu8JxvTV05+BlIDUNbspHTwBLgtHb/e4LEfTyLwQQ6xW0LqL5s8foprjcz0
         Gaqg==
X-Gm-Message-State: APjAAAUR3dyT1BYs3Rlxz7KBVwAWs2W8TQ6cxDM+uMeqrV6QFtLsHsrN
	hXmVATmLr5AjSgk2Tc8Mv04=
X-Google-Smtp-Source: APXvYqy1oXUYIem6XzmDVe884Ah62EAzXq+JkK2Hx/bJix7QTYC22HN51FBb8N05a72ad6sHl3Ne+g==
X-Received: by 2002:a17:90a:bb01:: with SMTP id u1mr1186109pjr.92.1565645631259;
        Mon, 12 Aug 2019 14:33:51 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id 185sm116118013pfa.170.2019.08.12.14.33.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Aug 2019 14:33:50 -0700 (PDT)
Subject: [PATCH v5 5/6] virtio-balloon: Pull page poisoning config out of
 free page hinting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, mst@redhat.com, david@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org,
 mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 virtio-dev@lists.oasis-open.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Mon, 12 Aug 2019 14:33:50 -0700
Message-ID: <20190812213350.22097.3322.stgit@localhost.localdomain>
In-Reply-To: <20190812213158.22097.30576.stgit@localhost.localdomain>
References: <20190812213158.22097.30576.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Currently the page poisoning setting wasn't being enabled unless free page
hinting was enabled. However we will need the page poisoning tracking logic
as well for unused page reporting. As such pull it out and make it a
separate bit of config in the probe function.

In addition we can actually wrap the code in a check for NO_SANITY. If we
don't care what is actually in the page we can just default to 0 and leave
it there.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 drivers/virtio/virtio_balloon.c |   19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 226fbb995fb0..2c19457ab573 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -842,7 +842,6 @@ static int virtio_balloon_register_shrinker(struct virtio_balloon *vb)
 static int virtballoon_probe(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb;
-	__u32 poison_val;
 	int err;
 
 	if (!vdev->config->get) {
@@ -909,11 +908,19 @@ static int virtballoon_probe(struct virtio_device *vdev)
 						  VIRTIO_BALLOON_CMD_ID_STOP);
 		spin_lock_init(&vb->free_page_list_lock);
 		INIT_LIST_HEAD(&vb->free_page_list);
-		if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_PAGE_POISON)) {
-			memset(&poison_val, PAGE_POISON, sizeof(poison_val));
-			virtio_cwrite(vb->vdev, struct virtio_balloon_config,
-				      poison_val, &poison_val);
-		}
+	}
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_PAGE_POISON)) {
+		__u32 poison_val = 0;
+
+#if !defined(CONFIG_PAGE_POISONING_NO_SANITY)
+		/*
+		 * Let hypervisor know that we are expecting a specific
+		 * value to be written back in unused pages.
+		 */
+		memset(&poison_val, PAGE_POISON, sizeof(poison_val));
+#endif
+		virtio_cwrite(vb->vdev, struct virtio_balloon_config,
+			      poison_val, &poison_val);
 	}
 	/*
 	 * We continue to use VIRTIO_BALLOON_F_DEFLATE_ON_OOM to decide if a


