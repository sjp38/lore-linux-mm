Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D6A8D6B0011
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:43:28 -0400 (EDT)
Date: Thu, 12 May 2011 09:43:21 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
In-Reply-To: <1305127773-10570-4-git-send-email-mgorman@suse.de>
Message-ID: <alpine.DEB.2.00.1105120942050.24560@router.home>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de> <1305127773-10570-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Wed, 11 May 2011, Mel Gorman wrote:

> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2198,7 +2198,7 @@ EXPORT_SYMBOL(kmem_cache_free);
>   * take the list_lock.
>   */
>  static int slub_min_order;
> -static int slub_max_order = PAGE_ALLOC_COSTLY_ORDER;
> +static int slub_max_order;

If we really need to do this then do not push this down to zero please.
SLAB uses order 1 for the meax. Lets at least keep it theere.

We have been using SLUB for a long time. Why is this issue arising now?
Due to compaction etc making reclaim less efficient?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
