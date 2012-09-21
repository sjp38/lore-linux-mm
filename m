Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id D5D756B0044
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 13:50:36 -0400 (EDT)
Date: Fri, 21 Sep 2012 14:50:27 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 4/9] mm: compaction: Abort compaction loop if lock is
 contended or run too long
Message-ID: <20120921175026.GD6665@optiplex.redhat.com>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
 <1348224383-1499-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1348224383-1499-5-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 21, 2012 at 11:46:18AM +0100, Mel Gorman wrote:
> From: Shaohua Li <shli@fusionio.com>
> 
> Changelog since V2
> o Fix BUG_ON triggered due to pages left on cc.migratepages
> o Make compact_zone_order() require non-NULL arg `contended'
> 
> Changelog since V1
> o only abort the compaction if lock is contended or run too long
> o Rearranged the code by Andrea Arcangeli.
> 
> isolate_migratepages_range() might isolate no pages if for example when
> zone->lru_lock is contended and running asynchronous compaction. In this
> case, we should abort compaction, otherwise, compact_zone will run a
> useless loop and make zone->lru_lock is even contended.
> 
> [minchan@kernel.org: Putback pages isolated for migration if aborting]
> [akpm@linux-foundation.org: compact_zone_order requires non-NULL arg contended]
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Shaohua Li <shli@fusionio.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---

Acked-by: Rafael Aquini <aquini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
