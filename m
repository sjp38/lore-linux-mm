Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 18E796B004D
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 04:52:10 -0400 (EDT)
Subject: Re: [BUGFIX] set_mempolicy(MPOL_INTERLEAV) N_HIGH_MEMORY aware
From: Andi Kleen <andi@firstfloor.org>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com>
	<20090728161813.f2fefd29.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 28 Jul 2009 10:52:10 +0200
In-Reply-To: <20090728161813.f2fefd29.kamezawa.hiroyu@jp.fujitsu.com> (KAMEZAWA Hiroyuki's message of "Tue, 28 Jul 2009 16:18:13 +0900")
Message-ID: <877hxti405.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Miao Xie <miaox@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Yasunori Goto <y-goto@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> tested on x86-64/fake NUMA and ia64/NUMA.
> (That ia64 is a host which orignal bug report used.)
>
> Maybe this is bigger patch than expected, but NODEMASK_ALLOC() will be a way
> to go, anyway. (even if CPUMASK_ALLOC is not used anyware yet..)
> Kosaki tested this on ia64 NUMA. thanks.

Note that low/high memory support in NUMA policy is only partial
anyways, e.g. the VMA based policy only supports a single zone. That
was by design choice and because NUMA has a lot of issues on 32bit due
to the limited address space and is not widely used.

So small fixes are ok but I wouldn't go to large effort to fix NUMA
policy on 32bit.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
