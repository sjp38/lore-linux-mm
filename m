Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C63CB6B033E
	for <linux-mm@kvack.org>; Wed, 16 May 2018 12:44:07 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 44-v6so1031093wrt.9
        for <linux-mm@kvack.org>; Wed, 16 May 2018 09:44:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k13-v6si1528523edl.323.2018.05.16.09.44.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 May 2018 09:44:05 -0700 (PDT)
Date: Wed, 16 May 2018 18:44:03 +0200
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH v3 0/2] mm: PAGE_KERNEL_* fallbacks
Message-ID: <20180516164403.GI27853@wotan.suse.de>
References: <20180510185507.2439-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180510185507.2439-1-mcgrof@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arnd@arndb.de, gregkh@linuxfoundation.org, willy@infradead.org
Cc: mcgrof@kernel.org, geert@linux-m68k.org, linux-m68k@lists.linux-m68k.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, May 10, 2018 at 11:55:05AM -0700, Luis R. Rodriguez wrote:
> This is the 3rd iteration for moving PAGE_KERNEL_* fallback
> definitions into asm-generic headers. Greg asked for a Changelog
> for patch iteration changes, its below.
> 
> All these patches have been tested by 0-day.
> 
> Questions, and specially flames are greatly appreciated.

*Poke*

Who's tree should this go through?

  Luis

> 
> v3:
> 
> Removed documentation effort to keep tabs on which architectures
> currently don't defint the respective PAGE_* flags. Keeping tabs
> on this is just not worth it.
> 
> Ran a spell checker on all patches :)
> 
> v2:
> 
> I added a patch for PAGE_KERNEL_EXEC as suggested by Matthew Wilcox.
> 
> v1:
> 
> I sent out a patch just for dealing witht he fallback mechanism for
> PAGE_KERNEL_RO.
> 
> Luis R. Rodriguez (2):
>   mm: provide a fallback for PAGE_KERNEL_RO for architectures
>   mm: provide a fallback for PAGE_KERNEL_EXEC for architectures
> 
>  drivers/base/firmware_loader/fallback.c |  5 -----
>  include/asm-generic/pgtable.h           | 18 ++++++++++++++++++
>  mm/nommu.c                              |  4 ----
>  mm/vmalloc.c                            |  4 ----
>  4 files changed, 18 insertions(+), 13 deletions(-)
> 
> -- 
> 2.17.0
> 
> 

-- 
Do not panic
