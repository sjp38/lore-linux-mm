Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 2E7DC6B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 01:50:57 -0400 (EDT)
Date: Tue, 6 Aug 2013 07:50:40 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/9] mm: zone_reclaim: compaction: scan all memory with
 /proc/sys/vm/compact_memory
Message-ID: <20130806055040.GD15161@redhat.com>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-3-git-send-email-aarcange@redhat.com>
 <20130805184559.GB1845@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130805184559.GB1845@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

Hi!

On Mon, Aug 05, 2013 at 02:45:59PM -0400, Johannes Weiner wrote:
> On Fri, Aug 02, 2013 at 06:06:29PM +0200, Andrea Arcangeli wrote:
> > Reset the stats so /proc/sys/vm/compact_memory will scan all memory.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > Reviewed-by: Rik van Riel <riel@redhat.com>
> > Acked-by: Rafael Aquini <aquini@redhat.com>
> > Acked-by: Mel Gorman <mgorman@suse.de>
> 
> It somehow feels wrong that this operation should have a destructive
> side effect, rather than just ignore the cached info for the one run
> (like cc.ignore_skip_hint).  But I don't really have a strong reason
> against it, so...

But what benefit would provide to keep the cached cursor positions
alive after we already compacted the whole memory from the start to
the end? The cached cursors provide useful information when we compact
in small steps and they represent the unscanned part of the
memory. But after a full compaction completed unless some memory
activity has happened there will be nothing to compact anymore. So we
just need to find what may have changed as result of the memory
activity and in turn there should be no benefit in starting at the
previously cached cursors positions.

> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
