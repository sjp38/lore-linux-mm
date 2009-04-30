Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 21E896B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 05:05:54 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3U95vH4022817
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 30 Apr 2009 18:05:57 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C18845DD7A
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 18:05:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 190F445DD6E
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 18:05:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id ED5571DB8019
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 18:05:56 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AABCC1DB8013
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 18:05:56 +0900 (JST)
Date: Thu, 30 Apr 2009 18:04:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: fix stale swap cache leak v5
Message-Id: <20090430180426.25ae2fa6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090430163539.7a882cef.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090430161627.0ccce565.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430163539.7a882cef.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Apr 2009 16:35:39 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 30 Apr 2009 16:16:27 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > This is v5 but all codes are rewritten.
> > 
> > After this patch, when memcg is used,
> >  1. page's swapcount is checked after I/O (without locks). If the page is
> >     stale swap cache, freeing routine will be scheduled.
> >  2. vmscan.c calls try_to_free_swap() when __remove_mapping() fails.
> > 
> > Works well for me. no extra resources and no races.
> > 
> > Because my office will be closed until May/7, I'll not be able to make a
> > response. Posting this for showing what I think of now.
> > 
> I found a hole immediately after posted this...sorry. plz ignore this patch/
> see you again in the next month.
> 
I'm now wondering to disable "swapin readahed" completely when memcg is used...
Then, half of the problems will go away immediately.
And it's not so bad to try to free swapcache if swap writeback ends. Then, another
half will go away...

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
