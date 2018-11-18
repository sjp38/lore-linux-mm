Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1706B154A
	for <linux-mm@kvack.org>; Sun, 18 Nov 2018 10:02:57 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id i12so4995413ita.3
        for <linux-mm@kvack.org>; Sun, 18 Nov 2018 07:02:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u17sor10195494itb.18.2018.11.18.07.02.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 18 Nov 2018 07:02:56 -0800 (PST)
MIME-Version: 1.0
References: <1542542538-11938-1-git-send-email-laoar.shao@gmail.com> <20181118121318.GC7861@bombadil.infradead.org>
In-Reply-To: <20181118121318.GC7861@bombadil.infradead.org>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sun, 18 Nov 2018 23:02:19 +0800
Message-ID: <CALOAHbAfWkAYJPTRfyPmHKSmg7UEhtnamzUVx9xd4oYkqi_x8g@mail.gmail.com>
Subject: Re: [PATCH] mm/filemap.c: minor optimization in write_iter file operation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org
Cc: Andrew Morton <akpm@linux-foundation.org>, darrick.wong@oracle.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Nov 18, 2018 at 8:13 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Sun, Nov 18, 2018 at 08:02:18PM +0800, Yafang Shao wrote:
> > This little adjustment on bitwise operation could make the code a little
> > faster.
> > As write_iter is used in lots of critical path, so this code change is
> > useful for performance.
>
> Did you check the before/after code generation with this patch applied?
>

Yes, I did.
My oompiler is gcc-4.8.5, a litte old, and with CONFIG_CC_OPTIMIZE_FOR_SIZE on.
The output file is differrent.

> $ diff -u before.S after.S
> --- before.S    2018-11-18 07:11:48.031096768 -0500
> +++ after.S     2018-11-18 07:11:36.883069103 -0500
> @@ -1,5 +1,5 @@
>
> -before.o:     file format elf32-i386
> +after.o:     file format elf32-i386
>
>
>  Disassembly of section .text:
>
> with gcc 8.2.0, I see no difference, indicating that the compiler already
> makes this optimisation.

Could pls. try set CONFIG_CC_OPTIMIZE_FOR_SIZE on and then compare them again ?

Thanks
Yafang
