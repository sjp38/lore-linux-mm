Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 17A0F6B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 03:46:55 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so100407742pac.2
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 00:46:54 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id qj6si3768528pbb.45.2015.09.25.00.46.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 00:46:54 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so100407457pac.2
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 00:46:54 -0700 (PDT)
Date: Fri, 25 Sep 2015 16:48:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3] zbud: allow up to PAGE_SIZE allocations
Message-ID: <20150925074832.GA24205@bbox>
References: <20150925075753.90ff10d13070717e3a6b10ca@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150925075753.90ff10d13070717e3a6b10ca@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, Sep 25, 2015 at 07:57:53AM +0200, Vitaly Wool wrote:
> From e219a88f4cd68842e7e04e37461aba6e06555d6a Mon Sep 17 00:00:00 2001
> From: Vitaly Vul <vitaly.vul@sonymobile.com>
> Date: Tue, 22 Sep 2015 14:07:01 +0200
> Subject: [PATCH] zbud: allow up to PAGE_SIZE allocations
> 
> Currently zbud is only capable of allocating not more than
> PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE. This is okay as
> long as only zswap is using it, but other users of zbud may
> (and likely will) want to allocate up to PAGE_SIZE. This patch
> addresses that by skipping the creation of zbud internal
> structure in the beginning of an allocated page. As a zbud page
> is no longer guaranteed to contain zbud header, the following
> changes have to be applied throughout the code:
> * page->lru to be used for zbud page lists
> * page->private to hold 'under_reclaim' flag
> 
> page->private will also be used to indicate if this page contains
> a zbud header in the beginning or not ('headless' flag).
> 
> This patch incorporates minor fixups after Seth's comments.
> 
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

In previous thread, I saw this patch is part of "support zbud into zram"
and commented out several times but have been ignored.
So, what I can do is just

Nacked-by: Minchan Kim <minchan@kernel.org>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
