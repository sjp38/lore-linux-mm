Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 33FB76B004D
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 01:51:02 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o246oxa7028372
	for <linux-mm@kvack.org>; Wed, 3 Mar 2010 22:50:59 -0800
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by kpbe14.cbf.corp.google.com with ESMTP id o246ov2x018780
	for <linux-mm@kvack.org>; Wed, 3 Mar 2010 22:50:57 -0800
Received: by pwj8 with SMTP id 8so1423215pwj.33
        for <linux-mm@kvack.org>; Wed, 03 Mar 2010 22:50:57 -0800 (PST)
Date: Wed, 3 Mar 2010 22:50:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
In-Reply-To: <20100304125934.1d8118b0.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003032249340.25386@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com> <alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com> <20100301052306.GG19665@balbir.in.ibm.com> <alpine.DEB.2.00.1003010159420.26824@chino.kir.corp.google.com>
 <20100302085532.ff9d3cf4.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003021600020.11946@chino.kir.corp.google.com> <20100303092210.a730a903.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003021634030.18535@chino.kir.corp.google.com>
 <20100303094438.1e9b09fb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003021651170.20958@chino.kir.corp.google.com> <20100303095812.c3d47ee1.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003031527230.32530@chino.kir.corp.google.com>
 <20100304125934.1d8118b0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Mar 2010, KAMEZAWA Hiroyuki wrote:

> > And this is fixed by memcg-fix-oom-kill-behavior-v3.patch in -mm, right?
> > 
> yes.
> 

Good.  This patch can easily be rebased on top of the next mmotm release, 
then, as I mentioned before.  Do you have time to review the actual oom 
killer part of this patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
