Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 28176900138
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 21:20:15 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4EDBC3EE0C0
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:20:10 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B79F45DE55
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:20:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 112B145DE4D
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:20:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E937B1DB8042
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:20:09 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A48581DB803B
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:20:09 +0900 (JST)
Date: Wed, 17 Aug 2011 10:12:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 2/2] mm: vmscan: drop nr_force_scan[] from
 get_scan_count
Message-Id: <20110817101249.03963ae4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1313094715-31187-2-git-send-email-jweiner@redhat.com>
References: <1313094715-31187-1-git-send-email-jweiner@redhat.com>
	<1313094715-31187-2-git-send-email-jweiner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Mel Gorman <mel@csn.ul.ie>

On Thu, 11 Aug 2011 22:31:55 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> The nr_force_scan[] tuple holds the effective scan numbers for anon
> and file pages in case the situation called for a forced scan and the
> regularly calculated scan numbers turned out zero.
> 
> However, the effective scan number can always be assumed to be
> SWAP_CLUSTER_MAX right before the division into anon and file.  The
> numerators and denominator are properly set up for all cases, be it
> force scan for just file, just anon, or both, to do the right thing.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Ying Han <yinghan@google.com>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: Mel Gorman <mel@csn.ul.ie>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
