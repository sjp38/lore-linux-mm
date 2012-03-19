Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id E6F566B007E
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 10:35:27 -0400 (EDT)
Date: Mon, 19 Mar 2012 15:35:19 +0100
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] mm: forbid lumpy-reclaim in shrink_active_list()
Message-ID: <20120319143519.GD1699@redhat.com>
References: <20120319091821.17716.54031.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120319091821.17716.54031.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Mar 19, 2012 at 01:18:21PM +0400, Konstantin Khlebnikov wrote:
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
> Proposed-by: Hugh Dickins <hughd@google.com>
> Link: https://lkml.org/lkml/2012/3/15/583
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
