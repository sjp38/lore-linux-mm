Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0FF9B6B004F
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 00:06:36 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2I46YHt026691
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 18 Mar 2009 13:06:34 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C5F745DD78
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 13:06:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 30B4645DD7F
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 13:06:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 05709E08003
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 13:06:34 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A3135E08001
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 13:06:33 +0900 (JST)
Date: Wed, 18 Mar 2009 13:05:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memcg: handle swapcache leak
Message-Id: <20090318130509.c666dcf5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090318125154.f8ffe652.nishimura@mxp.nes.nec.co.jp>
References: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
	<20090317143903.a789cf57.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317151113.79a3cc9d.nishimura@mxp.nes.nec.co.jp>
	<20090317162950.70c1245c.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317183850.67c35b27.kamezawa.hiroyu@jp.fujitsu.com>
	<20090318101727.f00dfc2f.nishimura@mxp.nes.nec.co.jp>
	<20090318103418.7d38dce0.kamezawa.hiroyu@jp.fujitsu.com>
	<20090318125154.f8ffe652.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 18 Mar 2009 12:51:54 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > I'm sorry if I miss your point.
> > 
> > 
> Yes, there would be no problem of swp_entry leak, but these pages, which have
> been removed from swapcache and are being free'ed by free_swap_and_cache,
> cannot be removed from orphan_lru, although they are removed from global LRU, right ?
> 
Ah, I see. thank you. SwapCache flags is deleted before deleting from LRU.
OK, will fix.

> > 
> It may work for type-1 of swapcaches that I described in first mail,
> because memsw charges of them are not uncharged while they are on swapcache.
> 
> But it doesn't work for type-2 of swapcaches because they are uncharged
> from both mem and memsw.
> 
> Hmm, should I send a patch for shrink_page_list() attached in first mail
> as another patch ?
> 
Ok, just check the number of pages on orphan list.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
