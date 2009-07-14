Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9AC086B004F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 19:04:00 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6ENcfEg031518
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 15 Jul 2009 08:38:41 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3190F45DE52
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 08:38:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 159EE45DE51
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 08:38:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EED1E1DB803A
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 08:38:40 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id AA04E1DB803E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 08:38:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] OOM analysis helper patch series v3
In-Reply-To: <alpine.DEB.1.00.0907141141100.1598@mail.selltech.ca>
References: <20090713144924.6257.A69D9226@jp.fujitsu.com> <alpine.DEB.1.00.0907141141100.1598@mail.selltech.ca>
Message-Id: <20090715083815.252D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 15 Jul 2009 08:38:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Li, Ming Chun" <macli@brc.ubc.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Mon, 13 Jul 2009, KOSAKI Motohiro wrote:
> 
> > ChangeLog
> >  Since v2
> >    - Dropped "[4/5] add isolate pages vmstat" temporary because it become
> >      slightly big. Then, I plan to submit it as another patchset.
> >    - Rewrote many patch description (Thanks! Christoph)
> >  Since v1
> >    - Dropped "[5/5] add NR_ANON_PAGES to OOM log" patch
> >    - Instead, introduce "[5/5] add shmem vmstat" patch
> >    - Fixed unit bug (Thanks Minchan)
> >    - Separated isolated vmstat to two field (Thanks Minchan and Wu)
> >    - Fixed isolated page and lumpy reclaim issue (Thanks Minchan)
> >    - Rewrote some patch description (Thanks Christoph)
> > 
> > This patch series are tested on 2.6.31-rc2 + mm-show_free_areas-display-slab-pages-in-two-separate-fields.patch
> 
> For your information, I tested the patches on 2.6.31-rc3 + 
> mm-show_free_areas-display-slab-pages-in-two-separate-fields.patch. It is 
> fine.

Cute. thanks!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
