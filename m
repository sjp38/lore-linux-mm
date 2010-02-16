Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4686B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 18:54:28 -0500 (EST)
Received: from spaceape24.eur.corp.google.com (spaceape24.eur.corp.google.com [172.28.16.76])
	by smtp-out.google.com with ESMTP id o1GNstIi001437
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 23:54:55 GMT
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by spaceape24.eur.corp.google.com with ESMTP id o1GNrARE003212
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 15:54:54 -0800
Received: by pzk9 with SMTP id 9so5023970pzk.28
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 15:54:53 -0800 (PST)
Date: Tue, 16 Feb 2010 15:54:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
In-Reply-To: <20100217084239.265c65ea.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002161550550.11952@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com> <20100216090005.f362f869.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002151610380.14484@chino.kir.corp.google.com>
 <20100216092311.86bceb0c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002160058470.17122@chino.kir.corp.google.com> <20100217084239.265c65ea.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Feb 2010, KAMEZAWA Hiroyuki wrote:

> Please don't. I had a chance to talk with customer support team and talked
> about panic_on_oom briefly. I understood that panic_on_oom_alyways+kdump
> is the strongest tool for investigating customer's OOM situtation and do
> the best advice to them. panic_on_oom_always+kdump is the 100% information
> as snapshot when oom-killer happens. Then, it's easy to investigate and
> explain what is wront. They sometimes discover memory leak (by some prorietary
> driver) or miss-configuration of the system (as using unnecessary bounce buffer.)
> 

Ok, I'm not looking to cause your customers unnecessary grief by removing 
an option that they use, even though the same effect is possible by 
setting all tasks to OOM_DISABLE.  I'll remove this patch in the next 
revision.

> Then, please leave panic_on_oom=always.
> Even with mempolicy or cpuset 's OOM, we need panic_on_oom=always option.
> And yes, I'll add something similar to memcg. freeze_at_oom or something.
> 

Memcg isn't a special case here, it should also panic the machine if 
panic_on_oom == 2, so if we aren't going to remove this option then I 
agree with Nick that we need to panic from mem_cgroup_out_of_memory() as 
well.  Some users use cpusets, for example, for the same effect of memory 
isolation as you use memcg, so panicking in one scenario and not the other 
is inconsistent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
