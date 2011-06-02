Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9927C6B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 10:29:26 -0400 (EDT)
Date: Thu, 2 Jun 2011 16:28:57 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 6/8] vmscan: change zone_nr_lru_pages to take memcg
 instead of scan control
Message-ID: <20110602142857.GD28684@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-7-git-send-email-hannes@cmpxchg.org>
 <BANLkTi=x_Fm-AcwcRAicJ4BaK1z0tT0u+Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTi=x_Fm-AcwcRAicJ4BaK1z0tT0u+Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 02, 2011 at 10:30:48PM +0900, Hiroyuki Kamezawa wrote:
> 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
> > This function only uses sc->mem_cgroup from the scan control.  Change
> > it to take a memcg argument directly, so callsites without an actual
> > reclaim context can use it as well.
> >
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> I wonder this can be cut out and cab be merged immediately, no ?

I don't see anything standing in the way of that.  OTOH, all current
users have scan controls, so it's not really urgent, either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
