Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0F6926B0027
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:04:56 -0400 (EDT)
Message-ID: <4DCC051E.4000206@redhat.com>
Date: Thu, 12 May 2011 12:04:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [rfc patch 3/6] mm: memcg-aware global reclaim
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org> <1305212038-15445-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1305212038-15445-4-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/12/2011 10:53 AM, Johannes Weiner wrote:

> I am open to solutions that trade fairness against CPU-time but don't
> want to have an extreme in either direction.  Maybe break out early if
> a number of memcgs has been successfully reclaimed from and remember
> the last one scanned.

The way we used to deal with this when we did per-process
virtual scanning (before rmap), was to scan the process at
the head of the list.

After we were done with that process, it got moved to the
back of the list.  If enough had been scanned, we bailed
out of the scanning code alltogether; if more needed to
be scanned, we moved on to the next process.

Doing a list move after scanning a bunch of pages in the
LRU lists of a cgroup isn't nearly as expensive as having
to scan all the cgroups.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
