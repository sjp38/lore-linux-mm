Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 145546B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 04:27:28 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so10129844wic.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 01:27:27 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id om11si3181353wic.29.2015.09.25.01.27.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 01:27:27 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so9581810wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 01:27:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150925080525.GE865@swordfish>
References: <20150922141733.d7d97f59f207d0655c3b881d@gmail.com>
	<20150923031845.GA31207@cerebellum.local.variantweb.net>
	<CAMJBoFOEYv05FZqDER9hw79re4vrc3wKwGeuL=uoGbCnwodH8Q@mail.gmail.com>
	<20150923215726.GA17171@cerebellum.local.variantweb.net>
	<20150925021325.GA16431@bbox>
	<20150925080525.GE865@swordfish>
Date: Fri, 25 Sep 2015 10:27:26 +0200
Message-ID: <CAMJBoFPg+rZqXRdJCLK1RYY8vs0NmBZzuTUD33AMzQn+tyN5Jw@mail.gmail.com>
Subject: Re: [PATCH v2] zbud: allow up to PAGE_SIZE allocations
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

> Have you seen those symptoms before? How did you come up to a conclusion
> that zram->zbud will do the trick?

I have data from various tests (partially described here:
https://lkml.org/lkml/2015/9/17/244) and once again, I'll post a reply
to https://lkml.org/lkml/2015/9/15/33 with more detailed test
description and explanation why zsmalloc is not the right choice for
me.

> If those symptoms are some sort of a recent addition, then does it help
> when you disable zsmalloc compaction?

No it doesn't. OTOH enabled zsmalloc compaction doesn't seem to have a
substantial effect either.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
