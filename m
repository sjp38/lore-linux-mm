Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id E54A76B002C
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 20:50:17 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6A7803EE0C1
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 10:50:16 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5020E45DE4D
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 10:50:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 380B245DD74
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 10:50:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DDDB1DB8041
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 10:50:16 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AB22B1DB803F
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 10:50:15 +0900 (JST)
Date: Mon, 6 Feb 2012 10:48:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: fix up documentation on global LRU.
Message-Id: <20120206104856.e56680a2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CALWz4ixtGPwDxsd8vnW=ErSh7zaVgO6m=6C7wxk2xmK69QnURQ@mail.gmail.com>
References: <1328233033-14246-1-git-send-email-yinghan@google.com>
	<20120203113822.19cf6fd2.kamezawa.hiroyu@jp.fujitsu.com>
	<CALWz4ixtGPwDxsd8vnW=ErSh7zaVgO6m=6C7wxk2xmK69QnURQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Fri, 3 Feb 2012 12:03:38 -0800
Ying Han <yinghan@google.com> wrote:

> On Thu, Feb 2, 2012 at 6:38 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, A 2 Feb 2012 17:37:13 -0800
> > Ying Han <yinghan@google.com> wrote:
 
> >
> > Do you want to do memory locking by setting swap_limit=0 ?
> 
> hmm, not sure what do you mean here?
> 

Do you want to add memory.swap.limit_in_bytes file for limitting swap
and do memrory.swap.limit_in_bytes = 0
for guaranteeing any anon pages will never be swapped-out ?



Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
