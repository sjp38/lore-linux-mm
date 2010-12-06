Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E6F7F6B0087
	for <linux-mm@kvack.org>; Sun,  5 Dec 2010 22:25:37 -0500 (EST)
Message-ID: <4CFC578B.9090904@redhat.com>
Date: Sun, 05 Dec 2010 22:24:59 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 5/7] add profile information for invalidated page reclaim
References: <cover.1291568905.git.minchan.kim@gmail.com> <dff7a42e5877b23a3cc3355743da4b7ef37299f8.1291568905.git.minchan.kim@gmail.com>
In-Reply-To: <dff7a42e5877b23a3cc3355743da4b7ef37299f8.1291568905.git.minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On 12/05/2010 12:29 PM, Minchan Kim wrote:
> This patch adds profile information about invalidated page reclaim.
> It's just for profiling for test so it would be discard when the series
> are merged.
>
> Signed-off-by: Minchan Kim<minchan.kim@gmail.com>
> Cc: Rik van Riel<riel@redhat.com>
> Cc: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Cc: Wu Fengguang<fengguang.wu@intel.com>
> Cc: Johannes Weiner<hannes@cmpxchg.org>
> Cc: Nick Piggin<npiggin@kernel.dk>
> Cc: Mel Gorman<mel@csn.ul.ie>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
