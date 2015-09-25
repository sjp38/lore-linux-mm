Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id EA8436B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 04:17:55 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so9259523wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 01:17:55 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id e1si9554347wiy.2.2015.09.25.01.17.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 01:17:55 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so9259022wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 01:17:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150925021325.GA16431@bbox>
References: <20150922141733.d7d97f59f207d0655c3b881d@gmail.com>
	<20150923031845.GA31207@cerebellum.local.variantweb.net>
	<CAMJBoFOEYv05FZqDER9hw79re4vrc3wKwGeuL=uoGbCnwodH8Q@mail.gmail.com>
	<20150923215726.GA17171@cerebellum.local.variantweb.net>
	<20150925021325.GA16431@bbox>
Date: Fri, 25 Sep 2015 10:17:54 +0200
Message-ID: <CAMJBoFMDaUv2+V8jQra+HNYBLDZq_B22aqYkjigYJ=V00Z+k4A@mail.gmail.com>
Subject: Re: [PATCH v2] zbud: allow up to PAGE_SIZE allocations
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

<snip>
> I already said questions, opinion and concerns but anything is not clear
> until now. Only clear thing I could hear is just "compaction stats are
> better" which is not enough for me. Sorry.
>
> 1) https://lkml.org/lkml/2015/9/15/33
> 2) https://lkml.org/lkml/2015/9/21/2

Could you please stop perverting the facts, I did answer to that:
https://lkml.org/lkml/2015/9/21/753.

Apart from that, an opinion is not necessarily something I would
answer. Concerns about zsmalloc are not in the scope of this patch's
discussion. If you have any concerns regarding this particular patch,
please let us know.

> Vitally, Please say what's the root cause of your problem and if it
> is external fragmentation, what's the problem of my approach?
>
> 1) make non-LRU page migrate
> 2) provide zsmalloc's migratpage

The problem with your approach is that in your world I need to prove
my right to use zbud. This is a very strange speculation.

> We should provide it for CMA as well as external fragmentation.
> I think we could solve your issue with above approach and
> it fundamentally makes zsmalloc/zbud happy in future.

I doubt that but I'll answer in this thread:
https://lkml.org/lkml/2015/9/15/33 as zsmalloc deficiencies do not
have direct relation to this particular patch.

> Also, please keep it in mind that zram has been in linux kernel for
> memory efficiency for a long time and later zswap/zbud was born
> for *determinism* at the cost of memory efficiency.

Yep, and determinism is more important to me than the memory
efficiency. Dropping the compression ration from 3.2x to 1.8x is okay
with me and stalls in UI are not.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
