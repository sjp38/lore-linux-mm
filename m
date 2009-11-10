Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6305D6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 02:43:34 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAA7hWfP012699
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 10 Nov 2009 16:43:32 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D1C1245DE52
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:43:31 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B7B3A45DE50
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:43:31 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A05BD1DB8041
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:43:31 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4939D1DB8038
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:43:31 +0900 (JST)
Date: Tue, 10 Nov 2009 16:40:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with
 nodemask v2
Message-Id: <20091110164055.a1b44a4b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091110163419.361E.A69D9226@jp.fujitsu.com>
References: <20091110162121.361B.A69D9226@jp.fujitsu.com>
	<20091110162445.c6db7521.kamezawa.hiroyu@jp.fujitsu.com>
	<20091110163419.361E.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, cl@linux-foundation.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 10 Nov 2009 16:39:02 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > > > +
> > > > +	/* Check this allocation failure is caused by cpuset's wall function */
> > > > +	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> > > > +			high_zoneidx, nodemask)
> > > > +		if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
> > > >  			return CONSTRAINT_CPUSET;
> > > 
> > > If cpuset and MPOL_BIND are both used, Probably CONSTRAINT_MEMORY_POLICY is
> > > better choice.
> > 
> > No. this memory allocation is failed by limitation of cpuset's alloc mask.
> > Not from mempolicy.
> 
> But CONSTRAINT_CPUSET doesn't help to free necessary node memory. It isn't
> your fault. original code is wrong too. but I hope we should fix it.
> 
Hmm, maybe fair enough.

My 3rd version will use "kill always current(CONSTRAINT_MEMPOLICY does this)
if it uses mempolicy" logic.

Objections ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
