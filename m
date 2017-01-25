Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B93266B0069
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 20:32:31 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 80so256793610pfy.2
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 17:32:31 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id w86si21565303pfa.192.2017.01.24.17.32.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 17:32:30 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id 204so18023840pge.2
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 17:32:30 -0800 (PST)
Date: Wed, 25 Jan 2017 10:32:44 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170125013244.GB2234@jagdpanzerIV.localdomain>
References: <1484296195-99771-1-git-send-email-zhouxianrong@huawei.com>
 <20170121084338.GA405@jagdpanzerIV.localdomain>
 <84073d07-6939-b22d-8bda-4fa2a9127555@huawei.com>
 <20170123025826.GA24581@js1304-P5Q-DELUXE>
 <20170123040347.GA2327@jagdpanzerIV.localdomain>
 <20170123062716.GF24581@js1304-P5Q-DELUXE>
 <20170123071339.GD2327@jagdpanzerIV.localdomain>
 <20170123074054.GA12782@bbox>
 <1ac33960-b523-1c58-b2de-8f6ddb3a5219@huawei.com>
 <20170125012905.GA17937@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170125012905.GA17937@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: zhouxianrong <zhouxianrong@huawei.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

Hello,

On (01/25/17 10:29), Minchan Kim wrote:
[..]
> > the result as listed below:
> > 
> > zero    pattern_char   pattern_short   pattern_int   pattern_long   total      (unit)
> > 162989  14454          3534            23516         2769           3294399    (page)
> > 
>
> so, int covers 93%. As considering non-zero dedup hit ratio is low, I think *int* is
> enough if memset is really fast. So, I'd like to go with 'int' if Sergey doesn't mind.

yep, 4 byte pattern matching and memset() sounds like a good plan to me

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
