Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 624976B0037
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 17:19:28 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kq14so6317448pab.20
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 14:19:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id fa10si23582389pab.227.2014.06.23.14.19.27
        for <linux-mm@kvack.org>;
        Mon, 23 Jun 2014 14:19:27 -0700 (PDT)
Date: Mon, 23 Jun 2014 14:19:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2 1/6] mm/zbud: zbud_alloc() minor param change
Message-Id: <20140623141925.47507153d49f22ee5cca62e1@linux-foundation.org>
In-Reply-To: <1401747586-11861-2-git-send-email-ddstreet@ieee.org>
References: <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
	<1401747586-11861-1-git-send-email-ddstreet@ieee.org>
	<1401747586-11861-2-git-send-email-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Mon,  2 Jun 2014 18:19:41 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

> Change zbud to store gfp_t flags passed at pool creation to use for
> each alloc; this allows the api to be closer to the existing zsmalloc
> interface, and the only current zbud user (zswap) uses the same gfp
> flags for all allocs.  Update zswap to use changed interface.

This would appear to be a step backwards.  There's nothing wrong with
requiring all callers to pass in a gfp_t and removing this option makes
the API less usable.

IMO the patch needs much better justification, or dropping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
