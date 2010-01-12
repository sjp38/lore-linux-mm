Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 365F76B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 03:56:34 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0C8uUPZ014983
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 12 Jan 2010 17:56:31 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C02D52AEAA2
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 17:56:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D7631EF082
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 17:56:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5163CEF8003
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 17:56:29 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 030DA1DB803E
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 17:56:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for memory free
In-Reply-To: <alpine.DEB.2.00.1001112335001.12808@chino.kir.corp.google.com>
References: <20100112140923.B3A4.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1001112335001.12808@chino.kir.corp.google.com>
Message-Id: <20100112175027.B3BC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Jan 2010 17:56:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Huang Shijie <shijie8@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Tue, 12 Jan 2010, KOSAKI Motohiro wrote:
> 
> > From 751f197ad256c7245151681d7aece591b1dab343 Mon Sep 17 00:00:00 2001
> > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Date: Tue, 12 Jan 2010 13:53:47 +0900
> > Subject: [PATCH] mm: Restore zone->all_unreclaimable to independence word
> > 
> > commit e815af95 (change all_unreclaimable zone member to flags) chage
> > all_unreclaimable member to bit flag. but It have undesireble side
> > effect.
> > free_one_page() is one of most hot path in linux kernel and increasing
> > atomic ops in it can reduce kernel performance a bit.
> > 
> 
> Could you please elaborate on "a bit" in the changelog with some data?  If 
> it's so egregious, it should be easily be quantifiable.

Unfortunately I can't. atomic ops is mainly the issue of large machine. but
I can't access such machine now. but I'm sure we shouldn't take unnecessary
atomic ops.

That's fundamental space vs performance tradeoff thing. if we talked about
struct page or similar lots created struct, space efficient is very important.
but struct zone isn't such one.

Or, do you have strong argue to use bitops without space efficiency?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
