Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id E54716B006E
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 20:49:33 -0500 (EST)
Received: by mail-oi0-f49.google.com with SMTP id a3so22150619oib.8
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 17:49:33 -0800 (PST)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id r8si3046438oev.103.2015.01.28.17.49.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 17:49:32 -0800 (PST)
Received: by mail-oi0-f49.google.com with SMTP id a3so22150490oib.8
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 17:49:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150128231723.GB4706@blaptop>
References: <1422432945-6764-1-git-send-email-minchan@kernel.org>
	<20150128141916.GA14062@swordfish>
	<20150128231723.GB4706@blaptop>
Date: Thu, 29 Jan 2015 09:49:32 +0800
Message-ID: <CADAEsF_eexxoaKH=WxvGhsoyDNPEDa5e3VsU7UgynP7ikVR1cg@mail.gmail.com>
Subject: Re: [PATCH 1/2] zram: free meta table in zram_meta_free
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, sergey.senozhatsky.work@gmail.com

Hello, Minchan

2015-01-29 7:17 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> On Wed, Jan 28, 2015 at 11:19:17PM +0900, Sergey Senozhatsky wrote:
>> On (01/28/15 17:15), Minchan Kim wrote:
>> > zram_meta_alloc() and zram_meta_free() are a pair.
>> > In zram_meta_alloc(), meta table is allocated. So it it better to free
>> > it in zram_meta_free().
>> >
>> > Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
>> > Signed-off-by: Minchan Kim <minchan@kernel.org>
>> > ---
>> >  drivers/block/zram/zram_drv.c | 30 ++++++++++++++----------------
>> >  drivers/block/zram/zram_drv.h |  1 +
>> >  2 files changed, 15 insertions(+), 16 deletions(-)
>> >
>> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
>> > index 9250b3f54a8f..a598ada817f0 100644
>> > --- a/drivers/block/zram/zram_drv.c
>> > +++ b/drivers/block/zram/zram_drv.c
>> > @@ -309,6 +309,18 @@ static inline int valid_io_request(struct zram *zram,
>> >
>> >  static void zram_meta_free(struct zram_meta *meta)
>> >  {
>> > +   size_t index;
>>
>>
>> I don't like how we bloat structs w/o any need.
>> zram keeps ->disksize, so let's use `zram->disksize >> PAGE_SHIFT'
>> instead of introducing ->num_pages.
>
> Right. I overlooked it. I just want to send my patch[2/2] and I thought
> it would be better ganesh's patch to merge first although it's orthogonal.
>
> Ganesh, I hope you resend this patch with Sergey's suggestion.
> If you are busy, please tell me. I will do it instead of you.

OK, I will do it today.
Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
