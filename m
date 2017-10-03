Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 733916B0260
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 11:40:31 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id r18so6477332qkh.9
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 08:40:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w17sor3663582qtw.102.2017.10.03.08.40.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Oct 2017 08:40:30 -0700 (PDT)
Date: Tue, 3 Oct 2017 11:40:28 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v4 4/5] cramfs: add mmap support
In-Reply-To: <20171003153659.GA31600@infradead.org>
Message-ID: <nycvar.YSQ.7.76.1710031137580.5407@knanqh.ubzr>
References: <20170927233224.31676-1-nicolas.pitre@linaro.org> <20170927233224.31676-5-nicolas.pitre@linaro.org> <20171001083052.GB17116@infradead.org> <nycvar.YSQ.7.76.1710011805070.5407@knanqh.ubzr> <CAFLxGvzfQrvU-8w7F26mez6fCQD+iS_qRJpLSU+2DniEGouEfA@mail.gmail.com>
 <nycvar.YSQ.7.76.1710021931270.5407@knanqh.ubzr> <20171003145732.GA8890@infradead.org> <nycvar.YSQ.7.76.1710031107290.5407@knanqh.ubzr> <20171003153659.GA31600@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Richard Weinberger <richard.weinberger@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-embedded@vger.kernel.org" <linux-embedded@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Chris Brandt <Chris.Brandt@renesas.com>

On Tue, 3 Oct 2017, Christoph Hellwig wrote:

> On Tue, Oct 03, 2017 at 11:30:50AM -0400, Nicolas Pitre wrote:
> > Unless you have a better scheme altogether  to suggest of course, given 
> > the existing constraints.
> 
> I still can't understand why this convoluted fault path that finds
> vma, attempts with all kinds of races and then tries to update things
> like vm_ops is even nessecary.
> 
> We have direct mappings of physical address perfectly working in the
> DAX code (even with write support!) or in drivers using remap_pfn_range
> so a really good explanation why neither scheme can be used is needed
> first.

I provided that explanation several times by now in my cover letter. And 
separately even to you directly at least once.  What else should I do?


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
