Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 89D6D6B0022
	for <linux-mm@kvack.org>; Fri, 13 May 2011 00:19:52 -0400 (EDT)
Date: Fri, 13 May 2011 13:15:14 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH][BUGFIX] memcg fix zone congestion
Message-Id: <20110513131514.a7ec1328.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110513121030.08fcae08.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110513121030.08fcae08.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Fri, 13 May 2011 12:10:30 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> ZONE_CONGESTED should be a state of global memory reclaim.
> If not, a busy memcg sets this and give unnecessary throttoling in
> wait_iff_congested() against memory recalim in other contexts. This makes
> system performance bad.
> 
hmm, nice catch.

Just from my curiosity, is there any number of performance improvement by this patch?

Thanks, 
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
