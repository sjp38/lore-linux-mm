Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71D34C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 08:37:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35DEA2085A
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 08:37:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tEneCk2D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35DEA2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEE216B0003; Mon, 25 Mar 2019 04:37:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9F1E6B0005; Mon, 25 Mar 2019 04:37:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B32C6B000D; Mon, 25 Mar 2019 04:37:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1F16B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 04:37:22 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id b16so7310167iot.5
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 01:37:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to:cc;
        bh=z+7nkfvtTneu9IAc9nPOkE1jK+Q1sW5bgIuB7n+sbEg=;
        b=cyIyScW7k8YyoReD5CPioGzLUh/rqYc43pOKhrI6NuAOTef8d4mV5sTYHEUSy+oNs1
         wzdL8TLeUC2ghnOlQjoPm8D+Vo6Q5tuHDKG7Pck4LVLjkAya4jM5cIqd5RrpmgSm7xJN
         U7hMZ4yr2Wz0ZYYva+9Jw8Vn42QedGNriJOJchR14Xa4vaz2CaGGFvIHbtCxnIY2rh/P
         Hhw04Pesu9q+OJ9GpFp03mMhzeHe3lXOv6NeJUrAWkw+juepQvsnxrXI9Q/GYBAZ9DOX
         LDbee3drJqSgRHm5On8gYrGuTQg3cW1cKXTiYcSphHBWXLowSvDTjBSvPG/PaITEmMwc
         1F0g==
X-Gm-Message-State: APjAAAXFp81caT4PpY1MBPRGwwQTprMGMsc43rR65erRipj0u8jZIK/c
	7omE+nsd/uAl1jZN34bBVkE7IyHyl9SMtR0j9mjg+f+D+py+KuUzUSjt+YY4A9K3nMS2B6UIZdQ
	bqDglIxPBJXmxZYIDu82xy1vVjOEtB+vLEaSZpi4CXknipVLaKsqL2LILtlpiPgsGAQ==
X-Received: by 2002:a6b:b909:: with SMTP id j9mr6346027iof.184.1553503042200;
        Mon, 25 Mar 2019 01:37:22 -0700 (PDT)
X-Received: by 2002:a6b:b909:: with SMTP id j9mr6346001iof.184.1553503041518;
        Mon, 25 Mar 2019 01:37:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553503041; cv=none;
        d=google.com; s=arc-20160816;
        b=jFOg9jAjhogoUrvfP59JZ6Hr3sXF5tK67TX/Ph/TLfMPwHsQTGoPPIuN/09vTm48ul
         8WmQ4Vesg4BmtPyA9yt1LbQXoEQJKI3h5zFuSozMpSuyvtMOanzXFToA3ANT0LtQPgKL
         KchZhTCJ67ssC7Oqqq55AXfkqK3Il6AV/x9iMyEdKGxDCw/XjVvx6fsX/l8AA5XyCFm2
         UmTrpmzUaoZFIPmCWzWeutSWVbujT5GgK1WboiJNytyESneCPOzeWjynpDWQw0QRoXfU
         lUX3vJwwgdJRoKJa9IRztsk/HOGHmbRY7tYLxxSmFODLGdXegsShUmz7ZPO3UHnQ7ilG
         9FHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=z+7nkfvtTneu9IAc9nPOkE1jK+Q1sW5bgIuB7n+sbEg=;
        b=y5W67geJ6EEoZHMcGIE2HDTLvVI9l18bqUq7kdxbpaKfdOV3VqDsjZd2cGVyJqWDca
         cdiAZNWCfN80iteMWHelQ1OupCYZ1l9yYQdyk8E7lA3cFI9C9QUqWNdPGuKAsW8hhqZJ
         htXXslCdSpGlPQODCLg75y7zTOoYbKLjR8orka5T5+BqYsmhwEkKruswwXrpklT2rPFy
         8fVgJyw2oUHnfm8UpQdMILHWfgvd4zbwiQJ7K6eKyha+iZ/aL5O4pd0FpBNT+3qoRr5A
         vkoI487wvowqWToUPXNm/KCGmncprNgcgIle+0XfJJJ9/PICuCP9ZzLiy+ib8MnHke0W
         PDIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tEneCk2D;
       spf=pass (google.com: domain of hzpeterchen@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=hzpeterchen@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i33sor1665047jaf.10.2019.03.25.01.37.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 01:37:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of hzpeterchen@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tEneCk2D;
       spf=pass (google.com: domain of hzpeterchen@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=hzpeterchen@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=z+7nkfvtTneu9IAc9nPOkE1jK+Q1sW5bgIuB7n+sbEg=;
        b=tEneCk2DBOvDwWM5bKHnxu24dtnzYvGjnhsaBfGf6CGteGlL/5A4hXjWZBSOXwtFqV
         GYvWRr4RolPdRSiMp4dC2tOlOszLOOo1Ejiu2krkhz34fnMu/nc1n3D8SO9t95tpCi2X
         3vI+7ZQfQw0MCWs9I3MVINWmSyo8FgeCe6bFuU91/bZLlLU2EmoRy3MoAKcuMwRgtLuK
         I4XetwYdsU7u8DlIpbVln7Jd6MeYr1sE/2ztH21XyFPwsxbOLXLaHmQfqfQ23jETTjWe
         Tt/+fZh4j+Fe9jOULS+DinJN+2yz/gikdyHgCyki/dGPkcm84hbzpCBF5D4/NqUbM8z4
         DucQ==
X-Google-Smtp-Source: APXvYqzLioj7ifEyiQBbdN4BUILKKXqwd6o59EWJMPuAq3GSCzjncDqBBOxqnOBfuxnNW1A1+YSQzUwY5RILgX3b4zY=
X-Received: by 2002:a02:a083:: with SMTP id g3mr3916773jah.44.1553503041292;
 Mon, 25 Mar 2019 01:37:21 -0700 (PDT)
MIME-Version: 1.0
From: Peter Chen <hzpeterchen@gmail.com>
Date: Mon, 25 Mar 2019 16:37:09 +0800
Message-ID: <CAL411-pwHq4Df-FsBu=Vzd4CR6Pzee2yR579hHeZuh8T7fBNJA@mail.gmail.com>
Subject: Why CMA allocater fails if there is a signal pending?
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-usb@vger.kernel.org, 
	linux-arm-kernel@lists.infradead.org, lkml <linux-kernel@vger.kernel.org>, 
	linux-mm@kvack.org, peter.chen@nxp.com, fugang.duan@nxp.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Michal & Marek,

I meet an issue that the DMA (CMA used) allocation failed if there is a user
signal, Eg Ctrl+C, it causes the USB xHCI stack fails to resume due to
dma_alloc_coherent
failed. It can be easy to reproduce if the user press Ctrl+C at
suspend/resume test.
Below is the call stack:

[  466.585755] [<ffff000008192f9c>] alloc_contig_range+0x1ac/0x3b8
[  466.585763] [<ffff00000820956c>] cma_alloc+0x10c/0x2d8
[  466.585772] [<ffff0000086de1bc>] dma_alloc_from_contiguous+0x3c/0x48
[  466.585779] [<ffff00000809bf20>] __dma_alloc+0xa8/0x248
[  466.585788] [<ffff0000089121e0>] xhci_mem_init+0x1c8/0x7f8
[  466.585794] [<ffff0000089074bc>] xhci_init+0x74/0x170
[  466.585800] [<ffff00000890a21c>] xhci_resume+0x184/0x630
[  466.585807] [<ffff0000088efec4>] cdns3_host_resume+0x34/0x68
[  466.585813] [<ffff0000088ebfd8>] cdns3_resume+0x1b0/0x2d0
[  466.585820] [<ffff0000086e3c10>] dpm_run_callback+0x50/0xd0
[  466.585825] [<ffff0000086e42a0>] device_resume+0xa0/0x288
[  466.585832] [<ffff0000086e5834>] dpm_resume+0xfc/0x218
[  466.585837] [<ffff0000086e5b5c>] dpm_resume_end+0x14/0x28
[  466.585844] [<ffff000008114630>] suspend_devices_and_enter+0x140/0x5b0
[  466.585849] [<ffff000008114d34>] pm_suspend+0x294/0x300
[  466.585857] [<ffff0000081136e4>] state_store+0x84/0x108
[  466.585865] [<ffff000008de9a2c>] kobj_attr_store+0x14/0x28
[  466.585873] [<ffff00000828cb90>] sysfs_kf_write+0x48/0x58
[  466.585879] [<ffff00000828be34>] kernfs_fop_write+0xcc/0x1c8
[  466.585886] [<ffff00000820e764>] __vfs_write+0x1c/0x118
[  466.585894] [<ffff00000820ea4c>] vfs_write+0xa4/0x1b0
[  466.585901] [<ffff00000820ecfc>] SyS_write+0x44/0xa0

I added WARN_ON at below code for above stack:
__alloc_contig_migrate_range
        while (pfn < end || !list_empty(&cc->migratepages)) {
                if (fatal_signal_pending(current)) {
                        WARN_ON(1);
                        ret = -EINTR;
                        break;
                }

The USB xHCI function can work well if I commented out above code.
Thanks.

BR,
Peter Chen

