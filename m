Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB7F6B0038
	for <linux-mm@kvack.org>; Wed, 31 Dec 2014 08:05:20 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id et14so21239815pad.17
        for <linux-mm@kvack.org>; Wed, 31 Dec 2014 05:05:20 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id fw4si61611009pbb.0.2014.12.31.05.05.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 31 Dec 2014 05:05:18 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NHG00HJ177HC240@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 31 Dec 2014 13:09:17 +0000 (GMT)
Message-id: <54A3F488.8060904@samsung.com>
Date: Wed, 31 Dec 2014 14:05:12 +0100
From: Andrzej Hajda <a.hajda@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC PATCH 0/4] kstrdup optimization
References: <1419864510-24834-1-git-send-email-a.hajda@samsung.com>
In-reply-to: <1419864510-24834-1-git-send-email-a.hajda@samsung.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org

On 12/29/2014 03:48 PM, Andrzej Hajda wrote:

(...)

> As I have tested it on mobile platform (exynos4210-trats) it saves above 2600
> string duplications. Below simple stats about the most frequent duplications:
> Count String
>   880 power
>   874 subsystem
>   130 device
>   126 parameters
>    61 iommu_group
>    40 driver
>    28 bdi
>    28 none
>    25 sclk_mpll
>    23 sclk_usbphy0
>    23 sclk_hdmi24m
>    23 xusbxti
>    22 sclk_vpll
>    22 sclk_epll
>    22 xxti
>    20 sclk_hdmiphy
>    11 aclk100

Minor update, printk buffer was too short during tests so I have not
catched everything. In fact the patchset saves 3260 duplications. Below
stats per kstrdup_const caller:
   2260 __kernfs_new_node+0x28/0xc4
    631 clk_register+0xc8/0x1b8
    318 clk_register+0x34/0x1b8
     51 kmem_cache_create+0x7c/0x1c8

Regards
Andrzej

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
