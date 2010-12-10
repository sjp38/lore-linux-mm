Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2308A6B0087
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 02:37:14 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBA7bAOI007160
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 10 Dec 2010 16:37:10 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7867F45DE6B
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 16:37:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E3B645DE55
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 16:37:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 46537E18008
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 16:37:10 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 04FBC1DB803B
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 16:37:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
In-Reply-To: <20101210162623.C7C7.A69D9226@jp.fujitsu.com>
References: <AANLkTikOgkGBn9AbEDAM4KegsnwuXqF2jg7icu0yc8Kh@mail.gmail.com> <20101210162623.C7C7.A69D9226@jp.fujitsu.com>
Message-Id: <20101210163338.C7CA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 10 Dec 2010 16:37:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > So we look at zone_reclaimable_pages() only to determine proceed
> > reclaiming or not. What if I have tons of unused dentry and inode
> > caches and we are skipping the shrinker here?
> > 
> > --Ying
> 
> Good catch!
> I perfectly agree with you.

The problem is, nunber of reclaimable slab doesn't give us any information.
There are frequently pinned and unreclaimable. That's one of the reason
now we are trying reclaim only when priority==DEF_PRIORITY even if all_unreclaimable=1.

slab shrinker should implement all_unreclaimable heuristics too?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
