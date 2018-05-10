Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B683F6B0630
	for <linux-mm@kvack.org>; Thu, 10 May 2018 13:15:23 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 3-v6so1861734wry.0
        for <linux-mm@kvack.org>; Thu, 10 May 2018 10:15:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i10-v6si1026351edb.233.2018.05.10.10.15.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 May 2018 10:15:21 -0700 (PDT)
Date: Thu, 10 May 2018 17:15:20 +0000
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH v2 0/2] mm: PAGE_KERNEL_* fallbacks
Message-ID: <20180510171520.GD27853@wotan.suse.de>
References: <20180510014447.15989-1-mcgrof@kernel.org>
 <20180510060733.GA23098@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180510060733.GA23098@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, arnd@arndb.de, willy@infradead.org, geert@linux-m68k.org, linux-m68k@lists.linux-m68k.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, May 10, 2018 at 08:07:33AM +0200, Greg KH wrote:
> On Wed, May 09, 2018 at 06:44:45PM -0700, Luis R. Rodriguez wrote:
> > While dusting out the firmware loader closet I spotted a PAGE_KERNEL_*
> > fallback hack. This hurts my eyes, and it should also be blinding
> > others. Turns out we have other PAGE_KERNEL_* fallback hacks in
> > other places.
> > 
> > This moves them to asm-generic, and keeps track of architectures which
> > need some love or review. At least 0-day was happy with the changes.
> > 
> > Matthew Wilcox did put together a PAGE_KERNEL_RO patch for ia64, that
> > needs review and testing, and if it goes well it should be merged.
> > 
> > Luis R. Rodriguez (2):
> >   mm: provide a fallback for PAGE_KERNEL_RO for architectures
> >   mm: provide a fallback for PAGE_KERNEL_EXEC for architectures
> > 
> >  drivers/base/firmware_loader/fallback.c |  5 ----
> >  include/asm-generic/pgtable.h           | 36 +++++++++++++++++++++++++
> >  mm/nommu.c                              |  4 ---
> >  mm/vmalloc.c                            |  4 ---
> >  4 files changed, 36 insertions(+), 13 deletions(-)
> 
> No list of changes that happened from v1?  :(

Didn't know you'd want it for such simple patch set, but I'll provide one for v3 and
also list the changes in v2.

  Luis
