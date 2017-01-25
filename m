Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E70C6B0069
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 00:38:36 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y143so262425941pfb.6
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 21:38:36 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id z32si397100plh.321.2017.01.24.21.38.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 21:38:35 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id 194so18647099pgd.0
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 21:38:35 -0800 (PST)
Date: Wed, 25 Jan 2017 14:38:49 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170125053849.GF2234@jagdpanzerIV.localdomain>
References: <20170123040347.GA2327@jagdpanzerIV.localdomain>
 <20170123062716.GF24581@js1304-P5Q-DELUXE>
 <20170123071339.GD2327@jagdpanzerIV.localdomain>
 <20170123074054.GA12782@bbox>
 <1ac33960-b523-1c58-b2de-8f6ddb3a5219@huawei.com>
 <20170125012905.GA17937@bbox>
 <20170125013244.GB2234@jagdpanzerIV.localdomain>
 <20170125024835.GA24387@bombadil.infradead.org>
 <20170125041857.GC2234@jagdpanzerIV.localdomain>
 <20170125045137.GA18289@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170125045137.GA18289@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Matthew Wilcox <willy@infradead.org>, zhouxianrong <zhouxianrong@huawei.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

On (01/25/17 13:51), Minchan Kim wrote:
[..]
> > Minchan, zhouxianrong, I was completely wrong. we can't
> > do memset(). d'oh, I did not know it truncates 4 bytes to
> > one byte only (doesn't make too much sense to me).
> 
> Now, I read Matthew's comment and understood. Thanks.
> It means zhouxianrong's patch I sent recently is okay?

this one looks OK to me
https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1316290.html


I'd agree with Joonsoo that doing forward prefetching is _probably_ better
than backwards prefetching. not that it necessarily should confuse the CPU
(need to google if ARM handles it normally), but still.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
