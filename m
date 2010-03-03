Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BDD326B0047
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 18:28:04 -0500 (EST)
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id o23NS1L7000731
	for <linux-mm@kvack.org>; Wed, 3 Mar 2010 15:28:01 -0800
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by spaceape23.eur.corp.google.com with ESMTP id o23NRwen023722
	for <linux-mm@kvack.org>; Wed, 3 Mar 2010 15:27:59 -0800
Received: by pxi2 with SMTP id 2so676609pxi.26
        for <linux-mm@kvack.org>; Wed, 03 Mar 2010 15:27:58 -0800 (PST)
Date: Wed, 3 Mar 2010 15:27:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
In-Reply-To: <20100303095812.c3d47ee1.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003031527230.32530@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com> <alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com> <20100301052306.GG19665@balbir.in.ibm.com> <alpine.DEB.2.00.1003010159420.26824@chino.kir.corp.google.com>
 <20100302085532.ff9d3cf4.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003021600020.11946@chino.kir.corp.google.com> <20100303092210.a730a903.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003021634030.18535@chino.kir.corp.google.com>
 <20100303094438.1e9b09fb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003021651170.20958@chino.kir.corp.google.com> <20100303095812.c3d47ee1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Mar 2010, KAMEZAWA Hiroyuki wrote:

> In patch 01-03, you don't modified panic_on_oom implementation.
> And this patch, you don't modified the return code of memcg's charge code.
> It still returns -ENOMEM.
> 
> Then, VM_FAULT_OOM is returned and page_fault_out_of_memory() calles this
> and hit this.
> 
>        case CONSTRAINT_NONE:
>                 if (sysctl_panic_on_oom) {
>                         dump_header(NULL, gfp_mask, order, NULL);
>                         panic("out of memory. panic_on_oom is selected\n");
>                 }
> 
> The system will panic. A hook, mem_cgroup_oom_called() is for avoiding this.
> memcg's oom doesn't mean memory shortage, just means it his limit.
> 

And this is fixed by memcg-fix-oom-kill-behavior-v3.patch in -mm, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
