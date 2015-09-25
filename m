Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id DD46B6B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 06:51:35 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so14226877wic.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 03:51:35 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id d19si4009073wjr.138.2015.09.25.03.51.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 03:51:34 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so14226400wic.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 03:51:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150925084617.GA23340@blaptop>
References: <20150922141733.d7d97f59f207d0655c3b881d@gmail.com>
	<20150923031845.GA31207@cerebellum.local.variantweb.net>
	<CAMJBoFOEYv05FZqDER9hw79re4vrc3wKwGeuL=uoGbCnwodH8Q@mail.gmail.com>
	<20150923215726.GA17171@cerebellum.local.variantweb.net>
	<20150925021325.GA16431@bbox>
	<CAMJBoFMDaUv2+V8jQra+HNYBLDZq_B22aqYkjigYJ=V00Z+k4A@mail.gmail.com>
	<20150925084617.GA23340@blaptop>
Date: Fri, 25 Sep 2015 12:51:34 +0200
Message-ID: <CAMJBoFOTM2DBBHXikcUkncC40D8DoTpf42zjk5cFv19t1L79pw@mail.gmail.com>
Subject: Re: [PATCH v2] zbud: allow up to PAGE_SIZE allocations
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, Sep 25, 2015 at 10:47 AM, Minchan Kim <minchan@kernel.org> wrote:
> On Fri, Sep 25, 2015 at 10:17:54AM +0200, Vitaly Wool wrote:
>> <snip>
>> > I already said questions, opinion and concerns but anything is not clear
>> > until now. Only clear thing I could hear is just "compaction stats are
>> > better" which is not enough for me. Sorry.
>> >
>> > 1) https://lkml.org/lkml/2015/9/15/33
>> > 2) https://lkml.org/lkml/2015/9/21/2
>>
>> Could you please stop perverting the facts, I did answer to that:
>> https://lkml.org/lkml/2015/9/21/753.
>>
>> Apart from that, an opinion is not necessarily something I would
>> answer. Concerns about zsmalloc are not in the scope of this patch's
>> discussion. If you have any concerns regarding this particular patch,
>> please let us know.
>
> Yes, I don't want to interrupt zbud thing which is Seth should maintain
> and I respect his decision but the reason I nacked is you said this patch
> aims for supporing zbud into zsmalloc for determinism.
> For that, at least, you should discuss with me and Sergey but I feel
> you are ignoring our comments.
>
>>
>> > Vitally, Please say what's the root cause of your problem and if it
>> > is external fragmentation, what's the problem of my approach?
>> >
>> > 1) make non-LRU page migrate
>> > 2) provide zsmalloc's migratpage
>>
>> The problem with your approach is that in your world I need to prove
>> my right to use zbud. This is a very strange speculation.
>
> No. If you want to contribute something, you should prove why yours
> is better. I already said my concerns and my approach. It's your turn
> that you should explain why it's better.

In fact, I do not add any specific functionality, my patches just do
what should have already been done -- that is, zram should have been
converted to use zpool api long ago. Your opposing to that is counter
productive.

>> > We should provide it for CMA as well as external fragmentation.
>> > I think we could solve your issue with above approach and
>> > it fundamentally makes zsmalloc/zbud happy in future.
>>
>> I doubt that but I'll answer in this thread:
>> https://lkml.org/lkml/2015/9/15/33 as zsmalloc deficiencies do not
>> have direct relation to this particular patch.
>>
>> > Also, please keep it in mind that zram has been in linux kernel for
>> > memory efficiency for a long time and later zswap/zbud was born
>> > for *determinism* at the cost of memory efficiency.
>>
>> Yep, and determinism is more important to me than the memory
>> efficiency. Dropping the compression ration from 3.2x to 1.8x is okay
>> with me and stalls in UI are not.
>
> Then, you could use zswap which have aimed for it with small changes
> to prevent writeback.

Should i come with a patch to zram explicitly stating that it is not
meant to be used in any environment that is deterministic / worst case
critical? Is that what you are aiming for?

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
