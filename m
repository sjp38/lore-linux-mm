Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6276B025E
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 00:46:22 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 204so263230556pge.5
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 21:46:22 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id z62si22241488pgz.214.2017.01.24.21.46.20
        for <linux-mm@kvack.org>;
        Tue, 24 Jan 2017 21:46:21 -0800 (PST)
Date: Wed, 25 Jan 2017 14:44:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170125054416.GC18289@bbox>
References: <20170123062716.GF24581@js1304-P5Q-DELUXE>
 <20170123071339.GD2327@jagdpanzerIV.localdomain>
 <20170123074054.GA12782@bbox>
 <1ac33960-b523-1c58-b2de-8f6ddb3a5219@huawei.com>
 <20170125012905.GA17937@bbox>
 <20170125013244.GB2234@jagdpanzerIV.localdomain>
 <20170125024835.GA24387@bombadil.infradead.org>
 <20170125041857.GC2234@jagdpanzerIV.localdomain>
 <20170125045137.GA18289@bbox>
 <20170125053849.GF2234@jagdpanzerIV.localdomain>
MIME-Version: 1.0
In-Reply-To: <20170125053849.GF2234@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, zhouxianrong <zhouxianrong@huawei.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

On Wed, Jan 25, 2017 at 02:38:49PM +0900, Sergey Senozhatsky wrote:
> On (01/25/17 13:51), Minchan Kim wrote:
> [..]
> > > Minchan, zhouxianrong, I was completely wrong. we can't
> > > do memset(). d'oh, I did not know it truncates 4 bytes to
> > > one byte only (doesn't make too much sense to me).
> > 
> > Now, I read Matthew's comment and understood. Thanks.
> > It means zhouxianrong's patch I sent recently is okay?
> 
> this one looks OK to me
> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1316290.html
> 
> 
> I'd agree with Joonsoo that doing forward prefetching is _probably_ better
> than backwards prefetching. not that it necessarily should confuse the CPU
> (need to google if ARM handles it normally), but still.

Okay, let's settle down.

zhouxianrong, please resend one Sergey pointed out with changing to
forward loop. though, sorry for a lot confusion!

> 
> 	-ss
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
