Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C60DBC10F00
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 00:35:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7561A206DD
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 00:35:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="I0s1x8+f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7561A206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A5688E0003; Wed,  6 Mar 2019 19:35:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0034E8E0002; Wed,  6 Mar 2019 19:35:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D98AE8E0003; Wed,  6 Mar 2019 19:35:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9388E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 19:35:18 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id p65so7310595oib.15
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 16:35:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=YGf5z/1I8Cu2i8LbrxNhN+soNX9B52Mijub6rlc4WZU=;
        b=meYhjniH5XDx9RqeDZ9s6g/36r3zJuU79i64ROLx99R05KAOTEcKP9/FeOwJgS5zlZ
         WjRRnjAboNjMyVRRfK7viz1WoiCzPdM0F+xFHnzBfFVSa+c1eAN8zdKFMWktk1CSEn9r
         zvGSj1pOGSUq3xFv2HJTqB1jrnx8ka100sGGU6DZ1e4GDDEGU5mUiUWpk6obeIPExGCa
         8KVWLlfqcsPkY1Sap5MKLfI/3jFUFJsC2WBnaDyiB29Cu39Tl0Y/q5c9mncwXvUJJuNa
         phEiiITUuHpOcsJnpf84hapBFFroBbpFIis9UeISL78FCRBDpkAcHu0rwyDeXJUaVrKI
         Utfg==
X-Gm-Message-State: APjAAAXY/lyigFosbTniIqlBW3+CsKROLiybQJ5zV1bJKDepEy28c5xG
	elwn1AhZzqHwon3TMvwNcSK8ZMLiXm7UTcr4pdTNqsGRQHUCMu9iiHtmWcHu3njoCDV7cAuKIEi
	yniSzlzH2rQCZSJV7ZS9cX//HO/jLZgsdbwLxcD8SrkWi9Yu7KfFlc/ERpnY8w+lY4QqXhc7sW6
	xMj1uGtmxDApix4inNNFqiR/z5/9SryHNwfLfEGw6lNn5xCneYmi66oHEUGH9EL+Ctqb8TTFO/i
	ZwsU+eilzAbTOLvnhBQaysk8Uqww8NlzWGDSiY00b796cD4sIRSxPSGEWks9oi5ek6LO8EH00Hj
	8E+98Q/UVkgpuNXGgmLi5DF3ARFUFXZn7DJNwKCIIuaP6JVgnKMhDOR9hWtTqFukuEnzf6o4s1J
	e
X-Received: by 2002:a9d:6c48:: with SMTP id g8mr6022759otq.268.1551918918091;
        Wed, 06 Mar 2019 16:35:18 -0800 (PST)
X-Received: by 2002:a9d:6c48:: with SMTP id g8mr6022707otq.268.1551918916689;
        Wed, 06 Mar 2019 16:35:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551918916; cv=none;
        d=google.com; s=arc-20160816;
        b=SYykUL1TrP30Ua9lIZ0y7BcdMbLfzNkVVw54h4v0iPSYa6LSndYnVhv1qF+0Qgdfv3
         xKQddkSOoahYv3SOM5R2OC1YqHUCq8ANx09JYMMh9e5YgBOhQHQp7g/fVwMT3HCQVL94
         iFy8MWJzF/4p6g8SJKsXc0JWr5a5c0nffwD2nYbnMB5Jf72Bhi48CEvuH341MoK/WRpj
         k0c527Epa8aJGN+OcYEW5XbBCkaJnxFv5pMcOgCn6590iUW1yZyV6JbVz/2BK0gBsNkk
         MdIuFIFxJ6tfRdqwvHi5uPh3tV/sDz2tuWucSGwTGx6b29npfMolE2ToN6L7JL2l2xdo
         3XmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=YGf5z/1I8Cu2i8LbrxNhN+soNX9B52Mijub6rlc4WZU=;
        b=jfo+gilpZWZtJoGUDsEznT+7foMQKy6KS27kKBwCL2ljm2qwtQfagbUnBcAjfX4Yvd
         weMjdSxP4zVfI3j9MTOeXmV5cHrUMk9wsQWrIoKlUu1FwMoWvIooEFVbw9w4mEuSwlWH
         c4mEBO08+O1VloCpBjFC+hv8aWtk0KqEyUTbFBwaNkWhjmZ+mzxVHDLxERVSYmeGkYnB
         q8PvzbIXZspRhhiY940yRIfNneokipWPrT3pyAaoc9zWtfbIZO22ozGjqUS/lBOMD1d6
         MjvrsZrB/8J7ZelI7pItC9hPScH4NYwwG2ZorUBz6mcYXCn3rGyu0qT9PmaiIDm+kKCe
         l7CA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=I0s1x8+f;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k7sor1693141otj.158.2019.03.06.16.35.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 16:35:16 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=I0s1x8+f;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=YGf5z/1I8Cu2i8LbrxNhN+soNX9B52Mijub6rlc4WZU=;
        b=I0s1x8+fBh9mmhBiUpJfTfq43dSaCCTQNPHBIPvz4UGKBiB1dMI4p+gtQskK8g6UWt
         NvmhiVZVlFOgURFvkGNS5dkA/jbY/aASwhilTiD6oMspkajZL7bH8XtMv4GLUw3xu8Z+
         7I2eXkyb8rZfbc2XXVQyXAOjLyRNQf0FC5mS0Ng1MOsobToLEL8Oa4PBD+KVV4poZdUg
         MW0CrsN+5tVEIIdjLGJvF+eWihDK18nLSJUQrmg07zhvKSRS+lZnXdnwj0qoHBYZEq3G
         LEZic+GWvonEyM3kRws9QqGCpW/mOyaDJJy9o4OGwTOrJV+dUyxigAJLuvcf7LpQ6pFg
         dldg==
X-Google-Smtp-Source: APXvYqxa+KLNBt+1ZOSJVAWjFOCQyK+jvCyFdDoS+Brw+FLkOhiejAsTBNA41dPAcvSqIg7fqZ0E5w==
X-Received: by 2002:a9d:77c7:: with SMTP id w7mr6530870otl.207.1551918916044;
        Wed, 06 Mar 2019 16:35:16 -0800 (PST)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id g80sm1192115otg.38.2019.03.06.16.35.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 16:35:15 -0800 (PST)
Subject: Re: [RFC][QEMU Patch] KVM: Enable QEMU to free the pages hinted by
 the guest
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, kvm@vger.kernel.org,
 riel@surriel.com, david@redhat.com, linux-kernel@vger.kernel.org,
 lcapitulino@redhat.com, linux-mm@kvack.org, wei.w.wang@intel.com,
 aarcange@redhat.com, mst@redhat.com, dhildenb@redhat.com, pbonzini@redhat.com,
 dodgen@google.com, konrad.wilk@oracle.com
Date: Wed, 06 Mar 2019 16:35:13 -0800
Message-ID: <20190307003207.25058.4638.stgit@localhost.localdomain>
In-Reply-To: <CAKgT0Ue=kGB4D2oV1WUmWHiYhrXa64KWBP2ZhLgHNgvWyOng5A@mail.gmail.com>
References: <CAKgT0Ue=kGB4D2oV1WUmWHiYhrXa64KWBP2ZhLgHNgvWyOng5A@mail.gmail.com>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Here are some changes I made to your patch in order to address the sizing
issue I called out. You may want to try testing with this patch applied to
your QEMU as I am finding it is making a signficant difference. It has cut
the test time for the 32G memhog test I called out earlier in half.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 hw/virtio/virtio-balloon.c |   28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
index d2cf66ada3c0..3ca6b1c6d511 100644
--- a/hw/virtio/virtio-balloon.c
+++ b/hw/virtio/virtio-balloon.c
@@ -285,7 +285,7 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
     balloon_stats_change_timer(s, 0);
 }
 
-static void *gpa2hva(MemoryRegion **p_mr, hwaddr addr, Error **errp)
+static void *gpa2hva(MemoryRegion **p_mr, unsigned long *size, hwaddr addr, Error **errp)
 {
     MemoryRegionSection mrs = memory_region_find(get_system_memory(),
                                                  addr, 1);
@@ -302,6 +302,7 @@ static void *gpa2hva(MemoryRegion **p_mr, hwaddr addr, Error **errp)
     }
 
     *p_mr = mrs.mr;
+    *size = mrs.mr->size - mrs.offset_within_region;
     return qemu_map_ram_ptr(mrs.mr->ram_block, mrs.offset_within_region);
 }
 
@@ -313,30 +314,35 @@ void page_hinting_request(uint64_t addr, uint32_t len)
     struct guest_pages *guest_obj;
     int i = 0;
     void *hvaddr_to_free;
-    unsigned long pfn, pfn_end;
     uint64_t gpaddr_to_free;
-    void * temp_addr = gpa2hva(&mr, addr, &local_err);
+    unsigned long madv_size, size;
+    void * temp_addr = gpa2hva(&mr, &madv_size, addr, &local_err);
 
     if (local_err) {
         error_report_err(local_err);
         return;
     }
+    if (madv_size < sizeof(*guest_obj)) {
+	printf("\nBad guest object ptr\n");
+	return;
+    }
     guest_obj = temp_addr;
     while (i < len) {
-        pfn = guest_obj[i].pfn;
-	pfn_end = guest_obj[i].pfn + (1 << guest_obj[i].order) - 1;
-	trace_virtio_balloon_hinting_request(pfn,(1 << guest_obj[i].order));
-	while (pfn <= pfn_end) {
-	        gpaddr_to_free = pfn << VIRTIO_BALLOON_PFN_SHIFT;
-	        hvaddr_to_free = gpa2hva(&mr, gpaddr_to_free, &local_err);
+        gpaddr_to_free = guest_obj[i].pfn << VIRTIO_BALLOON_PFN_SHIFT;
+	size = (1 << VIRTIO_BALLOON_PFN_SHIFT) << guest_obj[i].order;
+	while (size) {
+	        hvaddr_to_free = gpa2hva(&mr, &madv_size, gpaddr_to_free, &local_err);
 	        if (local_err) {
 			error_report_err(local_err);
 		        return;
 		}
-		ret = qemu_madvise((void *)hvaddr_to_free, 4096, QEMU_MADV_DONTNEED);
+		if (size < madv_size)
+			madv_size = size;
+		ret = qemu_madvise((void *)hvaddr_to_free, madv_size, QEMU_MADV_DONTNEED);
 		if (ret == -1)
 		    printf("\n%d:%s Error: Madvise failed with error:%d\n", __LINE__, __func__, ret);
-		pfn++;
+		gpaddr_to_free += madv_size;
+		size -= madv_size;
 	}
 	i++;
     }

