Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 280936B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 04:47:25 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so103473603ioi.2
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 01:47:25 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id z5si1511537igl.39.2015.09.25.01.47.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 01:47:24 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so101954893pac.2
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 01:47:24 -0700 (PDT)
Date: Fri, 25 Sep 2015 17:47:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] zbud: allow up to PAGE_SIZE allocations
Message-ID: <20150925084617.GA23340@blaptop>
References: <20150922141733.d7d97f59f207d0655c3b881d@gmail.com>
 <20150923031845.GA31207@cerebellum.local.variantweb.net>
 <CAMJBoFOEYv05FZqDER9hw79re4vrc3wKwGeuL=uoGbCnwodH8Q@mail.gmail.com>
 <20150923215726.GA17171@cerebellum.local.variantweb.net>
 <20150925021325.GA16431@bbox>
 <CAMJBoFMDaUv2+V8jQra+HNYBLDZq_B22aqYkjigYJ=V00Z+k4A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMJBoFMDaUv2+V8jQra+HNYBLDZq_B22aqYkjigYJ=V00Z+k4A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, Sep 25, 2015 at 10:17:54AM +0200, Vitaly Wool wrote:
> <snip>
> > I already said questions, opinion and concerns but anything is not clear
> > until now. Only clear thing I could hear is just "compaction stats are
> > better" which is not enough for me. Sorry.
> >
> > 1) https://lkml.org/lkml/2015/9/15/33
> > 2) https://lkml.org/lkml/2015/9/21/2
> 
> Could you please stop perverting the facts, I did answer to that:
> https://lkml.org/lkml/2015/9/21/753.
> 
> Apart from that, an opinion is not necessarily something I would
> answer. Concerns about zsmalloc are not in the scope of this patch's
> discussion. If you have any concerns regarding this particular patch,
> please let us know.

Yes, I don't want to interrupt zbud thing which is Seth should maintain
and I respect his decision but the reason I nacked is you said this patch
aims for supporing zbud into zsmalloc for determinism.
For that, at least, you should discuss with me and Sergey but I feel
you are ignoring our comments.

> 
> > Vitally, Please say what's the root cause of your problem and if it
> > is external fragmentation, what's the problem of my approach?
> >
> > 1) make non-LRU page migrate
> > 2) provide zsmalloc's migratpage
> 
> The problem with your approach is that in your world I need to prove
> my right to use zbud. This is a very strange speculation.

No. If you want to contribute something, you should prove why yours
is better. I already said my concerns and my approach. It's your turn
that you should explain why it's better.

> 
> > We should provide it for CMA as well as external fragmentation.
> > I think we could solve your issue with above approach and
> > it fundamentally makes zsmalloc/zbud happy in future.
> 
> I doubt that but I'll answer in this thread:
> https://lkml.org/lkml/2015/9/15/33 as zsmalloc deficiencies do not
> have direct relation to this particular patch.
> 
> > Also, please keep it in mind that zram has been in linux kernel for
> > memory efficiency for a long time and later zswap/zbud was born
> > for *determinism* at the cost of memory efficiency.
> 
> Yep, and determinism is more important to me than the memory
> efficiency. Dropping the compression ration from 3.2x to 1.8x is okay
> with me and stalls in UI are not.

Then, you could use zswap which have aimed for it with small changes
to prevent writeback.


> 
> ~vitaly

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
