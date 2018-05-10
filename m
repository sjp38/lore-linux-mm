Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AC3FE6B05A8
	for <linux-mm@kvack.org>; Wed,  9 May 2018 21:24:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g1-v6so275245pfh.19
        for <linux-mm@kvack.org>; Wed, 09 May 2018 18:24:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n6si22621111pfi.360.2018.05.09.18.24.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 18:24:30 -0700 (PDT)
Date: Thu, 10 May 2018 01:24:26 +0000
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH] mm: provide a fallback for PAGE_KERNEL_RO for
 architectures
Message-ID: <20180510012426.GA27853@wotan.suse.de>
References: <20180428001526.22475-1-mcgrof@kernel.org>
 <CAMuHMdUpc6=j62E7Xrcid6tKU5FRUZsiSVK7J=KD09epQ=9xfA@mail.gmail.com>
 <20180502151113.GB27853@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180502151113.GB27853@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, Matthew Wilcox <mawilcox@microsoft.com>, Greg KH <gregkh@linuxfoundation.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>

On Wed, May 02, 2018 at 03:11:13PM +0000, Luis R. Rodriguez wrote:
> On Wed, May 02, 2018 at 12:08:57PM +0200, Geert Uytterhoeven wrote:
> > Hi Luis,
> > 
> > On Sat, Apr 28, 2018 at 2:15 AM, Luis R. Rodriguez <mcgrof@kernel.org> wrote:
> > > Some architectures do not define PAGE_KERNEL_RO, best we can do
> > > for them is to provide a fallback onto PAGE_KERNEL. Remove the
> > > hack from the firmware loader and move it onto the asm-generic
> > > header, and document while at it the affected architectures
> > > which do not have a PAGE_KERNEL_RO:
> > >
> > >   o alpha
> > >   o ia64
> > >   o m68k
> > >   o mips
> > >   o sparc64
> > >   o sparc
> > >
> > > Blessed-by: 0-day
> > > Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
> > 
> > I believe the "best we can do" is to add the missing definitions for the
> > architectures where the hardware does support it?
> 
> True, but we cannot wait for every architecture to implement a feature to then
> such generics upstream, 

Come to think of it your point was the wording. I changed it to not be as misleading.

  Luis
