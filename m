Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 953486B0038
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 19:33:32 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id q7so5032887ioi.12
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 16:33:32 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b3sor8894298qkd.1.2017.10.02.16.33.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Oct 2017 16:33:31 -0700 (PDT)
Date: Mon, 2 Oct 2017 19:33:29 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v4 4/5] cramfs: add mmap support
In-Reply-To: <CAFLxGvzfQrvU-8w7F26mez6fCQD+iS_qRJpLSU+2DniEGouEfA@mail.gmail.com>
Message-ID: <nycvar.YSQ.7.76.1710021931270.5407@knanqh.ubzr>
References: <20170927233224.31676-1-nicolas.pitre@linaro.org> <20170927233224.31676-5-nicolas.pitre@linaro.org> <20171001083052.GB17116@infradead.org> <nycvar.YSQ.7.76.1710011805070.5407@knanqh.ubzr>
 <CAFLxGvzfQrvU-8w7F26mez6fCQD+iS_qRJpLSU+2DniEGouEfA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard.weinberger@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-embedded@vger.kernel.org" <linux-embedded@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Chris Brandt <Chris.Brandt@renesas.com>

On Tue, 3 Oct 2017, Richard Weinberger wrote:

> On Mon, Oct 2, 2017 at 12:29 AM, Nicolas Pitre <nicolas.pitre@linaro.org> wrote:
> > On Sun, 1 Oct 2017, Christoph Hellwig wrote:
> >
> >> up_read(&mm->mmap_sem) in the fault path is a still a complete
> >> no-go,
> >>
> >> NAK
> >
> > Care to elaborate?
> >
> > What about mm/filemap.c:__lock_page_or_retry() then?
> 
> As soon you up_read() in the page fault path other tasks will race
> with you before
> you're able to grab the write lock.

But I _know_ that.

Could you highlight an area in my code where this is not accounted for?


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
