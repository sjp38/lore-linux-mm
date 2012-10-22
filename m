Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id B62B36B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 10:41:38 -0400 (EDT)
Date: Mon, 22 Oct 2012 14:41:37 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm/slob: Mark zone page state to get slab usage at
 /proc/meminfo
In-Reply-To: <1350907434-2202-1-git-send-email-elezegarcia@gmail.com>
Message-ID: <0000013a88ebfa65-af0fc24b-13fd-400f-b7fc-32230ca70620-000000@email.amazonses.com>
References: <1350907434-2202-1-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Bird <tim.bird@am.sony.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Mon, 22 Oct 2012, Ezequiel Garcia wrote:

> On page allocations, SLAB and SLUB modify zone page state counters
> NR_SLAB_UNRECLAIMABLE or NR_SLAB_RECLAIMABLE.
> This allows to obtain slab usage information at /proc/meminfo.
>
> Without this patch, /proc/meminfo will show zero Slab usage for SLOB.
>
> Since SLOB discards SLAB_RECLAIM_ACCOUNT flag, we always use
> NR_SLAB_UNRECLAIMABLE zone state item.

Hmmm... that is unfortunate. The NR_SLAB_RECLAIMABLE stat is used by
reclaim to make decisions on when to reclaim inodes and dentries.

Could you fix that to properly account the reclaimable/unreclaimable
pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
