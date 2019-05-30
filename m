Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BC37C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:57:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8B7326228
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:57:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="A8TPUAyM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8B7326228
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8125B6B0003; Thu, 30 May 2019 17:57:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C4646B000D; Thu, 30 May 2019 17:57:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D9FA6B027F; Thu, 30 May 2019 17:57:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 352666B0003
	for <linux-mm@kvack.org>; Thu, 30 May 2019 17:57:15 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d9so5578394pfo.13
        for <linux-mm@kvack.org>; Thu, 30 May 2019 14:57:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=hRtJSBK7hOO2HxW36GCGs67i+7Qs4gI8yBkC+IiPEzA=;
        b=XBjTIeiF2BKWHEcbduP/588VJfH4Nd6+nSNGO+HvEwV0ykRX8ldWsDiYV0WQv4aHyI
         HS7WSkDL/nJVAzxeyZ/Knb+yRTAb/3K181X+AM0ZM2XOGKCsao8XhbkcSyGo+F/gEh7/
         5qHXP9qUEe0ZrpzhQ9+FFrtRN7ZoZPynqQjRRvOIdvRRdz9XyjeLMfYHJcPwLDnKQkKF
         9ZPs3g7XoEJVFTYVFA6KbAu1CKZ88X3sinSt76QgER7qnunqS6a/olfd4BmLEEOAh1MQ
         +S0wk1l1eleeciJMHHO7yhpppNhPD3QtNq3y1U1j6NP5PUsiRVEeAQl8qM2lHw+t+gkP
         pnHQ==
X-Gm-Message-State: APjAAAUtGeWfr5W36vAJlpjETG3Vlq59BLu3O8jwSlaoThqUPuHD+NwN
	1n21T/VMMHQjwtbEVC5RMGYV5hlmyHlRqE4JB2JOMMlj+Jy/b8X1XqH3s4IwiIDPzlq5hvtlS1M
	zTAA5ZantEWsHkPaeMdncol/IYrWe/M5WmngkCXfsz1UF7Rsf8cdcQWIa2cMvbl9Z4w==
X-Received: by 2002:a17:902:2aa6:: with SMTP id j35mr5858609plb.189.1559253434752;
        Thu, 30 May 2019 14:57:14 -0700 (PDT)
X-Received: by 2002:a17:902:2aa6:: with SMTP id j35mr5858573plb.189.1559253433887;
        Thu, 30 May 2019 14:57:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559253433; cv=none;
        d=google.com; s=arc-20160816;
        b=wQpH5Uy013QUkmcUQ91eOwJP7rZF1+Yk+zOaX2yZwmdAG96rBqQS5SGeUe8YG9M0Xq
         fcCfBHpLseajRMdf5LFwame1lzRB/8z6k8roHNKdyl3DsrQY53cyqCHVoRdmiXOrL2B3
         YwEC55vVxSFLzRBuuAzfp+Hwhbw+s89sfSGZDlkPL3q3Tg5CMbcro5wlyaXPRw3SBHOn
         /UJEiRhhGrCjYs/S/Nmc+q03fzAzY6aFXzqi8xvzAfTVGf6z4Dhpxm/N/tD1ZXNBha4S
         IlfasfFteLOrQL7DjPG1ISwV998bp5gNnfhdw83e4RjniDITymvS7/1yIyQykKcNjZES
         z+4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=hRtJSBK7hOO2HxW36GCGs67i+7Qs4gI8yBkC+IiPEzA=;
        b=k4q+XZHvYs35va5Z58+bSirls0ItFRGYhKuN82n4Xo50fNJX4Juu4nROpGXnoQYFEn
         zwS5ifSqbEtfckslOqgMHHYYCp8KFyksaqCBqWmiFb8JDzSUDgHDIKFXecg499yj8k/4
         +j+yUDCap6D/BJy83H1YDN4bABUtffLjGbNehOfcYOe/Ae5eK9SptGXj62JxH1oriG5B
         kwWqczvnS36dmqQuV8BzllXcEYojTzqU/bMb610ozqFpq/AiW2+Q81V1/tOWa+HaG+xf
         mdBKbbHbNt/1P61hHHE8YdFfLQEV+iiM8rtw2yZGoiZTpK/VFWTYBQuOoRL97LaEf86A
         VEbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=A8TPUAyM;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f32sor4546844pjg.1.2019.05.30.14.57.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 14:57:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=A8TPUAyM;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=hRtJSBK7hOO2HxW36GCGs67i+7Qs4gI8yBkC+IiPEzA=;
        b=A8TPUAyM7D9PNJyF7BVZzPlObfCFCc59wtEx1tW0J7TG+wTsG/Y3ZacpA78D0FN+zX
         uSjKZOQTH/K3+L8Nh+DdKSRyZ9Nc9LCHvzlvvfOlDQeVx3ol4O9MsvLlO4qLH5u08Uqv
         AZxFBOseylxOrjR12xdoqjq3HbXX8xM1ARAL8TEjoLm7Df6rzarhdti1c2W/DZmu3cDt
         tbhmvtxuG4oyP0X1bKJXfHL4GpMF0gaA5/pZqITUJLyW8f4Rhl/00cMdv6aBLHi6xSdG
         mfUjuJkHoKnb+OB9+5azdHhLq7f+ukrIN2/IuOxPxXtQL8Gnxz0Y/pz1ePg+5IH2t/lZ
         Rq6Q==
X-Google-Smtp-Source: APXvYqza9LItj53rC/Lk/5f/6GzO1gMW2j4r3pHNQec+Fng2dDwtZIBZAZvJmQjRCmneOAd0OAZcww==
X-Received: by 2002:a17:90a:9289:: with SMTP id n9mr5486760pjo.35.1559253433357;
        Thu, 30 May 2019 14:57:13 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id a12sm3467604pgq.0.2019.05.30.14.57.12
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 14:57:12 -0700 (PDT)
Subject: [RFC QEMU PATCH] QEMU: Provide a interface for hinting based off of
 the balloon infrastructure
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Thu, 30 May 2019 14:57:12 -0700
Message-ID: <20190530215640.14712.87802.stgit@localhost.localdomain>
In-Reply-To: <20190530215223.13974.22445.stgit@localhost.localdomain>
References: <20190530215223.13974.22445.stgit@localhost.localdomain>
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

So this is meant to be a simplification of the existing balloon interface
to use for providing hints to what memory needs to be freed. I am assuming
this is safe to do as the deflate logic does not actually appear to do very
much other than tracking what subpages have been released and which ones
haven't.

I suspect this is still a bit crude and will need some more work.
Suggestions welcome.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 hw/virtio/trace-events                          |    1 
 hw/virtio/virtio-balloon.c                      |   85 +++++++++++++++++++++++
 include/hw/virtio/virtio-balloon.h              |    2 -
 include/standard-headers/linux/virtio_balloon.h |    1 
 4 files changed, 88 insertions(+), 1 deletion(-)

diff --git a/hw/virtio/trace-events b/hw/virtio/trace-events
index e28ba48da621..b56daf460769 100644
--- a/hw/virtio/trace-events
+++ b/hw/virtio/trace-events
@@ -46,6 +46,7 @@ virtio_balloon_handle_output(const char *name, uint64_t gpa) "section name: %s g
 virtio_balloon_get_config(uint32_t num_pages, uint32_t actual) "num_pages: %d actual: %d"
 virtio_balloon_set_config(uint32_t actual, uint32_t oldactual) "actual: %d oldactual: %d"
 virtio_balloon_to_target(uint64_t target, uint32_t num_pages) "balloon target: 0x%"PRIx64" num_pages: %d"
+virtio_bubble_handle_output(const char *name, uint64_t gpa, uint64_t size) "section name: %s gpa: 0x%" PRIx64 " size: %" PRIx64
 
 # virtio-mmio.c
 virtio_mmio_read(uint64_t offset) "virtio_mmio_read offset 0x%" PRIx64
diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
index 2112874055fb..eb819ec8f436 100644
--- a/hw/virtio/virtio-balloon.c
+++ b/hw/virtio/virtio-balloon.c
@@ -34,6 +34,13 @@
 
 #define BALLOON_PAGE_SIZE  (1 << VIRTIO_BALLOON_PFN_SHIFT)
 
+struct guest_pages {
+	unsigned long pfn;
+	unsigned int order;
+};
+
+void page_hinting_request(uint64_t addr, uint32_t len);
+
 struct PartiallyBalloonedPage {
     RAMBlock *rb;
     ram_addr_t base;
@@ -328,6 +335,80 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
     balloon_stats_change_timer(s, 0);
 }
 
+static void bubble_inflate_page(VirtIOBalloon *balloon,
+                                MemoryRegion *mr, hwaddr offset, size_t size)
+{
+    void *addr = memory_region_get_ram_ptr(mr) + offset;
+    ram_addr_t ram_offset;
+    size_t rb_page_size;
+    RAMBlock *rb;
+
+    rb = qemu_ram_block_from_host(addr, false, &ram_offset);
+    rb_page_size = qemu_ram_pagesize(rb);
+
+    /* For now we will simply ignore unaligned memory regions */
+    if ((ram_offset | size) & (rb_page_size - 1))
+        return;
+
+    ram_block_discard_range(rb, ram_offset, size);
+}
+
+static void virtio_bubble_handle_output(VirtIODevice *vdev, VirtQueue *vq)
+{
+    VirtIOBalloon *s = VIRTIO_BALLOON(vdev);
+    VirtQueueElement *elem;
+    MemoryRegionSection section;
+
+    for (;;) {
+        size_t offset = 0;
+	struct {
+            uint32_t pfn;
+            uint32_t size;
+	} hint;
+
+        elem = virtqueue_pop(vq, sizeof(VirtQueueElement));
+        if (!elem) {
+            return;
+        }
+
+        while (iov_to_buf(elem->out_sg, elem->out_num, offset, &hint, 8) == 8) {
+            size_t size = virtio_ldl_p(vdev, &hint.size);
+            hwaddr pa = virtio_ldl_p(vdev, &hint.pfn);
+
+            offset += 8;
+
+            if (qemu_balloon_is_inhibited())
+                continue;
+
+            pa <<= VIRTIO_BALLOON_PFN_SHIFT;
+            size <<= VIRTIO_BALLOON_PFN_SHIFT;
+
+            section = memory_region_find(get_system_memory(), pa, size);
+            if (!section.mr) {
+                trace_virtio_balloon_bad_addr(pa);
+                continue;
+            }
+
+            if (!memory_region_is_ram(section.mr) ||
+                memory_region_is_rom(section.mr) ||
+                memory_region_is_romd(section.mr)) {
+                trace_virtio_balloon_bad_addr(pa);
+            } else {
+                trace_virtio_bubble_handle_output(memory_region_name(section.mr),
+                                                  pa, size);
+                bubble_inflate_page(s, section.mr,
+                                    section.offset_within_region, size);
+            }
+
+            memory_region_unref(section.mr);
+        }
+
+        virtqueue_push(vq, elem, offset);
+        virtio_notify(vdev, vq);
+        g_free(elem);
+    }
+}
+
 static void virtio_balloon_handle_output(VirtIODevice *vdev, VirtQueue *vq)
 {
     VirtIOBalloon *s = VIRTIO_BALLOON(vdev);
@@ -694,6 +775,7 @@ static uint64_t virtio_balloon_get_features(VirtIODevice *vdev, uint64_t f,
     VirtIOBalloon *dev = VIRTIO_BALLOON(vdev);
     f |= dev->host_features;
     virtio_add_feature(&f, VIRTIO_BALLOON_F_STATS_VQ);
+    virtio_add_feature(&f, VIRTIO_BALLOON_F_HINTING);
 
     return f;
 }
@@ -780,6 +862,7 @@ static void virtio_balloon_device_realize(DeviceState *dev, Error **errp)
     s->ivq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
     s->dvq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
     s->svq = virtio_add_queue(vdev, 128, virtio_balloon_receive_stats);
+    s->hvq = virtio_add_queue(vdev, 128, virtio_bubble_handle_output);
 
     if (virtio_has_feature(s->host_features,
                            VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
@@ -875,6 +958,8 @@ static void virtio_balloon_instance_init(Object *obj)
 
     object_property_add(obj, "guest-stats", "guest statistics",
                         balloon_stats_get_all, NULL, NULL, s, NULL);
+    object_property_add(obj, "guest-page-hinting", "guest page hinting",
+                        NULL, NULL, NULL, s, NULL);
 
     object_property_add(obj, "guest-stats-polling-interval", "int",
                         balloon_stats_get_poll_interval,
diff --git a/include/hw/virtio/virtio-balloon.h b/include/hw/virtio/virtio-balloon.h
index 1afafb12f6bc..dd6d4d0e45fd 100644
--- a/include/hw/virtio/virtio-balloon.h
+++ b/include/hw/virtio/virtio-balloon.h
@@ -44,7 +44,7 @@ enum virtio_balloon_free_page_report_status {
 
 typedef struct VirtIOBalloon {
     VirtIODevice parent_obj;
-    VirtQueue *ivq, *dvq, *svq, *free_page_vq;
+    VirtQueue *ivq, *dvq, *svq, *hvq, *free_page_vq;
     uint32_t free_page_report_status;
     uint32_t num_pages;
     uint32_t actual;
diff --git a/include/standard-headers/linux/virtio_balloon.h b/include/standard-headers/linux/virtio_balloon.h
index 9375ca2a70de..f9e3e8256261 100644
--- a/include/standard-headers/linux/virtio_balloon.h
+++ b/include/standard-headers/linux/virtio_balloon.h
@@ -36,6 +36,7 @@
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
 #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
+#define VIRTIO_BALLOON_F_HINTING	5 /* Page hinting virtqueue */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12

