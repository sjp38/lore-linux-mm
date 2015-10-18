Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id ACE1F82F64
	for <linux-mm@kvack.org>; Sun, 18 Oct 2015 01:10:57 -0400 (EDT)
Received: by pabws5 with SMTP id ws5so6526901pab.2
        for <linux-mm@kvack.org>; Sat, 17 Oct 2015 22:10:57 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id tb8si42149286pab.225.2015.10.17.22.10.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Oct 2015 22:10:56 -0700 (PDT)
Date: Sat, 17 Oct 2015 22:10:56 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] mm: cma: Fix incorrect type conversion for size during
 dma allocation
Message-ID: <20151018051056.GB20643@kroah.com>
References: <1444854232-4085-1-git-send-email-rvaswani@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444854232-4085-1-git-send-email-rvaswani@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rohit Vaswani <rvaswani@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 14, 2015 at 01:23:51PM -0700, Rohit Vaswani wrote:
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
> Signed-off-by: Rohit Vaswani <rvaswani@codeaurora.org>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
