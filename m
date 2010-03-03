Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1EE996B0078
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 19:02:51 -0500 (EST)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id o2301nSS020405
	for <linux-mm@kvack.org>; Wed, 3 Mar 2010 00:01:49 GMT
Received: from fxm28 (fxm28.prod.google.com [10.184.13.28])
	by spaceape8.eur.corp.google.com with ESMTP id o2301mbr019948
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 16:01:48 -0800
Received: by fxm28 with SMTP id 28so161500fxm.19
        for <linux-mm@kvack.org>; Tue, 02 Mar 2010 16:01:48 -0800 (PST)
Date: Tue, 2 Mar 2010 16:01:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
In-Reply-To: <20100302085532.ff9d3cf4.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003021600020.11946@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com> <alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com> <20100301052306.GG19665@balbir.in.ibm.com> <alpine.DEB.2.00.1003010159420.26824@chino.kir.corp.google.com>
 <20100302085532.ff9d3cf4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Mar 2010, KAMEZAWA Hiroyuki wrote:

> > Kame said earlier it would be no problem to rebase his memcg oom work on 
> > mmotm if my patches were merged.
> > 
> 
> But I also said this patch cause regression.

This patch causes a regression???  You never said that in any of your 
reviews and I have no idea what you're talking about, this patch simply 
cleans up the code and closes a race where VM_FAULT_OOM could needlessly 
kill tasks in parallel oom conditions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
