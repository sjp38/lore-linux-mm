Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7B8ED6B02A7
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 05:48:08 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6P9m7Yu023672
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 25 Jul 2010 18:48:08 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F9F645DE79
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 18:48:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 658F045DE6F
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 18:48:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CF8E1DB803B
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 18:48:07 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E4F091DB8037
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 18:48:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] memcg: sc.nr_to_reclaim should be initialized
In-Reply-To: <AANLkTikpZ8iH1oO1k84kvo2qYYS96LYuNmmw6xJL-1QV@mail.gmail.com>
References: <20100723154638.88C8.A69D9226@jp.fujitsu.com> <AANLkTikpZ8iH1oO1k84kvo2qYYS96LYuNmmw6xJL-1QV@mail.gmail.com>
Message-Id: <20100725184322.40CF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Sun, 25 Jul 2010 18:48:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

> >> 1. How far does this push pages (in terms of when limit is hit)?
> >
> > 32 pages per mem_cgroup_shrink_node_zone().
> >
> > That said, the algorithm is here.
> >
> > 1. call mem_cgroup_largest_soft_limit_node()
> > =A0 calculate largest cgroup
> > 2. call mem_cgroup_shrink_node_zone() and shrink 32 pages
> > 3. goto 1 if limit is still exceed.
> >
> > If it's not your intention, can you please your intended algorithm?
>=20
> We set it to 0, since we care only about a single page reclaim on
> hitting the limit. IIRC, in the past we saw an excessive pushback on
> reclaiming SWAP_CLUSTER_MAX pages, just wanted to check if you are
> seeing the same behaviour even now after your changes.

Actually, we have 32 pages reclaim batch size. (see nr_scan_try_batch() and=
 related functions)
thus <32 value doesn't works as your intended.

But, If you run your test again, and (if there is) report any bugs. I'm ver=
y glad and fix it soon.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
