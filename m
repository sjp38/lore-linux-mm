Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2AA6B0078
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 04:50:15 -0500 (EST)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o249oAgf013531
	for <linux-mm@kvack.org>; Thu, 4 Mar 2010 09:50:10 GMT
Received: from pzk41 (pzk41.prod.google.com [10.243.19.169])
	by kpbe15.cbf.corp.google.com with ESMTP id o249o85S008230
	for <linux-mm@kvack.org>; Thu, 4 Mar 2010 01:50:08 -0800
Received: by pzk41 with SMTP id 41so1604110pzk.23
        for <linux-mm@kvack.org>; Thu, 04 Mar 2010 01:50:08 -0800 (PST)
Date: Thu, 4 Mar 2010 01:50:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
In-Reply-To: <20100304160016.dda8101a.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003040149110.30214@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com> <alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com> <20100301052306.GG19665@balbir.in.ibm.com> <alpine.DEB.2.00.1003010159420.26824@chino.kir.corp.google.com>
 <20100302085532.ff9d3cf4.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003021600020.11946@chino.kir.corp.google.com> <20100303092210.a730a903.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003021634030.18535@chino.kir.corp.google.com>
 <20100303094438.1e9b09fb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003021651170.20958@chino.kir.corp.google.com> <20100303095812.c3d47ee1.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003031527230.32530@chino.kir.corp.google.com>
 <20100304125934.1d8118b0.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003032249340.25386@chino.kir.corp.google.com> <20100304160016.dda8101a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Mar 2010, KAMEZAWA Hiroyuki wrote:

> About the _changes_ for generic part itself, I have no concerns.
> 

Is that your acked-by?

> But I'm not sure whether TIF_MEMDIE task has been already killed (quit tasklist)
> before VM_FAULT_OOM task comes here.
> 

If it's no longer a member of the tasklist then it has freed its memory 
and thus returning VM_FAULT_OOM again would mean that we are still oom.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
