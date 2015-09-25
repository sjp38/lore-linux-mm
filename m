Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 294E96B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 05:58:15 -0400 (EDT)
Received: by iofb144 with SMTP id b144so105609420iof.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 02:58:15 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id g17si2177489iog.154.2015.09.25.02.58.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 02:58:14 -0700 (PDT)
Received: by pablk4 with SMTP id lk4so5113739pab.3
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 02:58:14 -0700 (PDT)
Date: Fri, 25 Sep 2015 18:57:02 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v2] zbud: allow up to PAGE_SIZE allocations
Message-ID: <20150925095702.GA1049@swordfish>
References: <20150922141733.d7d97f59f207d0655c3b881d@gmail.com>
 <20150923031845.GA31207@cerebellum.local.variantweb.net>
 <CAMJBoFOEYv05FZqDER9hw79re4vrc3wKwGeuL=uoGbCnwodH8Q@mail.gmail.com>
 <20150923215726.GA17171@cerebellum.local.variantweb.net>
 <20150925021325.GA16431@bbox>
 <20150925080525.GE865@swordfish>
 <CAMJBoFPg+rZqXRdJCLK1RYY8vs0NmBZzuTUD33AMzQn+tyN5Jw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMJBoFPg+rZqXRdJCLK1RYY8vs0NmBZzuTUD33AMzQn+tyN5Jw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On (09/25/15 10:27), Vitaly Wool wrote:
> > Have you seen those symptoms before? How did you come up to a conclusion
> > that zram->zbud will do the trick?
> 
> I have data from various tests (partially described here:
> https://lkml.org/lkml/2015/9/17/244) and once again, I'll post a reply

yeah, I guess I'm just not so bright to quickly understand what is wrong
with zsmalloc from those numbers.

> to https://lkml.org/lkml/2015/9/15/33 with more detailed test
> description and explanation why zsmalloc is not the right choice for
> me.

great, thanks.

> > If those symptoms are some sort of a recent addition, then does it help
> > when you disable zsmalloc compaction?
> 
> No it doesn't. OTOH enabled zsmalloc compaction doesn't seem to have a
> substantial effect either.

hm. ok, that was my quick guess.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
