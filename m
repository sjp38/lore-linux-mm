Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 841B26B004D
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 21:15:49 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o132FkiM015616
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Feb 2010 11:15:47 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 96B7845DE4C
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 11:15:46 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6038C45DE51
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 11:15:46 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4155AE7800D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 11:15:46 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C0DF4E78006
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 11:15:45 +0900 (JST)
Date: Wed, 3 Feb 2010 11:12:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Improving OOM killer
Message-Id: <20100203111224.8fe0e20c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002021809220.15327@chino.kir.corp.google.com>
References: <201002012302.37380.l.lunak@suse.cz>
	<alpine.DEB.2.00.1002011523280.19457@chino.kir.corp.google.com>
	<201002022210.06760.l.lunak@suse.cz>
	<alpine.DEB.2.00.1002021643240.3393@chino.kir.corp.google.com>
	<20100203105236.b4a60754.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002021809220.15327@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lubos Lunak <l.lunak@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Feb 2010 18:12:41 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 3 Feb 2010, KAMEZAWA Hiroyuki wrote:
> 
> > I stopped that as I mentioned. I'm heavily disappointed with myself and
> > would like not to touch oom-killer things for a while.
> > 
> > I'd like to conentrate on memcg for a while, which I've starved for these 3 months.
> > 
> > Then, you don't need to CC me.
> > 
> 
> I'm disappointed to hear that, it would be helpful to get some consensus 
> on the points that we can all agree on from different perspectives.  I'll 
> try to find some time to develop a solution that people will see as a move 
> in the positive direction.
> 
> On a seperate topic, do you have time to repost your sysctl cleanup for 
> Andrew from http://marc.info/?l=linux-kernel&m=126457416729672 with the
> #ifndef CONFIG_MMU fix I mentioned?
> 
I'll not. Feel free to reuse fragments I posted.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
