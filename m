Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 425C16B0033
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 23:52:04 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z67so261567666pgb.0
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 20:52:04 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id q4si287386plb.39.2017.01.24.20.52.02
        for <linux-mm@kvack.org>;
        Tue, 24 Jan 2017 20:52:03 -0800 (PST)
Date: Wed, 25 Jan 2017 13:51:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170125045137.GA18289@bbox>
References: <20170123025826.GA24581@js1304-P5Q-DELUXE>
 <20170123040347.GA2327@jagdpanzerIV.localdomain>
 <20170123062716.GF24581@js1304-P5Q-DELUXE>
 <20170123071339.GD2327@jagdpanzerIV.localdomain>
 <20170123074054.GA12782@bbox>
 <1ac33960-b523-1c58-b2de-8f6ddb3a5219@huawei.com>
 <20170125012905.GA17937@bbox>
 <20170125013244.GB2234@jagdpanzerIV.localdomain>
 <20170125024835.GA24387@bombadil.infradead.org>
 <20170125041857.GC2234@jagdpanzerIV.localdomain>
MIME-Version: 1.0
In-Reply-To: <20170125041857.GC2234@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, zhouxianrong <zhouxianrong@huawei.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

On Wed, Jan 25, 2017 at 01:18:58PM +0900, Sergey Senozhatsky wrote:
> On (01/24/17 18:48), Matthew Wilcox wrote:
> > On Wed, Jan 25, 2017 at 10:32:44AM +0900, Sergey Senozhatsky wrote:
> > > Hello,
> > > 
> > > On (01/25/17 10:29), Minchan Kim wrote:
> > > [..]
> > > > > the result as listed below:
> > > > > 
> > > > > zero    pattern_char   pattern_short   pattern_int   pattern_long   total      (unit)
> > > > > 162989  14454          3534            23516         2769           3294399    (page)
> > > > > 
> > > >
> > > > so, int covers 93%. As considering non-zero dedup hit ratio is low, I think *int* is
> > > > enough if memset is really fast. So, I'd like to go with 'int' if Sergey doesn't mind.
> > > 
> > > yep, 4 byte pattern matching and memset() sounds like a good plan to me
> > 
> > what?  memset ONLY HANDLES BYTES.
> > 
> > I pointed this out earlier, but you don't seem to be listening.  Let me
> > try it again.
> > 
> > MEMSET ONLY HANDLES BYTES.
> 
> dammit... how did that happen...
> 
> 
> Matthew, you are absolute right. and, yes, I missed out your previous
> mail, indeed. sorry. and thanks for "re-pointing" that out.
> 
> 
> Minchan, zhouxianrong, I was completely wrong. we can't
> do memset(). d'oh, I did not know it truncates 4 bytes to
> one byte only (doesn't make too much sense to me).

Now, I read Matthew's comment and understood. Thanks.
It means zhouxianrong's patch I sent recently is okay?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
