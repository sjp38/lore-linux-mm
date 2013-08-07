Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id C4A536B009B
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 11:53:47 -0400 (EDT)
Date: Wed, 7 Aug 2013 16:53:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 8/9] mm: zone_reclaim: after a successful zone_reclaim
 check the min watermark
Message-ID: <20130807155342.GV2296@suse.de>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-9-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1375459596-30061-9-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On Fri, Aug 02, 2013 at 06:06:35PM +0200, Andrea Arcangeli wrote:
> If we're in the fast path and we succeeded zone_reclaim(), it means we
> freed enough memory and we can use the min watermark to have some
> margin against concurrent allocations from other CPUs or interrupts.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

This seems very light on explanation. The fast path is meant to obey the
low watermark and wake up kswapd in the slow path if the watermark cannot
be obeyed. This patch appears to allow a kswapd wakeup to be missed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
