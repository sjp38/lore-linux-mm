Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B39B6B061F
	for <linux-mm@kvack.org>; Thu, 10 May 2018 11:33:58 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id a14-v6so1400669plt.7
        for <linux-mm@kvack.org>; Thu, 10 May 2018 08:33:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r59-v6si1010920plb.187.2018.05.10.08.33.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 May 2018 08:33:57 -0700 (PDT)
Date: Thu, 10 May 2018 15:33:55 +0000
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH v2 2/2] mm: provide a fallback for PAGE_KERNEL_EXEC for
 architectures
Message-ID: <20180510153355.GB27853@wotan.suse.de>
References: <20180510014447.15989-1-mcgrof@kernel.org>
 <20180510014447.15989-3-mcgrof@kernel.org>
 <CAMuHMdUJTKqqWzFi594_y_F1HdONr3+FOSTzg-n0ogoroFUqpA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdUJTKqqWzFi594_y_F1HdONr3+FOSTzg-n0ogoroFUqpA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Greg KH <gregkh@linuxfoundation.org>, Matthew Wilcox <willy@infradead.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, May 10, 2018 at 09:45:56AM +0200, Geert Uytterhoeven wrote:
> Hi Luis,
> 
> On Thu, May 10, 2018 at 3:44 AM, Luis R. Rodriguez <mcgrof@kernel.org> wrote:
> > Some architectures just don't have PAGE_KERNEL_EXEC. The mm/nommu.c
> > and mm/vmalloc.c code have been using PAGE_KERNEL as a fallback for years.
> > Move this fallback to asm-generic.
> >
> > Architectures which do not define PAGE_KERNEL_EXEC yet:
> >
> >   o alpha
> >   o mips
> >   o openrisc
> >   o sparc64
> 
> The above list seems to be far from complete?

I'll look again. If you know of others lemme know.

  Luis
