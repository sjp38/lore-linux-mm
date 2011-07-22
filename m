Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8DA636B004A
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 08:57:26 -0400 (EDT)
Subject: Re: [PATCH 8/8] mm: vmscan: Do not writeback filesystem pages from
 kswapd
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1311265730-5324-9-git-send-email-mgorman@suse.de>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
	 <1311265730-5324-9-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 22 Jul 2011 14:57:12 +0200
Message-ID: <1311339432.27400.36.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, 2011-07-21 at 17:28 +0100, Mel Gorman wrote:
> Assuming that flusher threads will always write back dirty pages promptly
> then it is always faster for reclaimers to wait for flushers. This patch
> prevents kswapd writing back any filesystem pages.=20

That is a somewhat sort changelog for such a big assumption ;-)

I think it can use a few extra words to explain the need to clean pages
from @zone vs writeback picks whatever fits best on disk and how that
works out wrt the assumption.

What requirements does this place on writeback and how does it meet
them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
