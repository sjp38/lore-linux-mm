Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 4EB6D6B0033
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 12:18:02 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so6604000pdi.13
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 09:18:01 -0700 (PDT)
Date: Thu, 15 Aug 2013 01:17:53 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 0/5] zram/zsmalloc promotion
Message-ID: <20130814161753.GB2706@gmail.com>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org>
 <CAA25o9Q1KVHEzdeXJFe9A8K9MULysq_ShWrUBZM4-h=5vmaQ8w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9Q1KVHEzdeXJFe9A8K9MULysq_ShWrUBZM4-h=5vmaQ8w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mgorman@suse.de>

Hi Luigi,

On Wed, Aug 14, 2013 at 08:53:31AM -0700, Luigi Semenzato wrote:
> During earlier discussions of zswap there was a plan to make it work
> with zsmalloc as an option instead of zbud. Does zbud work for

AFAIR, it was not an optoin but zsmalloc was must but there were
several objections because zswap's notable feature is to dump
compressed object to real swap storage. For that, zswap needs to
store bounded objects in a zpage so that dumping could be bounded, too.
Otherwise, it could encounter OOM easily.

> compression factors better than 2:1?  I have the impression (maybe
> wrong) that it does not.  In our use of zram (Chrome OS) typical

Since zswap changed allocator from zsmalloc to zbud, I didn't follow
because I had no interest of low compressoin ratio allocator so
I have no idea of status of zswap at a moment but I guess it would be
still 2:1.

> overall compression ratios are between 2.5:1 and 3:1.  We would hate
> to waste that memory if we switch to zswap.

If you have real swap storage, zswap might be better although I have
no number but real swap is money for embedded system and it has sudden
garbage collection on firmware side if we use eMMC or SSD so that it
could affect system latency. Morever, if we start to use real swap,
maybe we should encrypt the data and it would be severe overhead(CPU
and Power).

And what I am considering after promoting for zram feature is
asynchronous I/O and it's possible because zram is block device.

Thanks!
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
