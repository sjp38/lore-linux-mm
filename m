Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F349A900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 19:42:19 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p3FNgHjx004659
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:42:18 -0700
Received: from pwj6 (pwj6.prod.google.com [10.241.219.70])
	by hpaq7.eem.corp.google.com with ESMTP id p3FNgFsY009613
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:42:16 -0700
Received: by pwj6 with SMTP id 6so1867073pwj.18
        for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:42:14 -0700 (PDT)
Date: Fri, 15 Apr 2011 16:42:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] cpusets: randomize node rotor used in
 cpuset_mem_spread_node()
In-Reply-To: <20110415082051.GB8828@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1104151639080.3967@chino.kir.corp.google.com>
References: <20110414065146.GA19685@tiehlicka.suse.cz> <20110414160145.0830.A69D9226@jp.fujitsu.com> <20110415161831.12F8.A69D9226@jp.fujitsu.com> <20110415082051.GB8828@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Jack Steiner <steiner@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Fri, 15 Apr 2011, Michal Hocko wrote:

> You are right. I was thinking about lazy approach and initialize those
> values when they are used for the first time. What about the patch
> below?
> 
> Change from v1:
> - initialize cpuset_{mem,slab}_spread_rotor lazily
> 

The difference between this v2 patch and what is already in the -mm tree 
(http://userweb.kernel.org/~akpm/mmotm/broken-out/cpusets-randomize-node-rotor-used-in-cpuset_mem_spread_node.patch) 
is the lazy initialization by adding cpuset_{mem,slab}_spread_node()?

It'd probably be better to just make an incremental patch on top of 
mmotm-2011-04-14-15-08 with a new changelog and then propose with with 
your list of reviewed-by lines.

Andrew could easily drop the earlier version and merge this v2, but I'm 
asking for selfish reasons: please use NUMA_NO_NODE instead of -1.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
