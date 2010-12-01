Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 319216B0085
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 02:52:23 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB17qKNX016941
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Dec 2010 16:52:20 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 376D845DE5D
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 16:52:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1255045DE54
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 16:52:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F1567E08004
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 16:52:19 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B9BC2E38003
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 16:52:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] mm: kswapd: Stop high-order balancing when any suitable zone is balanced
In-Reply-To: <1291189227.12777.79.camel@sli10-conroe>
References: <20101201122638.ABBF.A69D9226@jp.fujitsu.com> <1291189227.12777.79.camel@sli10-conroe>
Message-Id: <20101201164647.ABD7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed,  1 Dec 2010 16:52:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Simon Kirby <sim@hostway.ca>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> > > > we can't make
> > > > perfect VM heuristics obviously, then we need to compare pros/cons.
> > > if you don't care about small system, let's consider a NORMAL i386
> > > system with 896m normal zone, and 896M*3 high zone. normal zone will
> > > quickly exhaust by high order high zone allocation, leave a latter
> > > allocation which does need normal zone fail.
> > 
> > Not happen. slab don't allocate from highmem and page cache allocation
> > is always using order-0. When happen high order high zone allocation?
> ok, thanks, I missed this. then how about a x86_64 box with 896M DMA32
> and 896*3M NORMAL? some pci devices can only dma to DMA32 zone.

First, DMA32 is 4GB. Second, modern high end system don't use 32bit PCI
device. Third, while we are thinking desktop users, 4GB is not small
room. nowadays, typical desktop have only 2GB or 4GB memory.

In other word, I agree your pointed issue is exist _potentially_. but
I don't think it is frequently than Simon's case.

In other word, when deciding heuristics, we can't avoid to think issue
frequency. It's very important.


Of cource, if you have better idea, I don't oppose it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
