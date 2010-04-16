Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9CFC06B020E
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 01:33:43 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3G5XejO029967
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 16 Apr 2010 14:33:41 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B1D9045DE55
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 14:33:40 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A7A145DE4F
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 14:33:40 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 631B91DB803F
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 14:33:40 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 18CB21DB8040
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 14:33:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: page_check_references() check low order lumpy  reclaim properly
In-Reply-To: <t2j28c262361004152126t1975cd96kc21e54f3a9e41f82@mail.gmail.com>
References: <20100416115437.27AD.A69D9226@jp.fujitsu.com> <t2j28c262361004152126t1975cd96kc21e54f3a9e41f82@mail.gmail.com>
Message-Id: <20100416143134.27B9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Fri, 16 Apr 2010 14:33:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Andreas Mohr <andi@lisas.de>, Jens Axboe <axboe@kernel.dk>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> > + A  A  A  /*
> > + A  A  A  A * If we need a large contiguous chunk of memory, or have
> > + A  A  A  A * trouble getting a small set of contiguous pages, we
> > + A  A  A  A * will reclaim both active and inactive pages.
> > + A  A  A  A */
> > + A  A  A  if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> > + A  A  A  A  A  A  A  sc->lumpy_reclaim = 1;
> > + A  A  A  else if (sc->order && priority < DEF_PRIORITY - 2)
> > + A  A  A  A  A  A  A  sc->lumpy_reclaim = 1;
> > + A  A  A  else
> > + A  A  A  A  A  A  A  sc->lumpy_reclaim = 0;
> 
> How about making new function for readability instead of nesting else?
> int is_lumpy_reclaim(struct scan_control *sc)
> {
> ....
> }
> 
> If you merge patch reduced stack usage of reclaim path, I think it's
> enough alone scan_control argument.
> It's just nitpick. :)
> If you don't mind, ignore, please.

Good opinion. I don't hope introduce the dependency of "reduced stack usage"
series. but I agree that I'll push your proposal later and separately.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
