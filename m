Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C90D86B05B9
	for <linux-mm@kvack.org>; Thu, 10 May 2018 02:07:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s3-v6so633845pfh.0
        for <linux-mm@kvack.org>; Wed, 09 May 2018 23:07:50 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b26-v6si44953pff.251.2018.05.09.23.07.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 23:07:49 -0700 (PDT)
Date: Thu, 10 May 2018 08:07:33 +0200
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 0/2] mm: PAGE_KERNEL_* fallbacks
Message-ID: <20180510060733.GA23098@kroah.com>
References: <20180510014447.15989-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180510014447.15989-1-mcgrof@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: arnd@arndb.de, willy@infradead.org, geert@linux-m68k.org, linux-m68k@lists.linux-m68k.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 09, 2018 at 06:44:45PM -0700, Luis R. Rodriguez wrote:
> While dusting out the firmware loader closet I spotted a PAGE_KERNEL_*
> fallback hack. This hurts my eyes, and it should also be blinding
> others. Turns out we have other PAGE_KERNEL_* fallback hacks in
> other places.
> 
> This moves them to asm-generic, and keeps track of architectures which
> need some love or review. At least 0-day was happy with the changes.
> 
> Matthew Wilcox did put together a PAGE_KERNEL_RO patch for ia64, that
> needs review and testing, and if it goes well it should be merged.
> 
> Luis R. Rodriguez (2):
>   mm: provide a fallback for PAGE_KERNEL_RO for architectures
>   mm: provide a fallback for PAGE_KERNEL_EXEC for architectures
> 
>  drivers/base/firmware_loader/fallback.c |  5 ----
>  include/asm-generic/pgtable.h           | 36 +++++++++++++++++++++++++
>  mm/nommu.c                              |  4 ---
>  mm/vmalloc.c                            |  4 ---
>  4 files changed, 36 insertions(+), 13 deletions(-)

No list of changes that happened from v1?  :(
