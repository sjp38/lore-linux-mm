Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A34FE8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 17:52:50 -0400 (EDT)
Date: Tue, 29 Mar 2011 14:52:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V3 1/2] count the soft_limit reclaim in global
 background reclaim
Message-Id: <20110329145237.b5bb7fbf.akpm@linux-foundation.org>
In-Reply-To: <1301378186-23199-2-git-send-email-yinghan@google.com>
References: <1301378186-23199-1-git-send-email-yinghan@google.com>
	<1301378186-23199-2-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Mon, 28 Mar 2011 22:56:25 -0700
Ying Han <yinghan@google.com> wrote:

> @@ -1442,6 +1443,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
>  	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;

This function rather abuses the concept of `bool'.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
