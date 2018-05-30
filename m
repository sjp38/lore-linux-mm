Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id C6C796B0274
	for <linux-mm@kvack.org>; Wed, 30 May 2018 08:14:11 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id d61-v6so11523704otb.21
        for <linux-mm@kvack.org>; Wed, 30 May 2018 05:14:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 11-v6sor15645048oip.30.2018.05.30.05.14.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 May 2018 05:14:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180530120133.GC17450@bombadil.infradead.org>
References: <59623b15001e5a20ac32b1a393db88722be2e718.1527679621.git.baolin.wang@linaro.org>
 <20180530120133.GC17450@bombadil.infradead.org>
From: Baolin Wang <baolin.wang@linaro.org>
Date: Wed, 30 May 2018 20:14:09 +0800
Message-ID: <CAMz4ku+fBt2uY6MbiMX1X-6jtjdpqp=DWNMrefOG4SsUHWN4kQ@mail.gmail.com>
Subject: Re: [PATCH] mm: dmapool: Check the dma pool name
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Mark Brown <broonie@kernel.org>

On 30 May 2018 at 20:01, Matthew Wilcox <willy@infradead.org> wrote:
> On Wed, May 30, 2018 at 07:28:43PM +0800, Baolin Wang wrote:
>> It will be crash if we pass one NULL name when creating one dma pool,
>> so we should check the passing name when copy it to dma pool.
>
> NAK.  Crashing is the appropriate thing to do.  Fix the caller to not
> pass NULL.
>
> If you permit NULL to be passed then you're inviting crashes or just
> bad reporting later when pool->name is printed.

I think it just prints one NULL pool name. Sometimes the device
doesn't care the dma pool names, so I think we can make code more
solid to valid the passing parameters like other code does.
Or can we add check to return NULL when the passing name is NULL
instead of crashing the kernel? Thanks.

-- 
Baolin.wang
Best Regards
