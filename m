Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 555346B007E
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 22:27:53 -0500 (EST)
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id nAB3Rmhf012362
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 03:27:48 GMT
Received: from pzk28 (pzk28.prod.google.com [10.243.19.156])
	by spaceape7.eur.corp.google.com with ESMTP id nAB3Ri3g007863
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 19:27:45 -0800
Received: by pzk28 with SMTP id 28so468175pzk.27
        for <linux-mm@kvack.org>; Tue, 10 Nov 2009 19:27:44 -0800 (PST)
Date: Tue, 10 Nov 2009 19:27:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask
 v3
In-Reply-To: <20091111121958.FD59.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911101926080.16932@chino.kir.corp.google.com>
References: <20091111115217.FD56.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0911101908180.14549@chino.kir.corp.google.com> <20091111121958.FD59.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Nov 2009, KOSAKI Motohiro wrote:

> Linux doesn't support 1K nodes. (and only SGI huge machine use 512 nodes)
> 

I know for a fact that it does on x86 if you adjust CONFIG_NODES_SHIFT, 
I've booted kernels all the way back to 2.6.18 with 1K nodes.

> At least, NODEMASK_ALLOC should make more cleaner interface. current one
> and struct nodemask_scratch are pretty ugly.
> 

I agree, I haven't been a fan of nodemask_scratch because I think its use 
case is pretty limited, but I do advocate using NODEMASK_ALLOC() when deep 
in the stack.  We've made sure that most of the mempolicy code does that 
where manipulating nodemasks is common in -mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
