Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 11D9F6B0047
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 22:01:59 -0400 (EDT)
Date: Tue, 31 Mar 2009 10:52:49 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] vmscan: memcg needs may_swap (Re: [patch] vmscan:
 rename  sc.may_swap to may_unmap)
Message-Id: <20090331105249.98fd051b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <28c262360903301826w6429720es8ceb361cfc088b1@mail.gmail.com>
References: <20090327151926.f252fba7.nishimura@mxp.nes.nec.co.jp>
	<20090327153035.35498303.kamezawa.hiroyu@jp.fujitsu.com>
	<20090328214636.68FF.A69D9226@jp.fujitsu.com>
	<28c262360903301826w6429720es8ceb361cfc088b1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: nishimura@mxp.nes.nec.co.jp, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi,

> > ========
> > Subject: vmswan: reintroduce sc->may_swap
> >
> > vmscan-rename-scmay_swap-to-may_unmap.patch removed may_swap flag,
> > but memcg had used it as a flag for "we need to use swap?", as the
> > name indicate.
> >
> > And in current implementation, memcg cannot reclaim mapped file caches
> > when mem+swap hits the limit.
> >
> > re-introduce may_swap flag and handle it at get_scan_ratio().
> > This patch doesn't influence any scan_control users other than memcg.
> >
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > --
> > A mm/vmscan.c | A  12 ++++++++++--
> > A 1 files changed, 10 insertions(+), 2 deletions(-)
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 3be6157..00ea4a1 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -63,6 +63,9 @@ struct scan_control {
> > A  A  A  A /* Can mapped pages be reclaimed? */
> > A  A  A  A int may_unmap;
> >
> > + A  A  A  /* Can pages be swapped as part of reclaim? */
> > + A  A  A  int may_swap;
> > +
> 
> Sorry for too late response.
> I don't know memcg well.
> 
> The memcg managed to use may_swap well with global page reclaim until now.
memcg had a bug that it cannot reclaim mapped file caches when it hit
the mem+swap limit :(


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
