Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0B11A6B009C
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 10:39:38 -0500 (EST)
Received: by padbj1 with SMTP id bj1so514352pad.5
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 07:39:37 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id uv4si1766103pbc.110.2015.02.19.07.39.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 19 Feb 2015 07:39:37 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NK000BV9ZOLS0B0@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 19 Feb 2015 15:43:33 +0000 (GMT)
Message-id: <54E603B0.60505@samsung.com>
Date: Thu, 19 Feb 2015 18:39:28 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: drivers/net/ethernet/broadcom/tg3.c:17811:37: warning: array
 subscript is above array bounds
References: <201502190116.RU3JpDne%fengguang.wu@intel.com>
In-reply-to: <201502190116.RU3JpDne%fengguang.wu@intel.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On 02/18/2015 08:14 PM, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   f5af19d10d151c5a2afae3306578f485c244db25
> commit: ef7f0d6a6ca8c9e4b27d78895af86c2fbfaeedb2 x86_64: add KASan support
> date:   5 days ago
> config: x86_64-randconfig-iv1-02190055 (attached as .config)
> reproduce:
>   git checkout ef7f0d6a6ca8c9e4b27d78895af86c2fbfaeedb2
>   # save the attached .config to linux build tree
>   make ARCH=x86_64 
> 
> Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
> 
> All warnings:
> 
>    drivers/net/ethernet/broadcom/tg3.c: In function 'tg3_init_one':
>>> drivers/net/ethernet/broadcom/tg3.c:17811:37: warning: array subscript is above array bounds [-Warray-bounds]
>       struct tg3_napi *tnapi = &tp->napi[i];
>                                         ^
>>> drivers/net/ethernet/broadcom/tg3.c:17811:37: warning: array subscript is above array bounds [-Warray-bounds]
> 

This probably a GCC bug: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=59124
I see this warning with 4.9.2, but not with GCC 5 where this should be fixed already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
