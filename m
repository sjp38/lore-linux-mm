Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id EEF3F6B0033
	for <linux-mm@kvack.org>; Sun, 22 Jan 2017 22:33:08 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id 65so93884383otq.2
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 19:33:08 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id h20si5471664oib.88.2017.01.22.19.33.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 22 Jan 2017 19:33:08 -0800 (PST)
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <1484296195-99771-1-git-send-email-zhouxianrong@huawei.com>
 <20170121084338.GA405@jagdpanzerIV.localdomain>
 <84073d07-6939-b22d-8bda-4fa2a9127555@huawei.com>
 <20170123025826.GA24581@js1304-P5Q-DELUXE>
From: zhouxianrong <zhouxianrong@huawei.com>
Message-ID: <67d60a22-b09f-cea4-eeb0-0c8bb02a315d@huawei.com>
Date: Mon, 23 Jan 2017 11:32:43 +0800
MIME-Version: 1.0
In-Reply-To: <20170123025826.GA24581@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, minchan@kernel.org, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

hey Joonsoo:
	i would test and give the same element type later.

On 2017/1/23 10:58, Joonsoo Kim wrote:
> Hello,
>
> On Sun, Jan 22, 2017 at 10:58:38AM +0800, zhouxianrong wrote:
>> 1. memset is just set a int value but i want to set a long value.
>
> Sorry for late review.
>
> Do we really need to set a long value? I cannot believe that
> long value is repeated in the page. Value repeatition is
> usually done by value 0 or 1 and it's enough to use int. And, I heard
> that value 0 or 1 is repeated in Android. Could you check the distribution
> of the value in the same page?
>
> Thanks.
>
>
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
