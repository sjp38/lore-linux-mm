Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4376B00CD
	for <linux-mm@kvack.org>; Thu,  8 May 2014 02:22:16 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so2088111pdj.11
        for <linux-mm@kvack.org>; Wed, 07 May 2014 23:22:15 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id tm7si8099pab.193.2014.05.07.23.22.14
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 23:22:15 -0700 (PDT)
Date: Thu, 8 May 2014 15:24:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: remove global tb_lock by using lock-free CAS
Message-ID: <20140508062418.GF5282@bbox>
References: <000001cf6816$d538c370$7faa4a50$%yang@samsung.com>
 <20140505152014.GA8551@cerebellum.variantweb.net>
 <1399312844.2570.28.camel@buesod1.americas.hpqcorp.net>
 <20140505134615.04cb627bb2784cabcb844655@linux-foundation.org>
 <1399328550.2646.5.camel@buesod1.americas.hpqcorp.net>
 <000001cf69c9$5776f330$0664d990$%yang@samsung.com>
 <20140507085743.GA31680@bbox>
 <CAL1ERfOXNrfKqMVs-Yz8yJjKKU3L5fjUEOb0Aeyqc37py-BWEg@mail.gmail.com>
 <CAAmzW4Pn2VUEnQ8FyOaBffqfUiHt6ocLEEvyaJrSKmTjaNp_wQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4Pn2VUEnQ8FyOaBffqfUiHt6ocLEEvyaJrSKmTjaNp_wQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Weijie Yang <weijie.yang.kh@gmail.com>, Weijie Yang <weijie.yang@samsung.com>, Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Bob Liu <bob.liu@oracle.com>, Dan Streetman <ddstreet@ieee.org>, Heesub Shin <heesub.shin@samsung.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, May 07, 2014 at 11:52:59PM +0900, Joonsoo Kim wrote:
> >> Most popular use of zram is the in-memory swap for small embedded system
> >> so I don't want to increase memory footprint without good reason although
> >> it makes synthetic benchmark. Alhought it's 1M for 1G, it isn't small if we
> >> consider compression ratio and real free memory after boot
> 
> We can use bit spin lock and this would not increase memory footprint for 32 bit
> platform.

Sounds like a idea.
Weijie, Do you mind testing with bit spin lock?

> 
> Thanks.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
