Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 080FB6B007E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 19:17:31 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a69so72719995pfa.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:17:30 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id m1si16217662pam.102.2016.06.15.16.17.29
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 16:17:30 -0700 (PDT)
Date: Thu, 16 Jun 2016 08:17:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: update zram to use zpool
Message-ID: <20160615231732.GJ17127@bbox>
References: <cover.1466000844.git.geliangtang@gmail.com>
 <efcf047e747d9d1e80af16ebfc51ea1964a7a621.1466000844.git.geliangtang@gmail.com>
MIME-Version: 1.0
In-Reply-To: <efcf047e747d9d1e80af16ebfc51ea1964a7a621.1466000844.git.geliangtang@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Vitaly Wool <vitalywool@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 15, 2016 at 10:42:07PM +0800, Geliang Tang wrote:
> Change zram to use the zpool api instead of directly using zsmalloc.
> The zpool api doesn't have zs_compact() and zs_pool_stats() functions.
> I did the following two things to fix it.
> 1) I replace zs_compact() with zpool_shrink(), use zpool_shrink() to
>    call zs_compact() in zsmalloc.
> 2) The 'pages_compacted' attribute is showed in zram by calling
>    zs_pool_stats(). So in order not to call zs_pool_state() I move the
>    attribute to zsmalloc.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

NACK.

I already explained why.
http://lkml.kernel.org/r/20160609013411.GA29779@bbox

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
