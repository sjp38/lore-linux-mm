Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 2A8666B004D
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 10:17:36 -0500 (EST)
Date: Fri, 16 Dec 2011 16:17:31 +0100
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH 11/11] mm: Isolate pages for immediate reclaim on their
 own LRU
Message-ID: <20111216151703.GA12817@redhat.com>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
 <1323877293-15401-12-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1323877293-15401-12-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 14, 2011 at 03:41:33PM +0000, Mel Gorman wrote:
> It was observed that scan rates from direct reclaim during tests
> writing to both fast and slow storage were extraordinarily high. The
> problem was that while pages were being marked for immediate reclaim
> when writeback completed, the same pages were being encountered over
> and over again during LRU scanning.
> 
> This patch isolates file-backed pages that are to be reclaimed when
> clean on their own LRU list.

Excuse me if I sound like a broken record, but have those observations
of high scan rates persisted with the per-zone dirty limits patchset?

In my tests with pzd, the scan rates went down considerably together
with the immediate reclaim / vmscan writes.

Our dirty limits are pretty low - if reclaim keeps shuffling through
dirty pages, where are the 80% reclaimable pages?!  To me, this sounds
like the unfair distribution of dirty pages among zones again.  Is
there are a different explanation that I missed?

PS: It also seems a bit out of place in this series...?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
