Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2D8E36B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 09:06:43 -0400 (EDT)
Date: Thu, 1 Sep 2011 14:05:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/3] Correct isolate_mode_t bitwise type
Message-ID: <20110901130542.GG14369@suse.de>
References: <cover.1321112552.git.minchan.kim@gmail.com>
 <e139175e938d94c0c977edd05ae07cbad7a72cc5.1321112552.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <e139175e938d94c0c977edd05ae07cbad7a72cc5.1321112552.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>

On Sun, Nov 13, 2011 at 01:37:41AM +0900, Minchan Kim wrote:
> [c1e8b0ae8, mm-change-isolate-mode-from-define-to-bitwise-type]
> made a mistake on the bitwise type.
> 

Minor nit, commit c1e8b0ae8 does not exist anywhere. I suspect you
are looking at a git tree generated from the mmotm quilt series. It
would be easier if you had said "This patch should be merged with
mm-change-isolate-mode-from-define-to-bitwise-type.patch in mmotm".

Otherwise, looks ok.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
