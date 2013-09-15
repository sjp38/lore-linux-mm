Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 5A9D66B0083
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 13:03:55 -0400 (EDT)
Date: Sun, 15 Sep 2013 13:03:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] Have __free_pages_memory() free in larger chunks.
Message-ID: <20130915170339.GA3278@cmpxchg.org>
References: <1378839444-196190-1-git-send-email-nzimmer@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1378839444-196190-1-git-send-email-nzimmer@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: mingo@kernel.org, hpa@zytor.com, Robin Holt <robin.m.holt@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>

On Tue, Sep 10, 2013 at 01:57:24PM -0500, Nathan Zimmer wrote:
> From: Robin Holt <robin.m.holt@gmail.com>
> 
> On large memory machines it can take a few minutes to get through
> free_all_bootmem().
> 
> Currently, when free_all_bootmem() calls __free_pages_memory(), the
> number of contiguous pages that __free_pages_memory() passes to the
> buddy allocator is limited to BITS_PER_LONG.  BITS_PER_LONG was originally
> chosen to keep things similar to mm/nobootmem.c.  But it is more
> efficient to limit it to MAX_ORDER.
> 
>        base   new  change
> 8TB    202s  172s   30s
> 16TB   401s  351s   50s
> 
> That is around 1%-3% improvement on total boot time.
> 
> This patch was spun off from the boot time rfc Robin and I had been
> working on.
> 
> Signed-off-by: Robin Holt <robin.m.holt@gmail.com>
> Signed-off-by: Nathan Zimmer <nzimmer@sgi.com>
> To: "H. Peter Anvin" <hpa@zytor.com>
> To: Ingo Molnar <mingo@kernel.org>
> Cc: Linux Kernel <linux-kernel@vger.kernel.org>
> Cc: Linux MM <linux-mm@kvack.org>
> Cc: Rob Landley <rob@landley.net>
> Cc: Mike Travis <travis@sgi.com>
> Cc: Daniel J Blueman <daniel@numascale-asia.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Greg KH <gregkh@linuxfoundation.org>
> Cc: Yinghai Lu <yinghai@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
