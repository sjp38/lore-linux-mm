Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C4AF66B0033
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 21:48:40 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id d75so63950164qkc.0
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 18:48:40 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c8si14545358qtg.1.2017.01.24.18.48.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 18:48:39 -0800 (PST)
Date: Tue, 24 Jan 2017 18:48:36 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170125024835.GA24387@bombadil.infradead.org>
References: <20170121084338.GA405@jagdpanzerIV.localdomain>
 <84073d07-6939-b22d-8bda-4fa2a9127555@huawei.com>
 <20170123025826.GA24581@js1304-P5Q-DELUXE>
 <20170123040347.GA2327@jagdpanzerIV.localdomain>
 <20170123062716.GF24581@js1304-P5Q-DELUXE>
 <20170123071339.GD2327@jagdpanzerIV.localdomain>
 <20170123074054.GA12782@bbox>
 <1ac33960-b523-1c58-b2de-8f6ddb3a5219@huawei.com>
 <20170125012905.GA17937@bbox>
 <20170125013244.GB2234@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170125013244.GB2234@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, zhouxianrong <zhouxianrong@huawei.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

On Wed, Jan 25, 2017 at 10:32:44AM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (01/25/17 10:29), Minchan Kim wrote:
> [..]
> > > the result as listed below:
> > > 
> > > zero    pattern_char   pattern_short   pattern_int   pattern_long   total      (unit)
> > > 162989  14454          3534            23516         2769           3294399    (page)
> > > 
> >
> > so, int covers 93%. As considering non-zero dedup hit ratio is low, I think *int* is
> > enough if memset is really fast. So, I'd like to go with 'int' if Sergey doesn't mind.
> 
> yep, 4 byte pattern matching and memset() sounds like a good plan to me

what?  memset ONLY HANDLES BYTES.

I pointed this out earlier, but you don't seem to be listening.  Let me
try it again.

MEMSET ONLY HANDLES BYTES.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
