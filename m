Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id A027A6B009F
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 17:33:16 -0500 (EST)
Message-ID: <50C905CE.1010405@redhat.com>
Date: Wed, 12 Dec 2012 17:31:42 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 7/8] mm: vmscan: compaction works against zones, not lruvecs
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org> <1355348620-9382-8-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1355348620-9382-8-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/12/2012 04:43 PM, Johannes Weiner wrote:
> The restart logic for when reclaim operates back to back with
> compaction is currently applied on the lruvec level.  But this does
> not make sense, because the container of interest for compaction is a
> zone as a whole, not the zone pages that are part of a certain memory
> cgroup.
>
> Negative impact is bounded.  For one, the code checks that the lruvec
> has enough reclaim candidates, so it does not risk getting stuck on a
> condition that can not be fulfilled.  And the unfairness of hammering
> on one particular memory cgroup to make progress in a zone will be
> amortized by the round robin manner in which reclaim goes through the
> memory cgroups.  Still, this can lead to unnecessary allocation
> latencies when the code elects to restart on a hard to reclaim or
> small group when there are other, more reclaimable groups in the zone.
>
> Move this logic to the zone level and restart reclaim for all memory
> cgroups in a zone when compaction requires more free pages from it.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
