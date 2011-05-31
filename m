Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 07CE96B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 00:41:23 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BAAD13EE0BC
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:41:18 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A313745DED8
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:41:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 896FE45DED5
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:41:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 795F31DB803B
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:41:18 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DD1E1DB8042
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:41:18 +0900 (JST)
Date: Tue, 31 May 2011 13:34:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: fix special case -1 order check in compact_finished
Message-Id: <20110531133430.d91aa49d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110530123831.GG20166@tiehlicka.suse.cz>
References: <20110530123831.GG20166@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 30 May 2011 14:38:31 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> 56de7263 (mm: compaction: direct compact when a high-order allocation
> fails) introduced a check for cc->order == -1 in compact_finished. We
> should continue compacting in that case because the request came from
> userspace and there is no particular order to compact for.
> 
> The check is, however, done after zone_watermark_ok which uses order as
> a right hand argument for shifts. Not only watermark check is pointless
> if we can break out without it but it also uses 1 << -1 which is not
> well defined (at least from C standard). Let's move the -1 check above
> zone_watermark_ok.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Cc: Mel Gorman <mgorman@suse.de>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
