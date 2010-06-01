Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 354056B021D
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:38:38 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o517cZos014557
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Jun 2010 16:38:36 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC09A45DE61
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:38:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7817545DE51
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:38:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D0681DB803F
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:38:35 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 136041DB803A
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:38:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 11/18] oom: avoid oom killer for lowmem allocations
In-Reply-To: <alpine.DEB.2.00.1006010015460.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010015460.29202@chino.kir.corp.google.com>
Message-Id: <20100601163813.2466.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  1 Jun 2010 16:38:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> If memory has been depleted in lowmem zones even with the protection
> afforded to it by /proc/sys/vm/lowmem_reserve_ratio, it is unlikely that
> killing current users will help.  The memory is either reclaimable (or
> migratable) already, in which case we should not invoke the oom killer at
> all, or it is pinned by an application for I/O.  Killing such an
> application may leave the hardware in an unspecified state and there is no
> guarantee that it will be able to make a timely exit.
> 
> Lowmem allocations are now failed in oom conditions when __GFP_NOFAIL is
> not used so that the task can perhaps recover or try again later.
> 
> Previously, the heuristic provided some protection for those tasks with
> CAP_SYS_RAWIO, but this is no longer necessary since we will not be
> killing tasks for the purposes of ISA allocations.
> 
> high_zoneidx is gfp_zone(gfp_flags), meaning that ZONE_NORMAL will be the
> default for all allocations that are not __GFP_DMA, __GFP_DMA32,
> __GFP_HIGHMEM, and __GFP_MOVABLE on kernels configured to support those
> flags.  Testing for high_zoneidx being less than ZONE_NORMAL will only
> return true for allocations that have either __GFP_DMA or __GFP_DMA32.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

ack


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
