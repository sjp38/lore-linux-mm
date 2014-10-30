Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id B402B90008B
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 21:06:21 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kx10so4315229pab.12
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 18:06:21 -0700 (PDT)
Received: from mail.tuxags.com (hydra.tuxags.com. [64.13.172.54])
        by mx.google.com with ESMTP id fb4si5302502pab.69.2014.10.29.18.06.20
        for <linux-mm@kvack.org>;
        Wed, 29 Oct 2014 18:06:20 -0700 (PDT)
Date: Wed, 29 Oct 2014 18:06:19 -0700
From: Matt Mullins <mmullins@mmlx.us>
Subject: Re: [PATCH] mm/balloon_compaction: fix deflation when compaction
 is disabled
Message-ID: <20141030010618.GE29098@hydra.tuxags.com>
References: <20141028202333.GC29098@hydra.tuxags.com>
 <20141029115107.23071.26065.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141029115107.23071.26065.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Matt Mullins <mmullins@mmlx.us>, linux-kernel@vger.kernel.org, Rafael Aquini <aquini@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, stable@vger.kernel.org

On Wed, Oct 29, 2014 at 02:51:07PM +0400, Konstantin Khlebnikov wrote:
> Fix for commit d6d86c0a7f8ddc5b38cf089222cb1d9540762dc2
> ("mm/balloon_compaction: redesign ballooned pages management").
> 
> If CONFIG_BALLOON_COMPACTION=n balloon_page_insert() does not link
> pages with balloon and doesn't set PagePrivate flag, as a result
> balloon_page_dequeue cannot get any pages because it thinks that
> all of them are isolated. Without balloon compaction nobody can
> isolate ballooned pages, it's safe to remove this check.
> 
> Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> Reported-by: Matt Mullins <mmullins@mmlx.us>
> Cc: Stable <stable@vger.kernel.org>	(v3.17)

That seems to do it, thanks!

Tested-by: Matt Mullins <mmullins@mmlx.us>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
