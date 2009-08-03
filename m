Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 161256B0087
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 03:46:06 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n73844m5012749
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 3 Aug 2009 17:04:04 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 38A4245DE50
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 17:04:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CA2F45DE4E
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 17:04:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FB841DB8037
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 17:04:03 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 55C161DB803F
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 17:04:03 +0900 (JST)
Date: Mon, 3 Aug 2009 17:02:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
Message-Id: <20090803170217.e98b2e46.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0908030050160.30778@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com>
	<20090730180029.c4edcc09.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907300219580.13674@chino.kir.corp.google.com>
	<20090730190216.5aae685a.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907301157100.9652@chino.kir.corp.google.com>
	<20090731093305.50bcc58d.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907310231370.25447@chino.kir.corp.google.com>
	<7f54310137837631f2526d4e335287fc.squirrel@webmail-b.css.fujitsu.com>
	<alpine.DEB.2.00.0907311212240.22732@chino.kir.corp.google.com>
	<77df8765230d9f83859fde3119a2d60a.squirrel@webmail-b.css.fujitsu.com>
	<alpine.DEB.2.00.0908011303050.22174@chino.kir.corp.google.com>
	<20090803104244.b58220ba.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0908030050160.30778@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Aug 2009 00:59:18 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> > >  - /proc/pid/oom_score is inconsistent when the thread that set the
> > >    effective per-mm oom_adj exits and it is now obsolete since you have
> > >    no way to determine what the next effective oom_adj value shall be.
> > > 
> > plz re-caluculate it. it's not a big job if done in lazy way.
> > 
> 
> You can't recalculate it if all the remaining threads have a different 
> oom_adj value than the effective oom_adj value from the thread that is now 
> exited.  

Then, crazy google apps pass different oom_adjs to each thread ?
And, threads other than thread-group-leader modifies its oom_adj.

Hmm, interesting.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
