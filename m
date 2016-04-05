Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id C68996B0262
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 11:34:42 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id c20so12958501pfc.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 08:34:42 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z4si8399760par.198.2016.04.05.08.34.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 08:34:42 -0700 (PDT)
Date: Tue, 5 Apr 2016 11:34:39 -0400
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [BUG] lib: zram lz4 compression/decompression still broken on
 big endian
Message-ID: <20160405153439.GA2647@kroah.com>
References: <CALjTZvavWqtLoGQiWb+HxHP4rwRwaZiP0QrPRb+9kYGdicXohg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALjTZvavWqtLoGQiWb+HxHP4rwRwaZiP0QrPRb+9kYGdicXohg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Salvaterra <rsalvaterra@gmail.com>
Cc: linux-kernel@vger.kernel.org, eunb.song@samsung.com, minchan@kernel.org, linux-mm@kvack.org

On Tue, Apr 05, 2016 at 03:07:48PM +0100, Rui Salvaterra wrote:
> Hi,
> 
> 
> I apologise in advance if I've cc'ed too many/the wrong people/lists.
> 
> Whenever I try to use zram with lz4, on my Power Mac G5 (tested with
> kernel 4.4.0-16-powerpc64-smp from Ubuntu 16.04 LTS), I get the
> following on my dmesg:
> 
> [13150.675820] zram: Added device: zram0
> [13150.704133] zram0: detected capacity change from 0 to 5131976704
> [13150.715960] zram: Decompression failed! err=-1, page=0
> [13150.716008] zram: Decompression failed! err=-1, page=0
> [13150.716027] zram: Decompression failed! err=-1, page=0
> [13150.716032] Buffer I/O error on dev zram0, logical block 0, async page read
> 
> I believe Eunbong Song wrote a patch [1] to fix this (or a very
> identical) bug on MIPS, but it never got merged (maybe
> incorrect/incomplete?). Is there any hope of seeing this bug fixed?
> 
> 
> Thanks,
> 
> Rui Salvaterra
> 
> 
> [1] http://comments.gmane.org/gmane.linux.kernel/1752745

For some reason it never got merged, sorry, I don't remember why.

Have you tested this patch?  If so, can you resend it with your
tested-by: line added to it?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
