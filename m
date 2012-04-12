Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id A09A36B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 14:52:39 -0400 (EDT)
Date: Thu, 12 Apr 2012 13:52:35 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: fix up the vmscan stat in vmstat
In-Reply-To: <1334253782-22755-1-git-send-email-yinghan@google.com>
Message-ID: <alpine.DEB.2.00.1204121348530.7437@router.home>
References: <1334253782-22755-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu, 12 Apr 2012, Ying Han wrote:

> It is always confusing on stat "pgsteal" where it counts both direct
> reclaim as well as background reclaim. However, we have "kswapd_steal"
> which also counts background reclaim value.
>
> This patch fixes it and also makes it match the existng "pgscan_" stats.

It also removes one stat item (kswapd_steal) which strictly speaking is
breaking the system ABI for tools that may rely on those stats. But I
think this is pretty obscure stuff. No major tools would depend on this I
guess.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
