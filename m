Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 03EB36B0070
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 13:54:33 -0400 (EDT)
Date: Fri, 21 Sep 2012 14:54:24 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 9/9] mm: compaction: Restart compaction from near where
 it left off
Message-ID: <20120921175424.GI6665@optiplex.redhat.com>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
 <1348224383-1499-10-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1348224383-1499-10-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 21, 2012 at 11:46:23AM +0100, Mel Gorman wrote:
> This is almost entirely based on Rik's previous patches and discussions
> with him about how this might be implemented.
> 
> Order > 0 compaction stops when enough free pages of the correct page
> order have been coalesced.  When doing subsequent higher order allocations,
> it is possible for compaction to be invoked many times.
> 
> However, the compaction code always starts out looking for things to compact
> at the start of the zone, and for free pages to compact things to at the
> end of the zone.
> 
> This can cause quadratic behaviour, with isolate_freepages starting at
> the end of the zone each time, even though previous invocations of the
> compaction code already filled up all free memory on that end of the zone.
> This can cause isolate_freepages to take enormous amounts of CPU with
> certain workloads on larger memory systems.
> 
> This patch caches where the migration and free scanner should start from on
> subsequent compaction invocations using the pageblock-skip information. When
> compaction starts it begins from the cached restart points and will
> update the cached restart points until a page is isolated or a pageblock
> is skipped that would have been scanned by synchronous compaction.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---

Acked-by: Rafael Aquini <aquini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
