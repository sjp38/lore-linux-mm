Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D82896B004F
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 05:01:53 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id n6H91nRm013042
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 10:01:50 +0100
Received: from pxi13 (pxi13.prod.google.com [10.243.27.13])
	by wpaz17.hot.corp.google.com with ESMTP id n6H91jQ1010944
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 02:01:46 -0700
Received: by pxi13 with SMTP id 13so495704pxi.12
        for <linux-mm@kvack.org>; Fri, 17 Jul 2009 02:01:45 -0700 (PDT)
Date: Fri, 17 Jul 2009 02:01:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
In-Reply-To: <20090717090003.A903.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0907170158050.13151@chino.kir.corp.google.com>
References: <1247679064.4089.26.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com> <20090717090003.A903.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Miao Xie <miaox@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Yasunori Goto <y-goto@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Jul 2009, KOSAKI Motohiro wrote:

> This patch seems band-aid patch. it will change memory-hotplug behavior.
> Please imazine following scenario:
> 
> 1. numactl interleave=all process-A
> 2. memory hot-add
> 
> before 2.6.30:
> 		-> process-A can use hot-added memory
> 

That apparently depends on the architecture since Lee said top_cpuset 
reflects node_possible_map on ia64 and node_online_map on x86_64.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
