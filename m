Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F17AC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 05:55:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE3B72175B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 05:55:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE3B72175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 875166B0269; Tue, 23 Apr 2019 01:55:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 823DD6B026A; Tue, 23 Apr 2019 01:55:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 715466B026B; Tue, 23 Apr 2019 01:55:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC3D6B0269
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 01:55:08 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id j20so5393366qta.23
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 22:55:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=xGOYeCUAlm5LyudhK8G/pGQDHHGofUwYKXBsaq5c9JI=;
        b=X+4TtOyK2AT1jveZK4qHylWJeDA/WwoGAG3GtBQqQ6u+LVeBqvp/usBgfNfznyRY2I
         Imu2eSpZczgb4fwFS77LgaQWsKbTnkbi5T2zS6pgUPsOEk/2KfD1cctqp+ObuqtDWKBc
         u78qQlJuOV/a5+KU3dgjOeZSjlCHIQz0Zz8YxyoZjWEoXLuVcIdNDOw+Yy+K/WsU58fJ
         rTo2V70Ij3KJj7bwRAfL4jgUxTlhazLYEtFL3YqmFYnL6VUzFa2p5pFldeaQ+ky3RNIc
         rMf+dQfMY+fR3BgPqp+iTAM+hIY9tiYwm0C77vT52YZluLawCk2psAsyjow5MgVOXFsR
         aTEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUL1ZyD1dc0auj3gAponWA3ocOqJ4SodeeTMAkxnd1YcqMrJY0T
	+9BmIn9nociETFmRuqwTliCshGkuaRyVe7IvCTiApJrNIwRXTFhiJqhU7wjFFHFJksbya+6NkYy
	BAvx53snnw7kvFgnzCrE0Q+uMwWtxSXCmiJvP2c1tLl9SGFkdDv7PyU0aox1FISCslA==
X-Received: by 2002:ac8:37b0:: with SMTP id d45mr8209451qtc.368.1555998908040;
        Mon, 22 Apr 2019 22:55:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzYOjkQhWPDMq4pm3Ks34lviE5JV6O488CPkueyhbftf9GIg0orsdAlXSshesGyMtkdFjR
X-Received: by 2002:ac8:37b0:: with SMTP id d45mr8209403qtc.368.1555998906756;
        Mon, 22 Apr 2019 22:55:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555998906; cv=none;
        d=google.com; s=arc-20160816;
        b=iBTjYz86fUvabXd9y/4bFuq98b18Akh4fya+ppq4MJnhXhuis7ke4rmCdFwUMMAVBR
         0oEIwuPNu7bxvEztqygGkVDz1ISAv8fz65MsDywspZ+4JXKE3stmeI14MCcDxxFMD3qI
         tx7H7RqJif5w7H/52Qs5bC0mw25Eie7dhoByLqHAhvlZ7HQjYj8O84C7OvvP/AwdZcBU
         8e61JoD7Cqy5y8uRa4Kdyj1yBUWA4QaHfVBK4Uaki/CemIIAaBSO7WBk6pOjGKz3s1vL
         vMkM1aCbrX/AHS4hHFmP2REpeAPU7HVpqxGmUSCAedpHvpEYLZnAP9Bj9YUcmrsxMPH2
         UsHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=xGOYeCUAlm5LyudhK8G/pGQDHHGofUwYKXBsaq5c9JI=;
        b=erf2+RRRMiYFztVgZpW6WXO6GYRubBbzlDzrzJS4iIIkJAFXqEJTl6XONXxeaUz8Ya
         kMjYyid2XCPgOY028lZ+oB4c5HLl3RRuKs2xUa1SbaBcHwvOHjGjKQAbQzvmRTBZlq16
         tBkir/OYWgj59tgH5/2JdV5iToSoqvDOislhxQ+oGXDBuBSsmrj890/SKiaoHyTclueb
         6RdpbNX6gJ80eil4m/4oPrI+WaDrEs0tjM039umUeqkONq4BA8+DtoewNT/QLDKMHBAd
         /DqW3qbNo2ArBamF3FkawPxAfw58XH9th/Jz/CoVobgbF/PWV82MWuIgbXChTgBou2s1
         2FLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f66si10244179qtb.0.2019.04.22.22.55.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 22:55:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BFAE030917AD;
	Tue, 23 Apr 2019 05:55:05 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 25C64261D3;
	Tue, 23 Apr 2019 05:54:58 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: peterx@redhat.com,
	aarcange@redhat.com,
	James.Bottomley@hansenpartnership.com,
	hch@infradead.org,
	davem@davemloft.net,
	jglisse@redhat.com,
	linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux-parisc@vger.kernel.org,
	christophe.de.dinechin@gmail.com,
	jrdr.linux@gmail.com
Subject: [RFC PATCH V3 5/6] vhost: factor out setting vring addr and num
Date: Tue, 23 Apr 2019 01:54:19 -0400
Message-Id: <20190423055420.26408-6-jasowang@redhat.com>
In-Reply-To: <20190423055420.26408-1-jasowang@redhat.com>
References: <20190423055420.26408-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Tue, 23 Apr 2019 05:55:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Factoring vring address and num setting which needs special care for
accelerating vq metadata accessing.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 177 ++++++++++++++++++++++++------------------
 1 file changed, 103 insertions(+), 74 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index f3f86c3ed659..c2362ed5839e 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1468,6 +1468,104 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
 	return -EFAULT;
 }
 
+static long vhost_vring_set_num(struct vhost_dev *d,
+				struct vhost_virtqueue *vq,
+				void __user *argp)
+{
+	struct vhost_vring_state s;
+
+	/* Resizing ring with an active backend?
+	 * You don't want to do that. */
+	if (vq->private_data)
+		return -EBUSY;
+
+	if (copy_from_user(&s, argp, sizeof s))
+		return -EFAULT;
+
+	if (!s.num || s.num > 0xffff || (s.num & (s.num - 1)))
+		return -EINVAL;
+	vq->num = s.num;
+
+	return 0;
+}
+
+static long vhost_vring_set_addr(struct vhost_dev *d,
+				 struct vhost_virtqueue *vq,
+				 void __user *argp)
+{
+	struct vhost_vring_addr a;
+
+	if (copy_from_user(&a, argp, sizeof a))
+		return -EFAULT;
+	if (a.flags & ~(0x1 << VHOST_VRING_F_LOG))
+		return -EOPNOTSUPP;
+
+	/* For 32bit, verify that the top 32bits of the user
+	   data are set to zero. */
+	if ((u64)(unsigned long)a.desc_user_addr != a.desc_user_addr ||
+	    (u64)(unsigned long)a.used_user_addr != a.used_user_addr ||
+	    (u64)(unsigned long)a.avail_user_addr != a.avail_user_addr)
+		return -EFAULT;
+
+	/* Make sure it's safe to cast pointers to vring types. */
+	BUILD_BUG_ON(__alignof__ *vq->avail > VRING_AVAIL_ALIGN_SIZE);
+	BUILD_BUG_ON(__alignof__ *vq->used > VRING_USED_ALIGN_SIZE);
+	if ((a.avail_user_addr & (VRING_AVAIL_ALIGN_SIZE - 1)) ||
+	    (a.used_user_addr & (VRING_USED_ALIGN_SIZE - 1)) ||
+	    (a.log_guest_addr & (VRING_USED_ALIGN_SIZE - 1)))
+		return -EINVAL;
+
+	/* We only verify access here if backend is configured.
+	 * If it is not, we don't as size might not have been setup.
+	 * We will verify when backend is configured. */
+	if (vq->private_data) {
+		if (!vq_access_ok(vq, vq->num,
+			(void __user *)(unsigned long)a.desc_user_addr,
+			(void __user *)(unsigned long)a.avail_user_addr,
+			(void __user *)(unsigned long)a.used_user_addr))
+			return -EINVAL;
+
+		/* Also validate log access for used ring if enabled. */
+		if ((a.flags & (0x1 << VHOST_VRING_F_LOG)) &&
+			!log_access_ok(vq->log_base, a.log_guest_addr,
+				sizeof *vq->used +
+				vq->num * sizeof *vq->used->ring))
+			return -EINVAL;
+	}
+
+	vq->log_used = !!(a.flags & (0x1 << VHOST_VRING_F_LOG));
+	vq->desc = (void __user *)(unsigned long)a.desc_user_addr;
+	vq->avail = (void __user *)(unsigned long)a.avail_user_addr;
+	vq->log_addr = a.log_guest_addr;
+	vq->used = (void __user *)(unsigned long)a.used_user_addr;
+
+	return 0;
+}
+
+static long vhost_vring_set_num_addr(struct vhost_dev *d,
+				     struct vhost_virtqueue *vq,
+				     unsigned int ioctl,
+				     void __user *argp)
+{
+	long r;
+
+	mutex_lock(&vq->mutex);
+
+	switch (ioctl) {
+	case VHOST_SET_VRING_NUM:
+		r = vhost_vring_set_num(d, vq, argp);
+		break;
+	case VHOST_SET_VRING_ADDR:
+		r = vhost_vring_set_addr(d, vq, argp);
+		break;
+	default:
+		BUG();
+	}
+
+	mutex_unlock(&vq->mutex);
+
+	return r;
+}
 long vhost_vring_ioctl(struct vhost_dev *d, unsigned int ioctl, void __user *argp)
 {
 	struct file *eventfp, *filep = NULL;
@@ -1477,7 +1575,6 @@ long vhost_vring_ioctl(struct vhost_dev *d, unsigned int ioctl, void __user *arg
 	struct vhost_virtqueue *vq;
 	struct vhost_vring_state s;
 	struct vhost_vring_file f;
-	struct vhost_vring_addr a;
 	u32 idx;
 	long r;
 
@@ -1490,26 +1587,14 @@ long vhost_vring_ioctl(struct vhost_dev *d, unsigned int ioctl, void __user *arg
 	idx = array_index_nospec(idx, d->nvqs);
 	vq = d->vqs[idx];
 
+	if (ioctl == VHOST_SET_VRING_NUM ||
+	    ioctl == VHOST_SET_VRING_ADDR) {
+		return vhost_vring_set_num_addr(d, vq, ioctl, argp);
+	}
+
 	mutex_lock(&vq->mutex);
 
 	switch (ioctl) {
-	case VHOST_SET_VRING_NUM:
-		/* Resizing ring with an active backend?
-		 * You don't want to do that. */
-		if (vq->private_data) {
-			r = -EBUSY;
-			break;
-		}
-		if (copy_from_user(&s, argp, sizeof s)) {
-			r = -EFAULT;
-			break;
-		}
-		if (!s.num || s.num > 0xffff || (s.num & (s.num - 1))) {
-			r = -EINVAL;
-			break;
-		}
-		vq->num = s.num;
-		break;
 	case VHOST_SET_VRING_BASE:
 		/* Moving base with an active backend?
 		 * You don't want to do that. */
@@ -1535,62 +1620,6 @@ long vhost_vring_ioctl(struct vhost_dev *d, unsigned int ioctl, void __user *arg
 		if (copy_to_user(argp, &s, sizeof s))
 			r = -EFAULT;
 		break;
-	case VHOST_SET_VRING_ADDR:
-		if (copy_from_user(&a, argp, sizeof a)) {
-			r = -EFAULT;
-			break;
-		}
-		if (a.flags & ~(0x1 << VHOST_VRING_F_LOG)) {
-			r = -EOPNOTSUPP;
-			break;
-		}
-		/* For 32bit, verify that the top 32bits of the user
-		   data are set to zero. */
-		if ((u64)(unsigned long)a.desc_user_addr != a.desc_user_addr ||
-		    (u64)(unsigned long)a.used_user_addr != a.used_user_addr ||
-		    (u64)(unsigned long)a.avail_user_addr != a.avail_user_addr) {
-			r = -EFAULT;
-			break;
-		}
-
-		/* Make sure it's safe to cast pointers to vring types. */
-		BUILD_BUG_ON(__alignof__ *vq->avail > VRING_AVAIL_ALIGN_SIZE);
-		BUILD_BUG_ON(__alignof__ *vq->used > VRING_USED_ALIGN_SIZE);
-		if ((a.avail_user_addr & (VRING_AVAIL_ALIGN_SIZE - 1)) ||
-		    (a.used_user_addr & (VRING_USED_ALIGN_SIZE - 1)) ||
-		    (a.log_guest_addr & (VRING_USED_ALIGN_SIZE - 1))) {
-			r = -EINVAL;
-			break;
-		}
-
-		/* We only verify access here if backend is configured.
-		 * If it is not, we don't as size might not have been setup.
-		 * We will verify when backend is configured. */
-		if (vq->private_data) {
-			if (!vq_access_ok(vq, vq->num,
-				(void __user *)(unsigned long)a.desc_user_addr,
-				(void __user *)(unsigned long)a.avail_user_addr,
-				(void __user *)(unsigned long)a.used_user_addr)) {
-				r = -EINVAL;
-				break;
-			}
-
-			/* Also validate log access for used ring if enabled. */
-			if ((a.flags & (0x1 << VHOST_VRING_F_LOG)) &&
-			    !log_access_ok(vq->log_base, a.log_guest_addr,
-					   sizeof *vq->used +
-					   vq->num * sizeof *vq->used->ring)) {
-				r = -EINVAL;
-				break;
-			}
-		}
-
-		vq->log_used = !!(a.flags & (0x1 << VHOST_VRING_F_LOG));
-		vq->desc = (void __user *)(unsigned long)a.desc_user_addr;
-		vq->avail = (void __user *)(unsigned long)a.avail_user_addr;
-		vq->log_addr = a.log_guest_addr;
-		vq->used = (void __user *)(unsigned long)a.used_user_addr;
-		break;
 	case VHOST_SET_VRING_KICK:
 		if (copy_from_user(&f, argp, sizeof f)) {
 			r = -EFAULT;
-- 
2.18.1

