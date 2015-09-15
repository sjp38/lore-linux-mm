Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE676B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 20:49:13 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so158839635pac.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 17:49:13 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id kh8si24295198pab.53.2015.09.14.17.49.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 17:49:12 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so161647338pac.2
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 17:49:12 -0700 (PDT)
Date: Tue, 15 Sep 2015 09:49:57 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 0/3] allow zram to use zbud as underlying allocator
Message-ID: <20150915004957.GA1860@swordfish>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: minchan@kernel.org, sergey.senozhatsky@gmail.com, ddstreet@ieee.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (09/14/15 15:49), Vitaly Wool wrote:
> While using ZRAM on a small RAM footprint devices, together with KSM,
> I ran into several occasions when moving pages from compressed swap back
> into the "normal" part of RAM caused significant latencies in system operation.
> By using zbud I lose in compression ratio but gain in determinism, lower
> latencies and lower fragmentation, so in the coming patches I tried to
> generalize what I've done to enable zbud for zram so far.
> 

do you have CONFIG_PGTABLE_MAPPING enabled or disabled? or
kmap_atomic/memcpy/kunmap_atomic is not the root cause here?
can you provide more details please?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
