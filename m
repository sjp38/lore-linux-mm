Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 74AF56B0254
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 04:50:13 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so3465325pab.3
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 01:50:13 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id le8si4104033pab.136.2015.09.25.01.50.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 01:50:12 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so100217587pac.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 01:50:12 -0700 (PDT)
Date: Fri, 25 Sep 2015 17:50:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] zbud: allow up to PAGE_SIZE allocations
Message-ID: <20150925085002.GA17075@blaptop>
References: <20150922141733.d7d97f59f207d0655c3b881d@gmail.com>
 <20150923031845.GA31207@cerebellum.local.variantweb.net>
 <CAMJBoFOEYv05FZqDER9hw79re4vrc3wKwGeuL=uoGbCnwodH8Q@mail.gmail.com>
 <20150923215726.GA17171@cerebellum.local.variantweb.net>
 <20150925021325.GA16431@bbox>
 <CAMJBoFMDaUv2+V8jQra+HNYBLDZq_B22aqYkjigYJ=V00Z+k4A@mail.gmail.com>
 <20150925084617.GA23340@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150925084617.GA23340@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, Sep 25, 2015 at 05:47:13PM +0900, Minchan Kim wrote:
> On Fri, Sep 25, 2015 at 10:17:54AM +0200, Vitaly Wool wrote:
> > <snip>
> > > I already said questions, opinion and concerns but anything is not clear
> > > until now. Only clear thing I could hear is just "compaction stats are
> > > better" which is not enough for me. Sorry.
> > >
> > > 1) https://lkml.org/lkml/2015/9/15/33
> > > 2) https://lkml.org/lkml/2015/9/21/2
> > 
> > Could you please stop perverting the facts, I did answer to that:
> > https://lkml.org/lkml/2015/9/21/753.
> > 
> > Apart from that, an opinion is not necessarily something I would
> > answer. Concerns about zsmalloc are not in the scope of this patch's
> > discussion. If you have any concerns regarding this particular patch,
> > please let us know.
> 
> Yes, I don't want to interrupt zbud thing which is Seth should maintain
> and I respect his decision but the reason I nacked is you said this patch
> aims for supporing zbud into zsmalloc for determinism.
                               zram

Sorry for the typo.
                

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
