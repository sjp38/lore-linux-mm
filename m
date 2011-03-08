Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 304248D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 21:01:46 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9863E3EE0BB
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:01:40 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DB2045DE59
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:01:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6529145DE56
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:01:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 56CFD1DB804A
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:01:40 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 223F71DB8047
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:01:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] oom: prevent unnecessary oom kills or kernel panics
In-Reply-To: <alpine.DEB.2.00.1103061404210.23737@chino.kir.corp.google.com>
References: <20110306201408.6CC6.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1103061404210.23737@chino.kir.corp.google.com>
Message-Id: <20110308105825.7EA5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Mar 2011 11:01:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

> On Sun, 6 Mar 2011, KOSAKI Motohiro wrote:
> 
> > > There is no deadlock being introduced by this patch; if you have an 
> > > example of one, then please show it.  The problem is not just overkill but 
> > > rather panicking the machine when no other eligible processes exist.  We 
> > > have seen this in production quite a few times and we'd like to see this 
> > > patch merged to avoid our machines panicking because the oom killer, by 
> > > your patch, isn't considering threads that are eligible in the exit path 
> > > once their parent has been killed and has exited itself yet memory freeing 
> > > isn't possible yet because the threads still pin the ->mm.
> > 
> > No. While you don't understand current code, I'll not taking yours.
> > 
> 
> I take this as you declining to show your example of a deadlock introduced 
> by this patch as requested.  There is no such deadlock.  The patch is 
> reintroducing the behavior of the oom killer that existed for years before 
> you broke it and caused many of ours machines to panic as a result.
> 
> Thanks for your review.

How do you proof no deadlock? No, you can't. Don't pray to work as you hope.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
