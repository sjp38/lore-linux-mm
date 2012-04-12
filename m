Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 0AFF86B0044
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 20:04:30 -0400 (EDT)
Date: Thu, 12 Apr 2012 02:04:13 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V2 1/5] memcg: revert current soft limit reclaim
 implementation
Message-ID: <20120412000413.GB1787@cmpxchg.org>
References: <1334181594-26671-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1334181594-26671-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Wed, Apr 11, 2012 at 02:59:54PM -0700, Ying Han wrote:
> This patch reverts all the existing softlimit reclaim implementations.

This ordering makes it quite hard to revert individual patches after
merging in case they are faulty, because we end up with a tree state
that has no soft limit implementation at all, or a newly broken one.

Could you reorder the series such that each patch leaves the tree in a
sane state?

I.e. also don't introduce an endless loop in the page allocator
through one patch and fix it later in another one ;) Noone will be
able to remember these cross-dependencies in a couple of weeks.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
