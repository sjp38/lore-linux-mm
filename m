Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 889566B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 02:36:38 -0500 (EST)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o0C7aYXg010369
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 23:36:34 -0800
Received: from pwi20 (pwi20.prod.google.com [10.241.219.20])
	by wpaz37.hot.corp.google.com with ESMTP id o0C7a60g027392
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 23:36:33 -0800
Received: by pwi20 with SMTP id 20so2047886pwi.9
        for <linux-mm@kvack.org>; Mon, 11 Jan 2010 23:36:33 -0800 (PST)
Date: Mon, 11 Jan 2010 23:36:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for
 memory free
In-Reply-To: <20100112140923.B3A4.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1001112335001.12808@chino.kir.corp.google.com>
References: <20100112042116.GA26035@localhost> <20100112133223.005b81ed.kamezawa.hiroyu@jp.fujitsu.com> <20100112140923.B3A4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Huang Shijie <shijie8@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jan 2010, KOSAKI Motohiro wrote:

> From 751f197ad256c7245151681d7aece591b1dab343 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Tue, 12 Jan 2010 13:53:47 +0900
> Subject: [PATCH] mm: Restore zone->all_unreclaimable to independence word
> 
> commit e815af95 (change all_unreclaimable zone member to flags) chage
> all_unreclaimable member to bit flag. but It have undesireble side
> effect.
> free_one_page() is one of most hot path in linux kernel and increasing
> atomic ops in it can reduce kernel performance a bit.
> 

Could you please elaborate on "a bit" in the changelog with some data?  If 
it's so egregious, it should be easily be quantifiable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
