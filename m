Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 36E356B0022
	for <linux-mm@kvack.org>; Fri, 13 May 2011 02:32:40 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3AF203EE0C2
	for <linux-mm@kvack.org>; Fri, 13 May 2011 15:32:36 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 21F3D45DE97
	for <linux-mm@kvack.org>; Fri, 13 May 2011 15:32:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AF2245DE96
	for <linux-mm@kvack.org>; Fri, 13 May 2011 15:32:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F2E491DB8038
	for <linux-mm@kvack.org>; Fri, 13 May 2011 15:32:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B931EE08001
	for <linux-mm@kvack.org>; Fri, 13 May 2011 15:32:35 +0900 (JST)
Date: Fri, 13 May 2011 15:25:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][BUGFIX] memcg fix zone congestion
Message-Id: <20110513152555.53def058.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTi=9oKwq-8f-kdinn0pUZ04g5Z7Gnw@mail.gmail.com>
References: <20110513121030.08fcae08.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=9oKwq-8f-kdinn0pUZ04g5Z7Gnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>

On Thu, 12 May 2011 22:25:10 -0700
Ying Han <yinghan@google.com> wrote:

> On Thu, May 12, 2011 at 8:10 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:

> >  mm/vmscan.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >
> > Index: mmotm-May11/mm/vmscan.c
> > ===================================================================
> > --- mmotm-May11.orig/mm/vmscan.c
> > +++ mmotm-May11/mm/vmscan.c
> > @@ -941,7 +941,8 @@ keep_lumpy:
> >         * back off and wait for congestion to clear because further reclaim
> >         * will encounter the same problem
> >         */
> > -       if (nr_dirty == nr_congested && nr_dirty != 0)
> > +       if (scanning_global_lru(sc) &&
> > +           nr_dirty == nr_congested && nr_dirty != 0)
> >                zone_set_flag(zone, ZONE_CONGESTED);
> >
> >        free_page_list(&free_pages);
> >
> > For memcg, wonder if we should make it per-memcg-per-zone congested.
> 

I guess dirty ratio should come 1st. If we don't have it, I think
nr_dirty==nr_congested very easily.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
