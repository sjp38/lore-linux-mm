Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C995A9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 20:47:53 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E67D83EE0BC
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:47:50 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C486C45DEA3
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:47:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC23F45DEA0
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:47:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BAFDE08002
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:47:50 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 656181DB803A
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:47:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH V2 2/2] change shrinker API by passing shrink_control struct
In-Reply-To: <BANLkTikteGwLXiG9GVDrMkrruUoTieADfQ@mail.gmail.com>
References: <20110426101631.F34C.A69D9226@jp.fujitsu.com> <BANLkTikteGwLXiG9GVDrMkrruUoTieADfQ@mail.gmail.com>
Message-Id: <20110427094902.D170.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 27 Apr 2011 09:47:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Nick Piggin <nickpiggin@yahoo.com.au>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

> > >  {
> > >       struct xfs_mount *mp;
> > >       struct xfs_perag *pag;
> > >       xfs_agnumber_t  ag;
> > >       int             reclaimable;
> > > +     int nr_to_scan = sc->nr_slab_to_reclaim;
> > > +     gfp_t gfp_mask = sc->gfp_mask;
> >
> > And, this very near meaning field .nr_scanned and .nr_slab_to_reclaim
> > poped up new question.
> > Why don't we pass more clever slab shrinker target? Why do we need pass
> > similar two argument?
> >
> 
> I renamed the nr_slab_to_reclaim and nr_scanned in shrink struct.

Oh no. that's not naming issue. example, Nick's previous similar patch pass
zone-total-pages and how-much-scanned-pages. (ie shrink_slab don't calculate 
current magical target scanning objects anymore)
	ie,  "4 *  max_pass  * (scanned / nr- lru_pages-in-zones)"

Instead, individual shrink_slab callback calculate this one.
see git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git

I'm curious why you change the design from another guy's previous very similar effort and
We have to be convinced which is better.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
