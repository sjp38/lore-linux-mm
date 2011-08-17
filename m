Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3F5900138
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 21:19:34 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AC77A3EE0C0
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:19:31 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A74E45DE4E
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:19:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DAB045DE54
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:19:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 601741DB8041
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:19:31 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 27B471DB803B
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:19:31 +0900 (JST)
Date: Wed, 17 Aug 2011 10:12:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 1/2] mm: vmscan: fix force-scanning small targets
 without swap
Message-Id: <20110817101208.c8bbed4a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1313094715-31187-1-git-send-email-jweiner@redhat.com>
References: <1313094715-31187-1-git-send-email-jweiner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Mel Gorman <mel@csn.ul.ie>

On Thu, 11 Aug 2011 22:31:54 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> Without swap, anonymous pages are not scanned.  As such, they should
> not count when considering force-scanning a small target if there is
> no swap.
> 
> Otherwise, targets are not force-scanned even when their effective
> scan number is zero and the other conditions--kswapd/memcg--apply.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Ying Han <yinghan@google.com>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: Mel Gorman <mel@csn.ul.ie>

Thanks,
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
