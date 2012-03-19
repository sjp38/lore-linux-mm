Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 7ADE66B007E
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 13:41:01 -0400 (EDT)
Message-ID: <4F676FA4.50905@redhat.com>
Date: Mon, 19 Mar 2012 13:40:52 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: forbid lumpy-reclaim in shrink_active_list()
References: <20120319091821.17716.54031.stgit@zurg>
In-Reply-To: <20120319091821.17716.54031.stgit@zurg>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 03/19/2012 05:18 AM, Konstantin Khlebnikov wrote:
> This patch reset reclaim mode in shrink_active_list() to RECLAIM_MODE_SINGLE | RECLAIM_MODE_ASYNC.
> (sync/async sign is used only in shrink_page_list and does not affect shrink_active_list)
>
> Currenly shrink_active_list() sometimes works in lumpy-reclaim mode,
> if RECLAIM_MODE_LUMPYRECLAIM left over from earlier shrink_inactive_list().
> Meanwhile, in age_active_anon() sc->reclaim_mode is totally zero.
> So, current behavior is too complex and confusing, all this looks like bug.
>
> In general, shrink_active_list() populate inactive list for next shrink_inactive_list().
> Lumpy shring_inactive_list() isolate pages around choosen one from both active and
> inactive lists. So, there no reasons for lumpy-isolation in shrink_active_list()
>
> Proposed-by: Hugh Dickins<hughd@google.com>
> Link: https://lkml.org/lkml/2012/3/15/583
> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>

Confirmed, this is already done by commit
26f5f2f1aea7687565f55c20d69f0f91aa644fb8 in the
linux-next tree.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
