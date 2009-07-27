Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 936B16B0055
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 14:01:06 -0400 (EDT)
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id n6RI0sv8026101
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 11:00:54 -0700
Received: from wa-out-1112.google.com (wagm34.prod.google.com [10.114.214.34])
	by spaceape13.eur.corp.google.com with ESMTP id n6RI0o6D031057
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 11:00:51 -0700
Received: by wa-out-1112.google.com with SMTP id m34so598606wag.30
        for <linux-mm@kvack.org>; Mon, 27 Jul 2009 11:00:50 -0700 (PDT)
Date: Mon, 27 Jul 2009 11:00:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
In-Reply-To: <f39a7fd56408054bebd11e40b7dd4db6.squirrel@webmail-b.css.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0907271056170.8408@chino.kir.corp.google.com>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com> <1247679064.4089.26.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com> <alpine.DEB.2.00.0907241551070.8573@chino.kir.corp.google.com>
 <20090724160936.a3b8ad29.akpm@linux-foundation.org> <337c5d83954b38b14a17f0adf4d357d8.squirrel@webmail-b.css.fujitsu.com> <5bb65c0e4c6828b1331d33745f34d9ee.squirrel@webmail-b.css.fujitsu.com> <9443f91bd4648e6214b32acff4512b97.squirrel@webmail-b.css.fujitsu.com>
 <2f11576a0907250621w3696fdc0pe61638c8c935c981@mail.gmail.com> <f39a7fd56408054bebd11e40b7dd4db6.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, miaox@cn.fujitsu.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, y-goto@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 25 Jul 2009, KAMEZAWA Hiroyuki wrote:

> This behavior itself is not very bad.
> And all hotplug thing is just a side story of this bugfix.
> 

Right, the original problem that Lee reported doesn't appear to be caused 
by hotplug.

> To update nodemask,  user's mask should be saved in the policy
> even when the mask is not relative and v.node should be calculated
> again, at event. IIUC, rather than per-policy update by notifer,
> some new implemenation for policy will be necessary.
> 

We don't need additional non-default mempolicy support for MEM_ONLINE.  
It would be inappropriate to store the user nodemask and then hot-add new 
nodes to mempolicies based on the given node id's when nothing is assumed 
of its proximity.  It's better left to userspace to update existing 
mempolicies to use the newly added memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
