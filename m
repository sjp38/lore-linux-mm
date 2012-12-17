Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 4583B6B0087
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 13:16:53 -0500 (EST)
Message-ID: <50CF618C.6020100@redhat.com>
Date: Mon, 17 Dec 2012 13:16:44 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 3/7] mm: vmscan: clarify how swappiness, highest priority,
 memcg interact
References: <1355767957-4913-1-git-send-email-hannes@cmpxchg.org> <1355767957-4913-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1355767957-4913-4-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Satoru Moriya <satoru.moriya@hds.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/17/2012 01:12 PM, Johannes Weiner wrote:
> A swappiness of 0 has a slightly different meaning for global reclaim
> (may swap if file cache really low) and memory cgroup reclaim (never
> swap, ever).
>
> In addition, global reclaim at highest priority will scan all LRU
> lists equal to their size and ignore other balancing heuristics.
> UNLESS swappiness forbids swapping, then the lists are balanced based
> on recent reclaim effectiveness.  UNLESS file cache is running low,
> then anonymous pages are force-scanned.
>
> This (total mess of a) behaviour is implicit and not obvious from the
> way the code is organized.  At least make it apparent in the code flow
> and document the conditions.  It will be it easier to come up with
> sane semantics later.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
