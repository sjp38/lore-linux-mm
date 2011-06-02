Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8327D6B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 10:27:59 -0400 (EDT)
Date: Thu, 2 Jun 2011 16:27:38 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 7/8] vmscan: memcg-aware unevictable page rescue scanner
Message-ID: <20110602142738.GC28684@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-8-git-send-email-hannes@cmpxchg.org>
 <BANLkTi=cHVZP+fZwHNM3cXVyw53kJ2HQmw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTi=cHVZP+fZwHNM3cXVyw53kJ2HQmw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 02, 2011 at 10:27:15PM +0900, Hiroyuki Kamezawa wrote:
> 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
> > Once the per-memcg lru lists are exclusive, the unevictable page
> > rescue scanner can no longer work on the global zone lru lists.
> >
> > This converts it to go through all memcgs and scan their respective
> > unevictable lists instead.
> >
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Hm, isn't it better to have only one GLOBAL LRU for unevictable pages ?
> memcg only needs counter for unevictable pages and LRU is not necessary
> to be per memcg because we don't reclaim it...

That's true, and I will look into it.  But keep in mind that it needs
special-casing that one list type from all the others, so maybe it's
just easier to keep it like this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
