Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 114D06B0038
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 08:14:52 -0400 (EDT)
Received: by oibi136 with SMTP id i136so41551996oib.3
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 05:14:51 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id gd1si55032obb.4.2015.09.11.05.14.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Sep 2015 05:14:51 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so73872083pad.1
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 05:14:50 -0700 (PDT)
Date: Fri, 11 Sep 2015 21:13:43 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH 0/2] mm:constify zpool/zs_pool char members
Message-ID: <20150911121343.GA521@swordfish>
References: <1441885718-32580-1-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1441885718-32580-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (09/10/15 20:48), Sergey Senozhatsky wrote:
> Two trivial patches to constify zs_pool and zpool ->name and ->type
> members and functions' signatures that set/return them.
> 

oh.. um.. somehow linux-next 20150910 contained zpool_has_pool()
function, which I can't find any more. I'll resend the patch set.

	-ss

> Sergey SENOZHATSKY (2):
>   mm:zpool: constify struct zpool type
>   mm:zsmalloc: constify struct zs_pool name
> 
>  include/linux/zpool.h    | 12 +++++++-----
>  include/linux/zsmalloc.h |  2 +-
>  mm/zbud.c                |  2 +-
>  mm/zpool.c               | 12 ++++++------
>  mm/zsmalloc.c            | 10 +++++-----
>  5 files changed, 20 insertions(+), 18 deletions(-)
> 
> -- 
> 2.5.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
