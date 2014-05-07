Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f177.google.com (mail-ve0-f177.google.com [209.85.128.177])
	by kanga.kvack.org (Postfix) with ESMTP id CBE5D6B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 10:53:00 -0400 (EDT)
Received: by mail-ve0-f177.google.com with SMTP id db11so1394219veb.8
        for <linux-mm@kvack.org>; Wed, 07 May 2014 07:53:00 -0700 (PDT)
Received: from mail-vc0-x234.google.com (mail-vc0-x234.google.com [2607:f8b0:400c:c03::234])
        by mx.google.com with ESMTPS id g10si2944784vcj.145.2014.05.07.07.52.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 07:52:59 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id hy4so595574vcb.25
        for <linux-mm@kvack.org>; Wed, 07 May 2014 07:52:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAL1ERfOXNrfKqMVs-Yz8yJjKKU3L5fjUEOb0Aeyqc37py-BWEg@mail.gmail.com>
References: <000001cf6816$d538c370$7faa4a50$%yang@samsung.com>
	<20140505152014.GA8551@cerebellum.variantweb.net>
	<1399312844.2570.28.camel@buesod1.americas.hpqcorp.net>
	<20140505134615.04cb627bb2784cabcb844655@linux-foundation.org>
	<1399328550.2646.5.camel@buesod1.americas.hpqcorp.net>
	<000001cf69c9$5776f330$0664d990$%yang@samsung.com>
	<20140507085743.GA31680@bbox>
	<CAL1ERfOXNrfKqMVs-Yz8yJjKKU3L5fjUEOb0Aeyqc37py-BWEg@mail.gmail.com>
Date: Wed, 7 May 2014 23:52:59 +0900
Message-ID: <CAAmzW4Pn2VUEnQ8FyOaBffqfUiHt6ocLEEvyaJrSKmTjaNp_wQ@mail.gmail.com>
Subject: Re: [PATCH] zram: remove global tb_lock by using lock-free CAS
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Bob Liu <bob.liu@oracle.com>, Dan Streetman <ddstreet@ieee.org>, Heesub Shin <heesub.shin@samsung.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

>> Most popular use of zram is the in-memory swap for small embedded system
>> so I don't want to increase memory footprint without good reason although
>> it makes synthetic benchmark. Alhought it's 1M for 1G, it isn't small if we
>> consider compression ratio and real free memory after boot

We can use bit spin lock and this would not increase memory footprint for 32 bit
platform.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
