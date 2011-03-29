Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7F42F8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 03:05:31 -0400 (EDT)
Date: Tue, 29 Mar 2011 15:55:10 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH V3 1/2] count the soft_limit reclaim in global
 background reclaim
Message-Id: <20110329155510.28c2683d.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <1301378186-23199-2-git-send-email-yinghan@google.com>
References: <1301378186-23199-1-git-send-email-yinghan@google.com>
	<1301378186-23199-2-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Mon, 28 Mar 2011 22:56:25 -0700
Ying Han <yinghan@google.com> wrote:

> In the global background reclaim, we do soft reclaim before scanning the
> per-zone LRU. However, the return value is ignored.
> 
> We would like to skip shrink_zone() if soft_limit reclaim does enough work.
> Also, we need to make the memory pressure balanced across per-memcg zones,
> like the logic vm-core. This patch is the first step where we start with
> counting the nr_scanned and nr_reclaimed from soft_limit reclaim into the
> global scan_control.
> 
> No change from V2.
> 
I think you can add KAMEZAWA-san's and KOSAKI-san's signatures which are sent to v2.
And here is mine:

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
