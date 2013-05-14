Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 5794E6B0033
	for <linux-mm@kvack.org>; Tue, 14 May 2013 13:34:45 -0400 (EDT)
Message-ID: <51927531.8010507@redhat.com>
Date: Tue, 14 May 2013 13:32:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 4/4] mm: free reclaimed pages instantly without depending
 next reclaim
References: <1368411048-3753-1-git-send-email-minchan@kernel.org> <1368411048-3753-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1368411048-3753-5-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>

On 05/12/2013 10:10 PM, Minchan Kim wrote:
> Normally, file I/O for reclaiming is asynchronous so that
> when page writeback is completed, reclaimed page will be
> rotated into LRU tail for fast reclaiming in next turn.
> But it makes unnecessary CPU overhead and more iteration with higher
> priority of reclaim could reclaim too many pages than needed
> pages.
>
> This patch frees reclaimed pages by paging out instantly without
> rotating back them into LRU's tail when the I/O is completed so
> that we can get out of reclaim loop as soon as poosbile and avoid
> unnecessary CPU overhead for moving them.
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

I like this approach and am looking forward to your v2 series,
with the reworked patch 3/4.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
