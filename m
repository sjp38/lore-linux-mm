Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A167A6B0033
	for <linux-mm@kvack.org>; Sun,  1 Oct 2017 18:29:24 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u7so3443896qku.3
        for <linux-mm@kvack.org>; Sun, 01 Oct 2017 15:29:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w190sor6270607qkc.112.2017.10.01.15.29.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 01 Oct 2017 15:29:24 -0700 (PDT)
Date: Sun, 1 Oct 2017 18:29:22 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v4 4/5] cramfs: add mmap support
In-Reply-To: <20171001083052.GB17116@infradead.org>
Message-ID: <nycvar.YSQ.7.76.1710011805070.5407@knanqh.ubzr>
References: <20170927233224.31676-1-nicolas.pitre@linaro.org> <20170927233224.31676-5-nicolas.pitre@linaro.org> <20171001083052.GB17116@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>

On Sun, 1 Oct 2017, Christoph Hellwig wrote:

> up_read(&mm->mmap_sem) in the fault path is a still a complete
> no-go,
> 
> NAK

Care to elaborate?

What about mm/filemap.c:__lock_page_or_retry() then?

Why the special handling on mm->mmap_sem with VM_FAULT_RETRY?

What are the potential problems with my approach I didn't cover yet?

Serious: I'm simply looking for solutions here.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
