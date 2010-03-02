Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7BAC46B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 18:59:59 -0500 (EST)
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id o22NxvIV024321
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 23:59:57 GMT
Received: from pwi8 (pwi8.prod.google.com [10.241.219.8])
	by spaceape7.eur.corp.google.com with ESMTP id o22Nxtin020017
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 15:59:56 -0800
Received: by pwi8 with SMTP id 8so468612pwi.9
        for <linux-mm@kvack.org>; Tue, 02 Mar 2010 15:59:55 -0800 (PST)
Date: Tue, 2 Mar 2010 15:59:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
In-Reply-To: <20100302112157.0665c339.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003021556211.11946@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com> <alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com> <20100302112157.0665c339.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Mar 2010, KAMEZAWA Hiroyuki wrote:

> Reviewd with refleshed mind.
> 
> 1. mem_cgroup_oom_called should be removed. ok.
> 2. I think mem_cgroup should not return -ENOMEM at charging
>    Then, no complicated thing in page_fault_out_of_memory().
>    I'll add such changes, soom.

pagefault_out_of_memory() needs to do the zone locking to prevent 
needlessly killing tasks when VM_FAULT_OOM races with another cpu trying 
to allocate pages.  This has nothing to do with memcg.

> 3. This patch includes too much things. please divide.
>    At least, please put memcg part ouf of this patch.
> 

No, it doesn't.  The patch rewrites pagefault_out_of_memory() and that 
includes removing a call to mem_cgroup_oom_called(), which you just 
agreed to removing.  I'm not going to leave behind unused code anywhere in 
the kernel that you want to remove yourself anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
