Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 305AFC04A6B
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:15:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFC93208C3
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:15:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="UjeQp29e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFC93208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 793786B0003; Tue, 14 May 2019 00:15:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 744086B0005; Tue, 14 May 2019 00:15:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60B256B0007; Tue, 14 May 2019 00:15:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 385526B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:15:27 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id e88so8511492ote.14
        for <linux-mm@kvack.org>; Mon, 13 May 2019 21:15:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=QpRQ5RKoCjF8LRntvBnA0N48k6E1wZWnQrRBNWvrbJk=;
        b=V8uEu/Wo9pI4mIGovcm1XyNeHMsJUvB1E8QRnjxsjHsvxDv00IQOehT6z6eoRte6n/
         P/+eUKVvSiJ6ASYzp7/0jKKxSjF5ZDhyKjJuiSiK8exJz/D0rMM/5nnEStYQJGs0LROg
         TT/fkplGjfcvHZZqwavkb943QI19rgkfiKLzhw7OMBG6d3dw3dFAF0fOU+OgalmBIAQV
         aYAQyl8Mf5ZTXVl2hBP11VmEyUGg8XRNR92xuM+bRVknBzr95sgq1LOEZVmsjoXXzVW5
         fD+gUsjrf869dQd2MJB/OVafHk/0Hu7rfSwVGZ4+AUSYT2+xcem6RytVVEBV+BSafo7x
         8EEA==
X-Gm-Message-State: APjAAAXN5XoGGcqv8n3LIYdGW+t9ZiR+SM1y1rfsNAKZRN5FvFOJPh0q
	bHrV1YR5cKe794vz2DibQFyyjT/8q34t28V/DXXhOKjDdjrASV27YTJH/HYrnqZKtdGtSqQQI5S
	otNeXym7UZ07qBB6b6X8gTm3Qx5ibBOjAOzV7CSKpdOQVpkcyMfNwvzQCSsBWRPESkQ==
X-Received: by 2002:aca:de56:: with SMTP id v83mr1517976oig.31.1557807326890;
        Mon, 13 May 2019 21:15:26 -0700 (PDT)
X-Received: by 2002:aca:de56:: with SMTP id v83mr1517952oig.31.1557807326060;
        Mon, 13 May 2019 21:15:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557807326; cv=none;
        d=google.com; s=arc-20160816;
        b=SECbRqP/QbGxIGzCVT9Dgm9vUHuc1sk+5Dm29zeXjzvQNzkOCRkHJxqJklldQGWQMI
         Zb8UFyM33tkdhqD1vHXCD7YKUfz6Ej8w9qaJh+iYtFTIZkMVCCjxDbb/Ocng31zMFE1k
         gsbxEJ8z7b1YVzgcYSK2AywordtVTMGqG5P3MpsQilpzcczNTl0QXpTtinQYva6VBeE5
         ophjPI5qS5p6GSqIVC9dB+4TgROJFiQs04f0dnYJlXaJ+WIkPvOtDVMgTBwcjmsJe7Ti
         SgTymyXfPFkeuNOGHKq9RaXd5EiLrjjv3+S70XuktxasJCdL6iFyGoTsrJdSDC0LYphX
         hJGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QpRQ5RKoCjF8LRntvBnA0N48k6E1wZWnQrRBNWvrbJk=;
        b=iv96+9Groncrdk+uuSTKGZomxF69kZf+fHJ4jQjI6aJ8NG72c/9smoLXbwXjJbSzex
         H+1eIvkuo0c54LmYK8T9CGtCrnM9fkC6yTe1Lk/s6Um3lUtw9LRfYGvlKgadAwaIWPGJ
         2Mfa6FVUx8p4EUVinEAHfg8kPT6BqtCq1BVqdbMU+6Xax6l6dYpfLrwCTiHEcfC/w6Xu
         eRTz3rmDF8TmzKA2hTwMhqu+YHhakvbVhCHUuHVqj3vHoKxLeZ8QTay6mqPwT+0+2HAT
         XnHY+/eNm/EVtx6lfL7AwT0Bijs/HVHBnUEocFSe5xh7wJTbuVEV0FIWy+h8kO8kr2+0
         by2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=UjeQp29e;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x2sor7614528otg.134.2019.05.13.21.15.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 May 2019 21:15:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=UjeQp29e;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QpRQ5RKoCjF8LRntvBnA0N48k6E1wZWnQrRBNWvrbJk=;
        b=UjeQp29e977K98sPeUHL7M2b26uz7ODCB1tPABTq8ycEneyS4c1UAuTfIjvJlmhKzW
         rgT+CLkzVz6Tj12F2GaNYO9z4bvlQqIiNlC0lA9pUjUBtExWciRMAcdda9tmeKRhjiif
         U5p6czdMWpPq57Q5YbCtPICTa2/bR8qnSDzyOdMYm/jpTVMS5P8yg+ynABoxRYVy/xMj
         Ns8pcVkcANjUsy88CGOTiuzbT6+MMd1jobBa2rDPPNHEOEXy/dQb90zw/UeZwuo46jDs
         3FHRbEo2GIwX+trJ5hV48Rrik7r2xZXpO8rC0CU4Xl2+3RJfOxDHNojG2wDfiY+ZDqd8
         rBxA==
X-Google-Smtp-Source: APXvYqxGVd1tqyXunJ456PV9dYVPRSqpzeYT2Q8gKJip9CosURLuJUd04BkNcpneRISWSBXU9PkRJuzBrm9HzMBwpUc=
X-Received: by 2002:a9d:12f2:: with SMTP id g105mr3369334otg.116.1557807325778;
 Mon, 13 May 2019 21:15:25 -0700 (PDT)
MIME-Version: 1.0
References: <20190514025354.9108-1-aneesh.kumar@linux.ibm.com>
In-Reply-To: <20190514025354.9108-1-aneesh.kumar@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 13 May 2019 21:15:15 -0700
Message-ID: <CAPcyv4hsTvyRnLGr3y4JB6zPzdxb7WGQgaWs=5vRqf=L1DYynQ@mail.gmail.com>
Subject: Re: [RFC PATCH] mm/nvdimm: Fix kernel crash on devm_mremap_pages_release
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Keith Busch <keith.busch@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ add Keith who was looking at something similar ]

On Mon, May 13, 2019 at 7:54 PM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> When we initialize the namespace, if we support altmap, we don't initialize all the
> backing struct page where as while releasing the namespace we look at some of
> these uninitilized struct page. This results in a kernel crash as below.
>
> kernel BUG at include/linux/mm.h:1034!
> cpu 0x2: Vector: 700 (Program Check) at [c00000024146b870]
>     pc: c0000000003788f8: devm_memremap_pages_release+0x258/0x3a0
>     lr: c0000000003788f4: devm_memremap_pages_release+0x254/0x3a0
>     sp: c00000024146bb00
>    msr: 800000000282b033
>   current = 0xc000000241382f00
>   paca    = 0xc00000003fffd680   irqmask: 0x03   irq_happened: 0x01
>     pid   = 4114, comm = ndctl
>  c0000000009bf8c0 devm_action_release+0x30/0x50
>  c0000000009c0938 release_nodes+0x268/0x2d0
>  c0000000009b95b4 device_release_driver_internal+0x164/0x230
>  c0000000009b638c unbind_store+0x13c/0x190
>  c0000000009b4f44 drv_attr_store+0x44/0x60
>  c00000000058ccc0 sysfs_kf_write+0x70/0xa0
>  c00000000058b52c kernfs_fop_write+0x1ac/0x290
>  c0000000004a415c __vfs_write+0x3c/0x70
>  c0000000004a85ac vfs_write+0xec/0x200
>  c0000000004a8920 ksys_write+0x80/0x130
>  c00000000000bee4 system_call+0x5c/0x70
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  mm/page_alloc.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 59661106da16..892eabe1ec13 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5740,8 +5740,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>
>  #ifdef CONFIG_ZONE_DEVICE
>         /*
> -        * Honor reservation requested by the driver for this ZONE_DEVICE
> -        * memory. We limit the total number of pages to initialize to just
> +        * We limit the total number of pages to initialize to just
>          * those that might contain the memory mapping. We will defer the
>          * ZONE_DEVICE page initialization until after we have released
>          * the hotplug lock.
> @@ -5750,8 +5749,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>                 if (!altmap)
>                         return;
>
> -               if (start_pfn == altmap->base_pfn)
> -                       start_pfn += altmap->reserve;

If it's reserved then we should not be accessing, even if the above
works in practice. Isn't the fix something more like this to fix up
the assumptions at release time?

diff --git a/kernel/memremap.c b/kernel/memremap.c
index a856cb5ff192..9074ba14572c 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -90,6 +90,7 @@ static void devm_memremap_pages_release(void *data)
  struct device *dev = pgmap->dev;
  struct resource *res = &pgmap->res;
  resource_size_t align_start, align_size;
+ struct vmem_altmap *altmap = pgmap->altmap_valid ? &pgmap->altmap : NULL;
  unsigned long pfn;
  int nid;

@@ -102,7 +103,10 @@ static void devm_memremap_pages_release(void *data)
  align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
  - align_start;

- nid = page_to_nid(pfn_to_page(align_start >> PAGE_SHIFT));
+ pfn = align_start >> PAGE_SHIFT;
+ if (altmap)
+ pfn += vmem_altmap_offset(altmap);
+ nid = page_to_nid(pfn_to_page(pfn));

  mem_hotplug_begin();
  if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
@@ -110,8 +114,7 @@ static void devm_memremap_pages_release(void *data)
  __remove_pages(page_zone(pfn_to_page(pfn)), pfn,
  align_size >> PAGE_SHIFT, NULL);
  } else {
- arch_remove_memory(nid, align_start, align_size,
- pgmap->altmap_valid ? &pgmap->altmap : NULL);
+ arch_remove_memory(nid, align_start, align_size, altmap);
  kasan_remove_zero_shadow(__va(align_start), align_size);
  }
  mem_hotplug_done();

