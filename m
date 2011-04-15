Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 61B0A900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 04:29:09 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BB9393EE0C1
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 17:29:06 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A0E7845DE73
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 17:29:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 846B645DE68
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 17:29:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6272FE08003
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 17:29:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C293E18005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 17:29:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2] cpusets: randomize node rotor used in cpuset_mem_spread_node()
In-Reply-To: <20110415082051.GB8828@tiehlicka.suse.cz>
References: <20110415161831.12F8.A69D9226@jp.fujitsu.com> <20110415082051.GB8828@tiehlicka.suse.cz>
Message-Id: <20110415172855.12FF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 15 Apr 2011 17:29:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, Jack Steiner <steiner@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

> [I just realized that I forgot to CC mm mailing list]
> 
> On Fri 15-04-11 16:18:45, KOSAKI Motohiro wrote:
> > Oops.
> > I should have look into !mempolicy part too.
> > I'm sorry.
> > 
> [...]
> > Michal, I think this should be
> > 
> > #ifdef CONFIG_CPUSETS
> > 	if (cpuset_do_page_mem_spread())
> > 		p->cpuset_mem_spread_rotor = node_random(&p->mems_allowed);
> > 	if (cpuset_do_slab_mem_spread())
> > 		p->cpuset_slab_spread_rotor = node_random(&p->mems_allowed);
> > #endif
> > 
> > because 99.999% people don't use cpuset's spread mem/slab feature and
> > get_random_int() isn't zero cost.
> > 
> > What do you think?
> 
> You are right. I was thinking about lazy approach and initialize those
> values when they are used for the first time. What about the patch
> below?
> 
> Change from v1:
> - initialize cpuset_{mem,slab}_spread_rotor lazily

Yeah! This is much much better than mine. Thank you!
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
