Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 49FA86B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 22:12:05 -0400 (EDT)
Received: by iow1 with SMTP id 1so6772319iow.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 19:12:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id oq3si908826igb.73.2015.10.12.19.12.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 19:12:04 -0700 (PDT)
Date: Mon, 12 Oct 2015 19:11:55 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] mm: cma: Fix incorrect type conversion for size during
 dma allocation
Message-ID: <20151013021155.GA24333@kroah.com>
References: <1444694447-23826-1-git-send-email-rvaswani@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444694447-23826-1-git-send-email-rvaswani@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rohit Vaswani <rvaswani@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 12, 2015 at 05:00:47PM -0700, Rohit Vaswani wrote:
> This was found during userspace fuzzing test when a large size
> dma cma allocation is made by driver(like ion) through userspace.
> 
>  show_stack+0x10/0x1c
>  dump_stack+0x74/0xc8
>  kasan_report_error+0x2b0/0x408
>  kasan_report+0x34/0x40
>  __asan_storeN+0x15c/0x168
>  memset+0x20/0x44
>  __dma_alloc_coherent+0x114/0x18c
> 
> Change-Id: I4e2db81c496604ecbe93ec21fe8ee94589c8eb63

We can't do anything with gerrit ids, sorry, please remove.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
