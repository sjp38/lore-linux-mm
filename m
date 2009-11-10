Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 25BCC6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 02:39:06 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAA7d385019724
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 10 Nov 2009 16:39:03 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 81E5B45DE52
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:39:03 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5960145DE51
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:39:03 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 41A771DB803F
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:39:03 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 002711DB803C
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:39:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask v2
In-Reply-To: <20091110162445.c6db7521.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091110162121.361B.A69D9226@jp.fujitsu.com> <20091110162445.c6db7521.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20091110163419.361E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 10 Nov 2009 16:39:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, cl@linux-foundation.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

> > > +
> > > +	/* Check this allocation failure is caused by cpuset's wall function */
> > > +	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> > > +			high_zoneidx, nodemask)
> > > +		if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
> > >  			return CONSTRAINT_CPUSET;
> > 
> > If cpuset and MPOL_BIND are both used, Probably CONSTRAINT_MEMORY_POLICY is
> > better choice.
> 
> No. this memory allocation is failed by limitation of cpuset's alloc mask.
> Not from mempolicy.

But CONSTRAINT_CPUSET doesn't help to free necessary node memory. It isn't
your fault. original code is wrong too. but I hope we should fix it.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
