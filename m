Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 5952A6B008A
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 17:02:38 -0500 (EST)
Message-ID: <50C8FE9E.9030203@redhat.com>
Date: Wed, 12 Dec 2012 17:01:02 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 2/8] mm: vmscan: disregard swappiness shortly before going
 OOM
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org> <1355348620-9382-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1355348620-9382-3-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/12/2012 04:43 PM, Johannes Weiner wrote:
> When a reclaim scanner is doing its final scan before giving up and
> there is swap space available, pay no attention to swappiness
> preference anymore.  Just swap.
>
> Note that this change won't make too big of a difference for general
> reclaim: anonymous pages are already force-scanned when there is only
> very little file cache left, and there very likely isn't when the
> reclaimer enters this final cycle.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
