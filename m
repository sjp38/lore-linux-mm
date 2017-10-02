Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E0F706B0069
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 18:45:29 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id j73so1646314lfg.4
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 15:45:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s197sor2648683wmd.16.2017.10.02.15.45.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Oct 2017 15:45:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <nycvar.YSQ.7.76.1710011805070.5407@knanqh.ubzr>
References: <20170927233224.31676-1-nicolas.pitre@linaro.org>
 <20170927233224.31676-5-nicolas.pitre@linaro.org> <20171001083052.GB17116@infradead.org>
 <nycvar.YSQ.7.76.1710011805070.5407@knanqh.ubzr>
From: Richard Weinberger <richard.weinberger@gmail.com>
Date: Tue, 3 Oct 2017 00:45:27 +0200
Message-ID: <CAFLxGvzfQrvU-8w7F26mez6fCQD+iS_qRJpLSU+2DniEGouEfA@mail.gmail.com>
Subject: Re: [PATCH v4 4/5] cramfs: add mmap support
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-embedded@vger.kernel.org" <linux-embedded@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Chris Brandt <Chris.Brandt@renesas.com>

On Mon, Oct 2, 2017 at 12:29 AM, Nicolas Pitre <nicolas.pitre@linaro.org> wrote:
> On Sun, 1 Oct 2017, Christoph Hellwig wrote:
>
>> up_read(&mm->mmap_sem) in the fault path is a still a complete
>> no-go,
>>
>> NAK
>
> Care to elaborate?
>
> What about mm/filemap.c:__lock_page_or_retry() then?

As soon you up_read() in the page fault path other tasks will race
with you before
you're able to grab the write lock.

HTH

-- 
Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
