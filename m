Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 87CD36B0087
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 02:25:39 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBA7PbYm008625
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 10 Dec 2010 16:25:37 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 17CC345DE66
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 16:25:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DDBBD45DE58
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 16:25:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CA064E38003
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 16:25:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 946721DB8046
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 16:25:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
In-Reply-To: <AANLkTikOgkGBn9AbEDAM4KegsnwuXqF2jg7icu0yc8Kh@mail.gmail.com>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org> <AANLkTikOgkGBn9AbEDAM4KegsnwuXqF2jg7icu0yc8Kh@mail.gmail.com>
Message-Id: <20101210162623.C7C7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 10 Dec 2010 16:25:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> So we look at zone_reclaimable_pages() only to determine proceed
> reclaiming or not. What if I have tons of unused dentry and inode
> caches and we are skipping the shrinker here?
> 
> --Ying

Good catch!
I perfectly agree with you.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
