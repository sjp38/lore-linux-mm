Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 960ED6B0087
	for <linux-mm@kvack.org>; Sun,  5 Dec 2010 22:26:28 -0500 (EST)
Message-ID: <4CFC57BF.6000903@redhat.com>
Date: Sun, 05 Dec 2010 22:25:51 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 6/7] Remove zap_details NULL dependency
References: <cover.1291568905.git.minchan.kim@gmail.com> <807118ceb3beeccdd69dda8228229e37b49d9803.1291568905.git.minchan.kim@gmail.com>
In-Reply-To: <807118ceb3beeccdd69dda8228229e37b49d9803.1291568905.git.minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On 12/05/2010 12:29 PM, Minchan Kim wrote:
> Some functions used zap_details depends on assumption that
> zap_details parameter should be NULLed if some fields are 0.
>
> This patch removes that dependency for next patch easy review/merge.
> It should not chanage behavior.
>
> Signed-off-by: Minchan Kim<minchan.kim@gmail.com>
> Cc: Rik van Riel<riel@redhat.com>
> Cc: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner<hannes@cmpxchg.org>
> Cc: Nick Piggin<npiggin@kernel.dk>
> Cc: Mel Gorman<mel@csn.ul.ie>
> Cc: Wu Fengguang<fengguang.wu@intel.com>
> Cc: Hugh Dickins<hughd@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
