Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 85344828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 04:54:20 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id c10so29491159pfc.2
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 01:54:20 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id ah10si8446975pad.118.2016.02.18.01.54.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 01:54:19 -0800 (PST)
Received: by mail-pa0-x232.google.com with SMTP id yy13so28086674pab.3
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 01:54:19 -0800 (PST)
Date: Thu, 18 Feb 2016 18:55:36 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC PATCH 3/3] mm/zsmalloc: change ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160218095536.GA503@swordfish>
References: <1455764556-13979-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1455764556-13979-4-git-send-email-sergey.senozhatsky@gmail.com>
 <CAAmzW4O-yQ5GBTE-6WvCL-hZeqyW=k3Fzn4_9G2qkMmp=ceuJg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4O-yQ5GBTE-6WvCL-hZeqyW=k3Fzn4_9G2qkMmp=ceuJg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello Joonsoo,

On (02/18/16 17:28), Joonsoo Kim wrote:
> 2016-02-18 12:02 GMT+09:00 Sergey Senozhatsky
> <sergey.senozhatsky.work@gmail.com>:
> > ZS_MAX_PAGES_PER_ZSPAGE does not have to be order or 2. The existing
> > limit of 4 pages per zspage sets a tight limit on ->huge classes, which
> > results in increased memory wastage and consumption.
> 
> There is a reason that it is order of 2. Increasing ZS_MAX_PAGES_PER_ZSPAGE
> is related to ZS_MIN_ALLOC_SIZE. If we don't have enough OBJ_INDEX_BITS,
> ZS_MIN_ALLOC_SIZE would be increase and it causes regression on some
> system.

Thanks!

do you mean PHYSMEM_BITS != BITS_PER_LONG systems? PAE/LPAE? isn't it
the case that on those systems ZS_MIN_ALLOC_SIZE already bigger than 32?

MAX_PHYSMEM_BITS	36
_PFN_BITS		36 - 12
OBJ_INDEX_BITS		(32 - (36 - 12) - 1)
ZS_MIN_ALLOC_SIZE	MAX(32, 4 << 12 >> (32 - (36 - 12) - 1))  !=  32

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
