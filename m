Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 6A3E76B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 14:46:04 -0400 (EDT)
Date: Mon, 5 Aug 2013 14:45:59 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/9] mm: zone_reclaim: compaction: scan all memory with
 /proc/sys/vm/compact_memory
Message-ID: <20130805184559.GB1845@cmpxchg.org>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-3-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375459596-30061-3-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On Fri, Aug 02, 2013 at 06:06:29PM +0200, Andrea Arcangeli wrote:
> Reset the stats so /proc/sys/vm/compact_memory will scan all memory.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Acked-by: Rafael Aquini <aquini@redhat.com>
> Acked-by: Mel Gorman <mgorman@suse.de>

It somehow feels wrong that this operation should have a destructive
side effect, rather than just ignore the cached info for the one run
(like cc.ignore_skip_hint).  But I don't really have a strong reason
against it, so...

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
