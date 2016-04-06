Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id AAE8B828F3
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 01:34:06 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id fe3so25728716pab.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 22:34:06 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id yk10si2144094pac.24.2016.04.05.22.34.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 22:34:05 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id r187so3259224pfr.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 22:34:05 -0700 (PDT)
Date: Wed, 6 Apr 2016 14:33:26 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [BUG] lib: zram lz4 compression/decompression still broken on
 big endian
Message-ID: <20160406053325.GA415@swordfish>
References: <CALjTZvavWqtLoGQiWb+HxHP4rwRwaZiP0QrPRb+9kYGdicXohg@mail.gmail.com>
 <20160405153439.GA2647@kroah.com>
 <CALjTZvat4FhSc1AvNzjNwfa5tYydiTQLTnxz6cU7-Qd+h5mi6A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALjTZvat4FhSc1AvNzjNwfa5tYydiTQLTnxz6cU7-Qd+h5mi6A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Salvaterra <rsalvaterra@gmail.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, eunb.song@samsung.com, minchan@kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (04/05/16 17:02), Rui Salvaterra wrote:
[..]
> > For some reason it never got merged, sorry, I don't remember why.
> >
> > Have you tested this patch?  If so, can you resend it with your
> > tested-by: line added to it?
> >
> > thanks,
> >
> > greg k-h
> 
> Hi, Greg
> 
> 
> No, I haven't tested the patch at all. I want to do so, and fix if if
> necessary, but I still need to learn how to (meaning, I need to watch
> your "first kernel patch" presentation again). I'd love to get
> involved in kernel development, and this seems to be a good
> opportunity, if none of the kernel gods beat me to it (I may need a
> month, but then again nobody complained about this bug in almost two
> years).

Hello Rui,

may we please ask you to test the patch first? quite possible there
is nothing to fix there; I've no access to mips h/w but the patch
seems correct to me.

LZ4_READ_LITTLEENDIAN_16 does get_unaligned_le16(), so
LZ4_WRITE_LITTLEENDIAN_16 must do put_unaligned_le16() /* not put_unaligned() */

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
