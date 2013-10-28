Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3DA3A6B0037
	for <linux-mm@kvack.org>; Mon, 28 Oct 2013 11:45:10 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so7309127pad.30
        for <linux-mm@kvack.org>; Mon, 28 Oct 2013 08:45:09 -0700 (PDT)
Received: from psmtp.com ([74.125.245.156])
        by mx.google.com with SMTP id yj4si13368472pac.50.2013.10.28.08.45.07
        for <linux-mm@kvack.org>;
        Mon, 28 Oct 2013 08:45:09 -0700 (PDT)
Received: by mail-ve0-f177.google.com with SMTP id oz11so4982375veb.8
        for <linux-mm@kvack.org>; Mon, 28 Oct 2013 08:45:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131028141310.GA4970@schnuecks.de>
References: <20131024200730.GB17447@blackmetal.musicnaut.iki.fi>
	<20131026143617.GA14034@mudshark.cambridge.arm.com>
	<20131027195115.208f40f3@tom-ThinkPad-T410>
	<20131028141310.GA4970@schnuecks.de>
Date: Mon, 28 Oct 2013 23:45:06 +0800
Message-ID: <CACVXFVMA61Wi6jZs_kf329fCj2oMXgbg9x0EhP5OpEEgPVw4kw@mail.gmail.com>
Subject: Re: ARM/kirkwood: v3.12-rc6: kernel BUG at mm/util.c:390!
From: Ming Lei <tom.leiming@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Baatz <gmbnomis@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>, Aaro Koskinen <aaro.koskinen@iki.fi>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Tejun Heo <tj@kernel.org>, "James E.J. Bottomley" <JBottomley@parallels.com>, Jens Axboe <axboe@kernel.dk>

On Mon, Oct 28, 2013 at 10:13 PM, Simon Baatz <gmbnomis@gmail.com> wrote:
> On Sun, Oct 27, 2013 at 07:51:15PM +0800, Ming Lei wrote:
>> diff --git a/lib/scatterlist.c b/lib/scatterlist.c
>> index a685c8a..eea8806 100644
>> --- a/lib/scatterlist.c
>> +++ b/lib/scatterlist.c
>> @@ -577,7 +577,7 @@ void sg_miter_stop(struct sg_mapping_iter *miter)
>>               miter->__offset += miter->consumed;
>>               miter->__remaining -= miter->consumed;
>>
>> -             if (miter->__flags & SG_MITER_TO_SG)
>> +             if ((miter->__flags & SG_MITER_TO_SG) && !PageSlab(page))
>
> This is what I was going to propose, but I would have used
> !PageSlab(miter->page) ;-)

OK, I will send a formal one later, thank you for pointing out the above, :-)

>
>>                       flush_kernel_dcache_page(miter->page);
>
> With this, a kernel with DEBUG_VM now boots on Kirkwood.



Thanks,
-- 
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
