Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f173.google.com (mail-vc0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4240682965
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 18:35:23 -0400 (EDT)
Received: by mail-vc0-f173.google.com with SMTP id lf12so8874055vcb.18
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 15:35:23 -0700 (PDT)
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
        by mx.google.com with ESMTPS id rm4si19893353vcb.95.2014.07.09.15.35.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 15:35:22 -0700 (PDT)
Received: by mail-vc0-f174.google.com with SMTP id hy4so8886974vcb.19
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 15:35:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140703181059.GJ17372@arm.com>
References: <1404324218-4743-1-git-send-email-lauraa@codeaurora.org>
	<1404324218-4743-2-git-send-email-lauraa@codeaurora.org>
	<20140703181059.GJ17372@arm.com>
Date: Wed, 9 Jul 2014 15:35:21 -0700
Message-ID: <CAOesGMjBMgutN6EDv=CeY=iM8zV=ti69_iyL=t5-HTD+pbCjzw@mail.gmail.com>
Subject: Re: [PATCHv4 1/5] lib/genalloc.c: Add power aligned algorithm
From: Olof Johansson <olof@lixom.net>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Laura Abbott <lauraa@codeaurora.org>, Catalin Marinas <Catalin.Marinas@arm.com>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Jul 3, 2014 at 11:10 AM, Will Deacon <will.deacon@arm.com> wrote:
> On Wed, Jul 02, 2014 at 07:03:34PM +0100, Laura Abbott wrote:
>>
>> One of the more common algorithms used for allocation
>> is to align the start address of the allocation to
>> the order of size requested. Add this as an algorithm
>> option for genalloc.
>>
>> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
>> ---
>>  include/linux/genalloc.h |  4 ++++
>>  lib/genalloc.c           | 20 ++++++++++++++++++++
>>  2 files changed, 24 insertions(+)
>>
>> diff --git a/include/linux/genalloc.h b/include/linux/genalloc.h
>> index 1c2fdaa..3cd0934 100644
>> --- a/include/linux/genalloc.h
>> +++ b/include/linux/genalloc.h
>> @@ -110,6 +110,10 @@ extern void gen_pool_set_algo(struct gen_pool *pool, genpool_algo_t algo,
>>  extern unsigned long gen_pool_first_fit(unsigned long *map, unsigned long size,
>>               unsigned long start, unsigned int nr, void *data);
>>
>> +extern unsigned long gen_pool_first_fit_order_align(unsigned long *map,
>> +             unsigned long size, unsigned long start, unsigned int nr,
>> +             void *data);
>> +
>
> You could also update gen_pool_first_fit to call this new function instead.

+1, that'd be slightly nicer and remove one exported symbol.

But, as Will says, up to you. Either option:

Acked-by: Olof Johansson <olof@lixom.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
