Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 7DE9F6B002B
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 04:56:26 -0500 (EST)
Date: Tue, 18 Dec 2012 09:56:21 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 1/7] mm: memcg: only evict file pages when we have plenty
Message-ID: <20121218095621.GJ9887@suse.de>
References: <1355767957-4913-1-git-send-email-hannes@cmpxchg.org>
 <1355767957-4913-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1355767957-4913-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Satoru Moriya <satoru.moriya@hds.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 17, 2012 at 01:12:31PM -0500, Johannes Weiner wrote:
> e986850 "mm, vmscan: only evict file pages when we have plenty" makes
> a point of not going for anonymous memory while there is still enough
> inactive cache around.
> 
> The check was added only for global reclaim, but it is just as useful
> to reduce swapping in memory cgroup reclaim:
> 
> 200M-memcg-defconfig-j2
> 
>                                  vanilla                   patched
> Real time              454.06 (  +0.00%)         453.71 (  -0.08%)
> User time              668.57 (  +0.00%)         668.73 (  +0.02%)
> System time            128.92 (  +0.00%)         129.53 (  +0.46%)
> Swap in               1246.80 (  +0.00%)         814.40 ( -34.65%)
> Swap out              1198.90 (  +0.00%)         827.00 ( -30.99%)
> Pages allocated   16431288.10 (  +0.00%)    16434035.30 (  +0.02%)
> Major faults           681.50 (  +0.00%)         593.70 ( -12.86%)
> THP faults             237.20 (  +0.00%)         242.40 (  +2.18%)
> THP collapse           241.20 (  +0.00%)         248.50 (  +3.01%)
> THP splits             157.30 (  +0.00%)         161.40 (  +2.59%)
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.cz>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
