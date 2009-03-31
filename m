Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C9BF46B004D
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 21:47:52 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2V1mZUi007807
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 31 Mar 2009 10:48:35 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C897C45DE5C
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 10:48:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AFFC45DE53
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 10:48:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 24ED1E38004
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 10:48:34 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E043E18001
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 10:48:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: memcg needs may_swap (Re: [patch] vmscan: rename  sc.may_swap to may_unmap)
In-Reply-To: <20090331104237.e689f279.kamezawa.hiroyu@jp.fujitsu.com>
References: <28c262360903301826w6429720es8ceb361cfc088b1@mail.gmail.com> <20090331104237.e689f279.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090331104625.B1C7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 31 Mar 2009 10:48:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>

> > Sorry for too late response.
> > I don't know memcg well.
> > 
> > The memcg managed to use may_swap well with global page reclaim until now.
> > I think that was because may_swap can represent both meaning.
> > Do we need each variables really ?
> > 
> > How about using union variable ?
> 
> or Just removing one of them  ?

I hope all may_unmap user convert to using may_swap.
may_swap is more efficient and cleaner meaning.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
