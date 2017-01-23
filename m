Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5B96B0033
	for <linux-mm@kvack.org>; Sun, 22 Jan 2017 21:52:08 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id t6so183167477pgt.6
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 18:52:08 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id v84si14218947pfd.3.2017.01.22.18.52.06
        for <linux-mm@kvack.org>;
        Sun, 22 Jan 2017 18:52:07 -0800 (PST)
Date: Mon, 23 Jan 2017 11:58:27 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170123025826.GA24581@js1304-P5Q-DELUXE>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <1484296195-99771-1-git-send-email-zhouxianrong@huawei.com>
 <20170121084338.GA405@jagdpanzerIV.localdomain>
 <84073d07-6939-b22d-8bda-4fa2a9127555@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84073d07-6939-b22d-8bda-4fa2a9127555@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong <zhouxianrong@huawei.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, minchan@kernel.org, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

Hello,

On Sun, Jan 22, 2017 at 10:58:38AM +0800, zhouxianrong wrote:
> 1. memset is just set a int value but i want to set a long value.

Sorry for late review.

Do we really need to set a long value? I cannot believe that
long value is repeated in the page. Value repeatition is
usually done by value 0 or 1 and it's enough to use int. And, I heard
that value 0 or 1 is repeated in Android. Could you check the distribution
of the value in the same page?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
