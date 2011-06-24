Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 38475900234
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 09:59:43 -0400 (EDT)
Date: Fri, 24 Jun 2011 14:59:37 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/4] mm: vmscan: Do not apply pressure to slab if we are
 not applying pressure to zone
Message-ID: <20110624135937.GR9396@suse.de>
References: <1308922998-15529-1-git-send-email-mgorman@suse.de>
 <1308922998-15529-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1308922998-15529-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: P?draig Brady <P@draigBrady.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Lutomirski <luto@mit.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Jun 24, 2011 at 02:43:16PM +0100, Mel Gorman wrote:
> During allocator-intensive workloads, kswapd will be woken frequently
> causing free memory to oscillate between the high and min watermark.
> This is expected behaviour.
> 

Bah, I accidentally exported a branch with a build error in this
patch. Will resend shortly.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
