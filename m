Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 547ED6B0099
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 17:05:17 -0500 (EST)
Message-ID: <50C8FF3A.5050903@redhat.com>
Date: Wed, 12 Dec 2012 17:03:38 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 4/8] mm: vmscan: clarify LRU balancing close to OOM
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org> <1355348620-9382-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1355348620-9382-5-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/12/2012 04:43 PM, Johannes Weiner wrote:
> There are currently several inter-LRU balancing heuristics that simply
> get disabled when the reclaimer is at the last reclaim cycle before
> giving up, but the code is quite cumbersome and not really obvious.
>
> Make the heuristics visibly unreachable for the last reclaim cycle.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Nice cleanup!

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
