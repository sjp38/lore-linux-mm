Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1EF2E6B004D
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 19:44:13 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9TNiAUL006551
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 30 Oct 2009 08:44:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 494EF45DE7A
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 08:44:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1761F45DE70
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 08:44:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EFF081DB8040
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 08:44:09 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 909141DB803F
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 08:44:09 +0900 (JST)
Date: Fri, 30 Oct 2009 08:41:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
Message-Id: <20091030084134.fc968a90.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0910290232000.21298@chino.kir.corp.google.com>
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com>
	<abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com>
	<20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910290125390.11476@chino.kir.corp.google.com>
	<20091029174632.8110976c.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910290156560.16347@chino.kir.corp.google.com>
	<20091029181650.979bf95c.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910290232000.21298@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, vedran.furac@gmail.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Oct 2009 02:44:45 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:
> >   Then,
> >   - I'd like to drop file_rss.
> >   - I'd like to take swap_usage into acccount.
> >   - I'd like to remove cpu_time bonus. runtime bonus is much more important.
> >   - I'd like to remove penalty from children. To do that, fork-bomb detector
> >     is necessary.
> >   - nice bonus is bad. (We have oom_adj instead of this.) It should be
> >     if (task_nice(p) < 0)
> > 	points /= 2;
> >     But we have "root user" bonus already. We can remove this line.
> > 
> > After above, much more simple selection, easy-to-understand,  will be done.
> > 
> 
> Agreed, I think we'll need to rewrite most of the heuristic from scratch.

I'd like to post total redesgin of oom-killer in the next week.
plz wait.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
