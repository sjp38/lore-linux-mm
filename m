Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA61C6B0038
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 12:01:13 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j65so203180350iof.1
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 09:01:13 -0800 (PST)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id y82si11167107ioi.164.2016.12.05.09.01.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 09:01:12 -0800 (PST)
Received: by mail-io0-x243.google.com with SMTP id h133so15613654ioe.2
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 09:01:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161129182010.13445.31256.stgit@localhost.localdomain>
References: <20161129182010.13445.31256.stgit@localhost.localdomain>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 5 Dec 2016 09:01:12 -0800
Message-ID: <CAKgT0UchMkvsboO23R332j96=yumL7=oSSm97zqJ5-v30_SgCw@mail.gmail.com>
Subject: Re: [mm PATCH 0/3] Page fragment updates
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>, David Miller <davem@davemloft.net>, Jeff Kirsher <jeffrey.t.kirsher@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Nov 29, 2016 at 10:23 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> This patch series takes care of a few cleanups for the page fragments API.
>
> First we do some renames so that things are much more consistent.  First we
> move the page_frag_ portion of the name to the front of the functions
> names.  Secondly we split out the cache specific functions from the other
> page fragment functions by adding the word "cache" to the name.
>
> Second I did some minor clean-up on the function calls so that they are
> more inline with the existing __free_pages calls in terms of how they
> operate.
>
> Finally I added a bit of documentation that will hopefully help to explain
> some of this.  I plan to revisit this later as we get things more ironed
> out in the near future with the changes planned for the DMA setup to
> support eXpress Data Path.
>
> ---
>
> Alexander Duyck (3):
>       mm: Rename __alloc_page_frag to page_frag_alloc and __free_page_frag to page_frag_free
>       mm: Rename __page_frag functions to __page_frag_cache, drop order from drain
>       mm: Add documentation for page fragment APIs
>
>
>  Documentation/vm/page_frags               |   42 +++++++++++++++++++++++++++++
>  drivers/net/ethernet/intel/igb/igb_main.c |    6 ++--
>  include/linux/gfp.h                       |    9 +++---
>  include/linux/skbuff.h                    |    2 +
>  mm/page_alloc.c                           |   33 +++++++++++++----------
>  net/core/skbuff.c                         |    8 +++---
>  6 files changed, 73 insertions(+), 27 deletions(-)
>  create mode 100644 Documentation/vm/page_frags
>
> --

It's been about a week since I submitted this series.  Just wanted to
check in and see if anyone had any feedback or if this is good to be
accepted for 4.10-rc1 with the rest of the set?

Thanks.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
