Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6C46B01C6
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 14:39:03 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id o58IcxnU016494
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:38:59 -0700
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by hpaq7.eem.corp.google.com with ESMTP id o58IcR1B017091
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:38:58 -0700
Received: by pzk30 with SMTP id 30so4279452pzk.6
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 11:38:58 -0700 (PDT)
Date: Tue, 8 Jun 2010 11:38:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 11/18] oom: avoid oom killer for lowmem allocations
In-Reply-To: <20100606184014.8727.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081138290.18848@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010015460.29202@chino.kir.corp.google.com> <20100606184014.8727.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

> > Previously, the heuristic provided some protection for those tasks with
> > CAP_SYS_RAWIO, but this is no longer necessary since we will not be
> > killing tasks for the purposes of ISA allocations.
> 
> Seems incorrect. CAP_SYS_RAWIO tasks usually both use GFP_KERNEL and GFP_DMA.
> Even if last allocation is GFP_KERNEL, it doesn't provide any gurantee the
> process doesn't have any in flight I/O.
> 

Right, that's why I said it "provided some protection".

> Then, we can't remove for RAWIO protection from oom heuristics. but the code
> itself seems ok though.
> 

It's removed with my heuristic rewrite.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
