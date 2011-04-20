Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E36128D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 22:57:54 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 759573EE0BB
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 11:57:50 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DEFA45DE97
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 11:57:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3187745DE92
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 11:57:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 21E33E38008
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 11:57:50 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DA5CEE38004
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 11:57:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to expand_upwards
In-Reply-To: <1303267733.11237.42.camel@mulgrave.site>
References: <20110420102314.4604.A69D9226@jp.fujitsu.com> <1303267733.11237.42.camel@mulgrave.site>
Message-Id: <20110420115804.461E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed, 20 Apr 2011 11:57:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>

> On Wed, 2011-04-20 at 10:23 +0900, KOSAKI Motohiro wrote:
> > > On Tue, 19 Apr 2011, James Bottomley wrote:
> > > 
> > > > > Which part of me telling you that you will break lots of other things in
> > > > > the core kernel dont you get?
> > > >
> > > > I get that you tell me this ... however, the systems that, according to
> > > > you, should be failing to get to boot prompt do, in fact, manage it.
> > > 
> > > If you dont use certain subsystems then it may work. Also do you run with
> > > debuggin on.
> > > 
> > > The following patch is I think what would be needed to fix it.
> > 
> > I'm worry about this patch. A lot of mm code assume !NUMA systems 
> > only have node 0. Not only SLUB.
> > 
> > I'm not sure why this unfortunate mismatch occur. but I think DISCONTIG
> > hacks makes less sense. Can we consider parisc turn NUMA on instead?
> 
> Well, you mean a patch like this?  It won't build ... obviously we need
> some more machinery
> 
>   CC      arch/parisc/kernel/asm-offsets.s
> In file included from include/linux/sched.h:78,
>                  from arch/parisc/kernel/asm-offsets.c:31:
> include/linux/topology.h:212:2: error: #error Please define an appropriate SD_NODE_INIT in include/asm/topology.h!!!
> In file included from include/linux/sched.h:78,
>                  from arch/parisc/kernel/asm-offsets.c:31:
> include/linux/topology.h: In function 'numa_node_id':
> include/linux/topology.h:255: error: implicit declaration of function 'cpu_to_node'

Sorry about that. I'll see more carefully the code later. Probably long
time discontig-mem uninterest made multiple level breakage. Grr. ;-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
