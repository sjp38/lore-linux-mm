Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 490A66B004D
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 19:53:09 -0500 (EST)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o230r5f2004320
	for <linux-mm@kvack.org>; Wed, 3 Mar 2010 00:53:06 GMT
Received: from pva18 (pva18.prod.google.com [10.241.209.18])
	by kpbe11.cbf.corp.google.com with ESMTP id o230r43H032069
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 18:53:04 -0600
Received: by pva18 with SMTP id 18so235922pva.36
        for <linux-mm@kvack.org>; Tue, 02 Mar 2010 16:53:04 -0800 (PST)
Date: Tue, 2 Mar 2010 16:53:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
In-Reply-To: <20100303094438.1e9b09fb.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003021651170.20958@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com> <alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com> <20100301052306.GG19665@balbir.in.ibm.com> <alpine.DEB.2.00.1003010159420.26824@chino.kir.corp.google.com>
 <20100302085532.ff9d3cf4.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003021600020.11946@chino.kir.corp.google.com> <20100303092210.a730a903.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003021634030.18535@chino.kir.corp.google.com>
 <20100303094438.1e9b09fb.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Mar 2010, KAMEZAWA Hiroyuki wrote:

> memory_cgroup_out_of_memory() kills a task. and return VM_FAULT_OOM then,
> page_fault_out_of_memory() kills another task.
> and cause panic if panic_on_oom=1.
> 

If mem_cgroup_out_of_memory() has returned, then it has already killed a 
task that will have TIF_MEMDIE set and therefore make the VM_FAULT_OOM oom 
a no-op.  If the oom killed task subsequently returns VM_FAULT_OOM, we 
better panic because we've fully depleted memory reserves and no future 
memory freeing is guaranteed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
