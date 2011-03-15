Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CF8B88D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 22:33:03 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id EC8173EE0C3
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 11:32:59 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CEBCA45DE4D
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 11:32:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B59D445DE53
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 11:32:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A44E2E78004
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 11:32:59 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F8F11DB8040
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 11:32:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2 v4]mm: batch activate_page() to reduce lock contention
In-Reply-To: <AANLkTin2h0YFe70vYj7cExAJbbPS+oDjvfunfGPNZfB1@mail.gmail.com>
References: <1300154014.2337.74.camel@sli10-conroe> <AANLkTin2h0YFe70vYj7cExAJbbPS+oDjvfunfGPNZfB1@mail.gmail.com>
Message-Id: <20110315111641.3520.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 15 Mar 2011 11:32:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

> >> Why do we need CONFIG_SMP in only activate_page_pvecs?
> >> The per-cpu of activate_page_pvecs consumes lots of memory in UP?
> >> I don't think so. But if it consumes lots of memory, it's a problem
> >> of per-cpu.
> > No, not too much memory.
> >
> >> I can't understand why we should hanlde activate_page_pvecs specially.
> >> Please, enlighten me.
> > Not it's special. akpm asked me to do it this time. Reducing little
> > memory is still worthy anyway, so that's it. We can do it for other
> > pvecs too, in separate patch.
> 
> Understandable but I don't like code separation by CONFIG_SMP for just
> little bit enhance of memory usage. In future, whenever we use percpu,
> do we have to implement each functions for both SMP and non-SMP?
> Is it desirable?
> Andrew, Is it really valuable?
> 
> If everybody agree, I don't oppose such way.
> But now I vote code cleanness than reduce memory footprint.

FWIW, The ifdef was added for embedded concern. and I believe you are 
familiar with modern embedded trend than me. then, I have no objection
to remove it if you don't need it.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
