Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BC6B18D0039
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 07:11:50 -0500 (EST)
Message-ID: <4D5BBF88.6030103@redhat.com>
Date: Wed, 16 Feb 2011 07:14:00 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: vmscan: Stop reclaim/compaction earlier due to	insufficient
 progress if !__GFP_REPEAT
References: <20110209154606.GJ27110@cmpxchg.org> <20110209164656.GA1063@csn.ul.ie> <20110209182846.GN3347@random.random> <20110210102109.GB17873@csn.ul.ie> <20110210124838.GU3347@random.random> <20110210133323.GH17873@csn.ul.ie> <20110210141447.GW3347@random.random> <20110210145813.GK17873@csn.ul.ie> <20110216095048.GA4473@csn.ul.ie>
In-Reply-To: <20110216095048.GA4473@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.cz>, Kent Overstreet <kent.overstreet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/16/2011 04:50 AM, Mel Gorman wrote:

> This patch will stop reclaim/compaction if no pages were reclaimed in the
> last SWAP_CLUSTER_MAX pages that were considered. For allocations such as
> hugetlbfs that use GFP_REPEAT and have fewer fallback options, the full LRU
> list may still be scanned.

> Signed-off-by: Mel Gorman<mel@csn.ul.ie>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
