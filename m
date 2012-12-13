Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 1CB636B0068
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 05:46:05 -0500 (EST)
Date: Thu, 13 Dec 2012 10:46:00 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 4/8] mm: vmscan: clarify LRU balancing close to OOM
Message-ID: <20121213104600.GY1009@suse.de>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
 <1355348620-9382-5-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1355348620-9382-5-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 12, 2012 at 04:43:36PM -0500, Johannes Weiner wrote:
> There are currently several inter-LRU balancing heuristics that simply
> get disabled when the reclaimer is at the last reclaim cycle before
> giving up, but the code is quite cumbersome and not really obvious.
> 
> Make the heuristics visibly unreachable for the last reclaim cycle.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
