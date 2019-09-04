Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 481D0C3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 15:12:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 032E02077B
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 15:12:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Icdioip/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 032E02077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A80DE6B000D; Wed,  4 Sep 2019 11:11:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A30286B000E; Wed,  4 Sep 2019 11:11:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 946136B026A; Wed,  4 Sep 2019 11:11:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0154.hostedemail.com [216.40.44.154])
	by kanga.kvack.org (Postfix) with ESMTP id 710176B000D
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 11:11:59 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 0DE73181AC9BF
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 15:11:59 +0000 (UTC)
X-FDA: 75897578358.04.crow96_85a671cf1ac00
X-HE-Tag: crow96_85a671cf1ac00
X-Filterd-Recvd-Size: 8670
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 15:11:58 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id s12so6441787pfe.6
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 08:11:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=R9EIePxtKgh7rutMNGBvqWvR/nyIQIv1yBQVlI6lc80=;
        b=Icdioip/LrE7zC1LjFhruymYKz5CChvFweZFNaQHSt0elL4kf0rEcwoiDnrDAo4wsd
         lculUOTKABzUpllh/6JcZEK1C9+szQUevDm2233hJRsBXFMqL+lPRscj3lXDE/HHlbPc
         IBQXiIFzd2gHcYCAeLDhNUCB6KcdFk+xudcysNTpWBn1q0+V0ZbnDtTTKUv4dZtnXFTF
         SDeiUW0XA4dD6JYzcDZrrCDgkttwlOmQb5RhC2E0bY2x7KP9gIYZHnqGku9VfUVUpUzw
         weh3WeDoEkbWkXv/rneDrEogXrWTovdbhvtRNFXL0460yxwc4bSW4ENUncFhf71IfM/p
         s5zg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=R9EIePxtKgh7rutMNGBvqWvR/nyIQIv1yBQVlI6lc80=;
        b=bXKkEa5tdweJ2ZjulqjHZBzgHyYMAa/+ftOjFTNGBQCA2vJrtt063z5AVGbh+hFPmg
         Bm87cPF/hNWyo7ZB/4Lzn5FYcL2RW9HA0ULQNFAntsMEY2FKBRFsYtJB9puUHW+nj7uH
         AAwIzyBZsNJzgV3HeXO9RWlIazh7KNbycJMxOiuZYC1JIs3s+gh0HuQ8c8Vuw41DyLEE
         4e4YfqVJBuRtJX9qmQtc2ixbaFcG5xnFVbKELZowHJCiVxtXGDmLBhpy/4o7g/ex0d56
         UXFV5IBIwTk/S4+yJzJFlyrSqM9AMA98RVtevulsvF+zBSB7sspoSArG3GTin6h3x8Wd
         9B+g==
X-Gm-Message-State: APjAAAVd8XlYplpEYnq0gzp5kTfCkQKNGRddFY/II1iF9OzD5bVy8i6U
	lkXcJwdiBi6qaaXHOdZTKfI=
X-Google-Smtp-Source: APXvYqz8hxh9LJuvHBkIwHPd7Zgipkz7Ryft0mOHwrXV6Llo7seFR+xT4mPT1M5fYnrbzjbkIZxxvQ==
X-Received: by 2002:a65:4505:: with SMTP id n5mr21223408pgq.301.1567609917279;
        Wed, 04 Sep 2019 08:11:57 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id q186sm11375401pfb.47.2019.09.04.08.11.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Sep 2019 08:11:56 -0700 (PDT)
Subject: [PATCH v7 QEMU 3/3] virtio-balloon: Provide a interface for unused
 page reporting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, mst@redhat.com, david@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, virtio-dev@lists.oasis-open.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, mhocko@kernel.org, alexander.h.duyck@linux.intel.com,
 osalvador@suse.de
Date: Wed, 04 Sep 2019 08:11:56 -0700
Message-ID: <20190904151156.14270.25192.stgit@localhost.localdomain>
In-Reply-To: <20190904150920.13848.32271.stgit@localhost.localdomain>
References: <20190904150920.13848.32271.stgit@localhost.localdomain>
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

Add support for what I am referring to as "unused page reporting".
Basically the idea is to function very similar to how the balloon works
in that we basically end up madvising the page as not being used. However
we don't really need to bother with any deflate type logic since the page
will be faulted back into the guest when it is read or written to.

This is meant to be a simplification of the existing balloon interface
to use for providing hints to what memory needs to be freed. I am assuming
this is safe to do as the deflate logic does not actually appear to do very
much other than tracking what subpages have been released and which ones
haven't.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 hw/virtio/virtio-balloon.c         |   46 ++++++++++++++++++++++++++++++++++--
 include/hw/virtio/virtio-balloon.h |    2 +-
 2 files changed, 45 insertions(+), 3 deletions(-)

diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
index 003b3ebcfdfb..7a30df63bc77 100644
--- a/hw/virtio/virtio-balloon.c
+++ b/hw/virtio/virtio-balloon.c
@@ -320,6 +320,40 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
     balloon_stats_change_timer(s, 0);
 }
 
+static void virtio_balloon_handle_report(VirtIODevice *vdev, VirtQueue *vq)
+{
+    VirtIOBalloon *dev = VIRTIO_BALLOON(vdev);
+    VirtQueueElement *elem;
+
+    while ((elem = virtqueue_pop(vq, sizeof(VirtQueueElement)))) {
+    	unsigned int i;
+
+        for (i = 0; i < elem->in_num; i++) {
+            void *addr = elem->in_sg[i].iov_base;
+            size_t size = elem->in_sg[i].iov_len;
+            ram_addr_t ram_offset;
+            size_t rb_page_size;
+            RAMBlock *rb;
+
+            if (qemu_balloon_is_inhibited() || dev->poison_val)
+                continue;
+
+            rb = qemu_ram_block_from_host(addr, false, &ram_offset);
+            rb_page_size = qemu_ram_pagesize(rb);
+
+            /* For now we will simply ignore unaligned memory regions */
+            if ((ram_offset | size) & (rb_page_size - 1))
+                continue;
+
+            ram_block_discard_range(rb, ram_offset, size);
+        }
+
+        virtqueue_push(vq, elem, 0);
+        virtio_notify(vdev, vq);
+        g_free(elem);
+    }
+}
+
 static void virtio_balloon_handle_output(VirtIODevice *vdev, VirtQueue *vq)
 {
     VirtIOBalloon *s = VIRTIO_BALLOON(vdev);
@@ -627,7 +661,8 @@ static size_t virtio_balloon_config_size(VirtIOBalloon *s)
         return sizeof(struct virtio_balloon_config);
     }
     if (virtio_has_feature(features, VIRTIO_BALLOON_F_PAGE_POISON) ||
-        virtio_has_feature(features, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
+        virtio_has_feature(features, VIRTIO_BALLOON_F_FREE_PAGE_HINT) ||
+        virtio_has_feature(features, VIRTIO_BALLOON_F_REPORTING)) {
         return sizeof(struct virtio_balloon_config);
     }
     return offsetof(struct virtio_balloon_config, free_page_report_cmd_id);
@@ -715,7 +750,8 @@ static uint64_t virtio_balloon_get_features(VirtIODevice *vdev, uint64_t f,
     VirtIOBalloon *dev = VIRTIO_BALLOON(vdev);
     f |= dev->host_features;
     virtio_add_feature(&f, VIRTIO_BALLOON_F_STATS_VQ);
-    if (virtio_has_feature(f, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
+    if (virtio_has_feature(f, VIRTIO_BALLOON_F_FREE_PAGE_HINT) ||
+        virtio_has_feature(f, VIRTIO_BALLOON_F_REPORTING)) {
         virtio_add_feature(&f, VIRTIO_BALLOON_F_PAGE_POISON);
     }
 
@@ -805,6 +841,10 @@ static void virtio_balloon_device_realize(DeviceState *dev, Error **errp)
     s->dvq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
     s->svq = virtio_add_queue(vdev, 128, virtio_balloon_receive_stats);
 
+    if (virtio_has_feature(s->host_features, VIRTIO_BALLOON_F_REPORTING)) {
+        s->rvq = virtio_add_queue(vdev, 32, virtio_balloon_handle_report);
+    }
+
     if (virtio_has_feature(s->host_features,
                            VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
         s->free_page_vq = virtio_add_queue(vdev, VIRTQUEUE_MAX_SIZE,
@@ -931,6 +971,8 @@ static Property virtio_balloon_properties[] = {
      */
     DEFINE_PROP_BOOL("qemu-4-0-config-size", VirtIOBalloon,
                      qemu_4_0_config_size, false),
+    DEFINE_PROP_BIT("unused-page-reporting", VirtIOBalloon, host_features,
+                    VIRTIO_BALLOON_F_REPORTING, true),
     DEFINE_PROP_LINK("iothread", VirtIOBalloon, iothread, TYPE_IOTHREAD,
                      IOThread *),
     DEFINE_PROP_END_OF_LIST(),
diff --git a/include/hw/virtio/virtio-balloon.h b/include/hw/virtio/virtio-balloon.h
index 7fe78e5c14d7..db5bf7127112 100644
--- a/include/hw/virtio/virtio-balloon.h
+++ b/include/hw/virtio/virtio-balloon.h
@@ -42,7 +42,7 @@ enum virtio_balloon_free_page_report_status {
 
 typedef struct VirtIOBalloon {
     VirtIODevice parent_obj;
-    VirtQueue *ivq, *dvq, *svq, *free_page_vq;
+    VirtQueue *ivq, *dvq, *svq, *free_page_vq, *rvq;
     uint32_t free_page_report_status;
     uint32_t num_pages;
     uint32_t actual;


