Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 25D4D900015
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 13:24:14 -0500 (EST)
Received: by pdev10 with SMTP id v10so2259199pde.3
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 10:24:13 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id tk5si2996735pac.190.2015.02.04.10.24.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Feb 2015 10:24:13 -0800 (PST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so4352996pab.6
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 10:24:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150204150942.GA100965@lkp-sb04>
References: <201502042321.YTAJE4EN%fengguang.wu@intel.com>
	<20150204150942.GA100965@lkp-sb04>
Date: Wed, 4 Feb 2015 22:24:12 +0400
Message-ID: <CAPAsAGyK8RD3i0n5bZ=KzxWpkNv2k2s5gzcTEWXy+LkREBXdfQ@mail.gmail.com>
Subject: Re: [PATCH mmotm] x86_64: __asan_load2 can be static
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

2015-02-04 18:09 GMT+03:00 kbuild test robot <fengguang.wu@intel.com>:
> mm/kasan/kasan.c:276:1: sparse: symbol '__asan_load2' was not declared. Should it be static?
> mm/kasan/kasan.c:277:1: sparse: symbol '__asan_load4' was not declared. Should it be static?
> mm/kasan/kasan.c:278:1: sparse: symbol '__asan_load8' was not declared. Should it be static?
> mm/kasan/kasan.c:279:1: sparse: symbol '__asan_load16' was not declared. Should it be static?
> mm/kasan/report.c:188:1: sparse: symbol '__asan_report_load1_noabort' was not declared. Should it be static?
> mm/kasan/report.c:189:1: sparse: symbol '__asan_report_load2_noabort' was not declared. Should it be static?
> mm/kasan/report.c:190:1: sparse: symbol '__asan_report_load4_noabort' was not declared. Should it be static?
> mm/kasan/report.c:191:1: sparse: symbol '__asan_report_load8_noabort' was not declared. Should it be static?
> mm/kasan/report.c:192:1: sparse: symbol '__asan_report_load16_noabort' was not declared. Should it be static?
> mm/kasan/report.c:193:1: sparse: symbol '__asan_report_store1_noabort' was not declared. Should it be static?
> mm/kasan/report.c:194:1: sparse: symbol '__asan_report_store2_noabort' was not declared. Should it be static?
> mm/kasan/report.c:195:1: sparse: symbol '__asan_report_store4_noabort' was not declared. Should it be static?
> mm/kasan/report.c:196:1: sparse: symbol '__asan_report_store8_noabort' was not declared. Should it be static?
> mm/kasan/report.c:197:1: sparse: symbol '__asan_report_store16_noabort' was not declared. Should it be static?
>
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
>  kasan.c  |    8 ++++----
>  report.c |   20 ++++++++++----------
>  2 files changed, 14 insertions(+), 14 deletions(-)
>

Nak. These symbols shouldn't be static.
All these function invoked only by compiler, so we don't need declarations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
