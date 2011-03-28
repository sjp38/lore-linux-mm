Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AD52F8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 06:37:38 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 0111A3EE0B6
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 19:37:35 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D455745DE6E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 19:37:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B59CE45DE55
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 19:37:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A47441DB8041
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 19:37:34 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C5D81DB8038
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 19:37:34 +0900 (JST)
Date: Mon, 28 Mar 2011 19:31:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: update documentation to describe usage_in_bytes
Message-Id: <20110328193108.07965b4a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110328094820.GC5693@tiehlicka.suse.cz>
References: <20110321102420.GB26047@tiehlicka.suse.cz>
	<20110322091014.27677ab3.kamezawa.hiroyu@jp.fujitsu.com>
	<20110322104723.fd81dddc.nishimura@mxp.nes.nec.co.jp>
	<20110322073150.GA12940@tiehlicka.suse.cz>
	<20110323092708.021d555d.nishimura@mxp.nes.nec.co.jp>
	<20110323133517.de33d624.kamezawa.hiroyu@jp.fujitsu.com>
	<20110328085508.c236e929.nishimura@mxp.nes.nec.co.jp>
	<20110328132550.08be4389.nishimura@mxp.nes.nec.co.jp>
	<20110328074341.GA5693@tiehlicka.suse.cz>
	<20110328181127.b8a2a1c5.kamezawa.hiroyu@jp.fujitsu.com>
	<20110328094820.GC5693@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 28 Mar 2011 11:48:20 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Mon 28-03-11 18:11:27, KAMEZAWA Hiroyuki wrote:
> > On Mon, 28 Mar 2011 09:43:42 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > On Mon 28-03-11 13:25:50, Daisuke Nishimura wrote:
> > > > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> [...]
> > > > +5.5 usage_in_bytes
> > > > +
> > > > +As described in 2.1, memory cgroup uses res_counter for tracking and limiting
> > > > +the memory usage. memory.usage_in_bytes shows the current res_counter usage for
> > > > +memory, and DOESN'T show a actual usage of RSS and Cache. It is usually bigger
> > > > +than the actual usage for a performance improvement reason. 
> > > 
> > > Isn't an explicit mention about caching charges better?
> > > 
> > 
> > It's difficult to distinguish which is spec. and which is implemnation details...
> 
> Sure. At least commit log should contain the implementation details IMO,
> though.
> 
> > 
> > My one here ;)
> > ==
> > 5.5 usage_in_bytes
> > 
> > For efficiency, as other kernel components, memory cgroup uses some optimization to
> > avoid unnecessary cacheline false sharing. usage_in_bytes is affected by the
> > method and doesn't show 'exact' value of usage, it's an fuzz value for efficient
> > access. (Of course, when necessary, it's synchronized.)
> > In usual, the value (RSS+CACHE) in memory.stat shows more exact value. IOW,
> 
> - In usual, the value (RSS+CACHE) in memory.stat shows more exact value. IOW,
> + (RSS+CACHE) value from memory.stat shows more exact value and should be used
> + by userspace. IOW,
> 
> ?
> 

seems good. Nishimura-san, could you update ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
